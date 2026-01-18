import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

/// Authentication Provider
class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final SocketService _socketService;
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;
  String? _pendingPhone;
  bool _userExists = false;
  String? _existingUserName;
  bool _isInitialized = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  bool get userExists => _userExists;
  String? get existingUserName => _existingUserName;
  bool get isInitialized => _isInitialized;

  AuthProvider({
    ApiService? apiService,
    SocketService? socketService,
  })  : _apiService = apiService ?? ApiService.instance,
        _socketService = socketService ?? SocketService.instance {
    // Try to restore session on initialization
    _restoreSession();
  }

  /// Restore session from local storage
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);
      
      print('🔐 Restoring session: hasToken=${token != null}, hasUserJson=${userJson != null}');
      
      if (token != null && userJson != null) {
        _apiService.setAuthToken(token);
        
        // Verify session with server
        try {
          print('🔄 Verifying session with server...');
          final serverUser = await _apiService.getCurrentUser();
          _user = serverUser;
          _isLoggedIn = true;
          
          // Update saved user data
          await prefs.setString(_userKey, jsonEncode(serverUser.toJson()));
          
          // Connect to socket
          print('🔌 Calling socket connect...');
          _socketService.connect(token);
          
          print('✅ Session verified for ${_user?.fullName}');
        } catch (e) {
          // Session invalid - logout
          print('❌ Session verification failed: $e');
          print('🚪 Logging out due to invalid session...');
          await _clearSession();
          _apiService.clearAuthToken();
          _user = null;
          _isLoggedIn = false;
        }
      } else {
        print('⚠️ No saved session found');
      }
    } catch (e) {
      print('⚠️ Failed to restore session: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Save session to local storage
  Future<void> _saveSession(String token, UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      print('✅ Session saved');
    } catch (e) {
      print('⚠️ Failed to save session: $e');
    }
  }

  /// Clear session from local storage
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      print('✅ Session cleared');
    } catch (e) {
      print('⚠️ Failed to clear session: $e');
    }
  }

  /// Refresh user data from server
  Future<void> refreshUser() async {
    try {
      final updatedUser = await _apiService.getCurrentUser();
      _user = updatedUser;
      
      // Update saved session
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        await _saveSession(token, _user!);
      }
      
      notifyListeners();
    } catch (e) {
      print('⚠️ Failed to refresh user: $e');
    }
  }

  /// Login with Phone and OTP
  Future<bool> login(String phone, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _apiService.verifyOtp(phone, otp);
      
      if (result['token'] != null) {
        final token = result['token'] as String;
        _apiService.setAuthToken(token);
        _user = UserModel.fromJson(result['user']);
        _isLoggedIn = true;
        
        // Save session locally
        await _saveSession(token, _user!);
        
        // Connect to socket for real-time updates
        _socketService.connect(token);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'فشل في تسجيل الدخول';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with Email/Password (for testing)
  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API delay for demo
    await Future.delayed(const Duration(seconds: 1));

    _isLoggedIn = true;
    _user = UserModel(
      id: '1', 
      phone: '07700000000', 
      fullName: 'مستخدم تجريبي',
      createdAt: DateTime.now(),
    );
    
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Send OTP to phone number
  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.sendOtp(phone);
      _pendingPhone = phone;
      _userExists = result['userExists'] == true;
      _existingUserName = result['userName'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ SendOtp Error: $e');
      _error = 'فشل في إرسال رمز التحقق: ${e.toString().substring(0, e.toString().length > 50 ? 50 : e.toString().length)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String otp) async {
    if (_pendingPhone == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.verifyOtp(_pendingPhone!, otp);
      
      if (result['isNewUser'] == true) {
        _isLoading = false;
        notifyListeners();
        return true; // Needs registration
      }
      
      // Existing user - log in
      final token = result['token'] as String;
      _apiService.setAuthToken(token);
      _user = UserModel.fromJson(result['user']);
      _isLoggedIn = true;
      
      // Save session locally
      await _saveSession(token, _user!);
      
      // Connect to socket
      _socketService.connect(token);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'رمز التحقق غير صحيح';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String fullName,
    required String password,
    required AddressModel address,
  }) async {
    print('📝 Register called - pendingPhone: $_pendingPhone');
    
    if (_pendingPhone == null) {
      print('❌ No pending phone!');
      _error = 'رقم الهاتف غير موجود. الرجاء العودة وإدخال الرقم مجدداً';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📤 Sending register request for $_pendingPhone');
      final response = await _apiService.register(
        phone: _pendingPhone!,
        fullName: fullName,
        password: password,
        address: address,
      );
      
      final user = response['user'] as UserModel;
      final token = response['token'] as String?;
      
      print('✅ Register success: ${user.fullName}');
      _user = user;
      _isLoggedIn = true;
      
      // Save session if token is available
      if (token != null) {
        _apiService.setAuthToken(token);
        await _saveSession(token, user);
        _socketService.connect(token);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Register error: $e');
      _error = 'فشل في إنشاء الحساب: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _user = null;
    _isLoggedIn = false;
    _pendingPhone = null;
    _apiService.clearAuthToken();
    _socketService.disconnect();
    
    // Clear saved session
    await _clearSession();
    
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
