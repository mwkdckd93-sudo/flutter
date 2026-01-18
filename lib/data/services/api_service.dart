import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/models.dart';
import '../../providers/category_provider.dart';

/// API Service for REST endpoints
class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  String? _authToken;
  static const String _tokenKey = 'auth_token';
  bool _tokenRestoreFailed = false; // Prevent infinite retry loop

  ApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true', // Required for ngrok
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Auto-restore token from SharedPreferences if missing (only once)
        if (_authToken == null && !_tokenRestoreFailed) {
          await _tryRestoreToken();
        }
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 errors - token might be expired
        if (error.response?.statusCode == 401) {
          print('🔐 API 401 Error - Token may be expired or invalid');
          // Clear invalid token from memory AND storage
          _authToken = null;
          _tokenRestoreFailed = true; // Prevent retry loop
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(_tokenKey);
            print('🔐 Invalid token cleared from storage');
          } catch (e) {
            print('⚠️ Failed to clear token from storage: $e');
          }
        }
        print('API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// Try to restore token from SharedPreferences
  Future<void> _tryRestoreToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      if (savedToken != null) {
        _authToken = savedToken;
        print('🔐 Token auto-restored from storage');
      }
    } catch (e) {
      print('⚠️ Failed to restore token: $e');
    }
  }

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  /// Get current auth token (for other services)
  String? get authToken => _authToken;

  void setAuthToken(String token) {
    _authToken = token;
    _tokenRestoreFailed = false; // Reset on successful login
  }

  void clearAuthToken() {
    _authToken = null;
    _tokenRestoreFailed = false; // Allow restore on next login
  }

  // ============ Upload Endpoints ============

  /// Get the base URL without /api suffix for static files
  String get _staticBaseUrl {
    final url = AppConstants.baseUrl;
    if (url.endsWith('/api')) {
      return url.substring(0, url.length - 4);
    }
    return url;
  }

  /// Upload a single image file
  Future<String> uploadImage(File imageFile) async {
    try {
      // Get filename cross-platform (works with both / and \)
      final filename = imageFile.path.split(RegExp(r'[/\\]')).last;
      
      print('📤 Uploading image: ${imageFile.path}');
      print('📤 Filename: $filename');
      print('📤 File exists: ${await imageFile.exists()}');
      print('📤 File size: ${await imageFile.length()} bytes');
      
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: filename,
        ),
      });

      final response = await _dio.post('/upload/image', data: formData);
      
      print('📤 Upload response: ${response.data}');
      
      if (response.data['success'] == true) {
        // Return full URL (static files are served without /api prefix)
        final url = '$_staticBaseUrl${response.data['data']['url']}';
        print('📤 Image URL: $url');
        return url;
      }
      throw Exception(response.data['message'] ?? 'فشل في رفع الصورة');
    } catch (e) {
      print('❌ Upload error: $e');
      rethrow;
    }
  }

  /// Upload multiple image files
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    final List<MultipartFile> files = [];
    
    for (final file in imageFiles) {
      // Get filename cross-platform (works with both / and \)
      final filename = file.path.split(RegExp(r'[/\\]')).last;
      files.add(await MultipartFile.fromFile(
        file.path,
        filename: filename,
      ));
    }

    final formData = FormData.fromMap({
      'images': files,
    });

    final response = await _dio.post('/upload/images', data: formData);
    
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((img) => '$_staticBaseUrl${img['url']}').toList();
    }
    throw Exception(response.data['message'] ?? 'فشل في رفع الصور');
  }

  /// Delete an uploaded image
  Future<void> deleteImage(String filename) async {
    await _dio.delete('/upload/image/$filename');
  }

  // ============ Auth Endpoints ============

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await _dio.post('/auth/send-otp', data: {'phone': phone});
    return response.data;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final response = await _dio.post('/auth/verify-otp', data: {
      'phone': phone,
      'otp': otp,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> register({
    required String phone,
    required String fullName,
    required String password,
    required AddressModel address,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'phone': phone,
      'fullName': fullName,
      'password': password,
      'address': address.toJson(),
    });
    return {
      'user': UserModel.fromJson(response.data['user']),
      'token': response.data['token'],
    };
  }

  // ============ Auction Endpoints ============

  Future<List<AuctionModel>> getAuctions({
    String? category,
    String? province,
    double? minPrice,
    double? maxPrice,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get('/auctions', queryParameters: {
      if (category != null) 'category': category,
      if (province != null) 'province': province,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (search != null) 'search': search,
      'page': page,
      'limit': limit,
    });
    
    return (response.data['auctions'] as List)
        .map((e) => AuctionModel.fromJson(e))
        .toList();
  }

  Future<List<AuctionModel>> getFeaturedAuctions() async {
    final response = await _dio.get('/auctions', queryParameters: {
      'featured': true,
      'limit': 10,
    });
    return (response.data['auctions'] as List)
        .map((e) => AuctionModel.fromJson(e))
        .toList();
  }

  Future<List<AuctionModel>> getEndingSoonAuctions() async {
    final response = await _dio.get('/auctions', queryParameters: {
      'sortBy': 'endTime',
      'sortOrder': 'asc',
      'limit': 10,
    });
    return (response.data['auctions'] as List)
        .map((e) => AuctionModel.fromJson(e))
        .toList();
  }

  Future<AuctionModel> getAuctionById(String id) async {
    try {
      final response = await _dio.get('/auctions/$id');
      final data = response.data['data'] ?? response.data;
      
      // Helper function to convert to double
      double toDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }
      
      // Extract images - handle both array of strings and array of objects
      List<String> extractImages(dynamic images) {
        if (images == null) return [];
        if (images is! List) return [];
        return images.map<String>((img) {
          if (img is String) return img;
          if (img is Map) return img['url']?.toString() ?? '';
          return '';
        }).where((url) => url.isNotEmpty).toList();
      }
      
      // Transform bids
      List<Map<String, dynamic>> transformBids(dynamic bids) {
        if (bids == null || bids is! List) return [];
        return bids.map<Map<String, dynamic>>((b) => {
          'id': b['id']?.toString() ?? '',
          'amount': toDouble(b['amount']),
          'bidderName': b['bidderName']?.toString() ?? 'مستخدم',
          'bidderAvatar': b['bidderAvatar']?.toString(),
          'isAutoBid': b['isAutoBid'] == 1 || b['isAutoBid'] == true,
          'createdAt': b['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
        }).toList();
      }
      
      // Transform questions
      List<Map<String, dynamic>> transformQuestions(dynamic questions) {
        if (questions == null || questions is! List) return [];
        return questions.map<Map<String, dynamic>>((q) => {
          'id': q['id']?.toString() ?? '',
          'question': q['question']?.toString() ?? '',
          'answer': q['answer']?.toString(),
          'askerName': q['askerName']?.toString(),
          'answeredAt': q['answeredAt']?.toString(),
          'createdAt': q['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
        }).toList();
      }
      
      // Transform to match AuctionModel format
      final transformed = {
        'id': data['id']?.toString() ?? '',
        'title': data['title']?.toString() ?? '',
        'description': data['description']?.toString() ?? '',
        'categoryId': data['categoryId']?.toString() ?? 'cat-1',
        'categoryName': data['categoryName']?.toString() ?? '',
        'condition': data['condition'] == 'new' ? 'new' : 'used',
        'warranty': data['warranty'] ?? {'hasWarranty': false},
        'images': extractImages(data['images']),
        'sellerId': data['seller']?['id']?.toString() ?? '',
        'sellerName': data['seller']?['name']?.toString() ?? '',
        'sellerAvatar': data['seller']?['avatar']?.toString(),
        'sellerRating': toDouble(data['seller']?['rating']),
        'startingPrice': toDouble(data['startingPrice']),
        'currentPrice': toDouble(data['currentPrice']),
        'minBidIncrement': toDouble(data['minBidIncrement']),
        'bidCount': data['bidCount'] as int? ?? 0,
        'startTime': data['startTime']?.toString(),
        'endTime': data['endTime']?.toString(),
        'shippingProvinces': data['shippingProvinces'] ?? [],
        'status': data['status']?.toString() ?? 'active',
        'isFavorite': data['isWatched'] == true || data['isWatched'] == 1,
        'createdAt': data['createdAt']?.toString() ?? data['startTime']?.toString(),
        'highestBidderId': data['highestBidderId']?.toString(),
        'recentBids': transformBids(data['bids']),
        'questions': transformQuestions(data['questions']),
      };
      
      return AuctionModel.fromJson(transformed);
    } catch (e) {
      print('❌ Error loading auction: $e');
      rethrow;
    }
  }

  Future<String> createAuction({
    required String title,
    required String description,
    required String categoryId,
    required String condition,
    required Map<String, dynamic> warranty,
    required List<String> images,
    required double startingPrice,
    required double minBidIncrement,
    required int durationHours,
    required List<String> shippingProvinces,
  }) async {
    final response = await _dio.post('/auctions', data: {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'condition': condition,
      'warranty': warranty,
      'images': images,
      'startingPrice': startingPrice,
      'minBidIncrement': minBidIncrement,
      'durationHours': durationHours,
      'shippingProvinces': shippingProvinces,
    });
    
    // Return the auction ID
    return response.data['data']['id'] as String;
  }

  // ============ Bid Endpoints ============

  Future<BidModel> placeBid({
    required String auctionId,
    required double amount,
  }) async {
    final response = await _dio.post('/bids', data: {
      'auctionId': auctionId,
      'amount': amount,
    });
    
    // Backend returns: { success, message, data: { bidId, amount, newPrice, bidCount } }
    final data = response.data['data'] ?? response.data;
    return BidModel(
      id: data['bidId'] ?? '',
      auctionId: auctionId,
      bidderId: '',
      bidderName: '',
      amount: (data['amount'] as num).toDouble(),
      createdAt: DateTime.now(),
    );
  }

  Future<void> setupAutoBid({
    required String auctionId,
    required double maxAmount,
  }) async {
    await _dio.post('/auctions/$auctionId/auto-bid', data: {
      'maxAmount': maxAmount,
    });
  }

  Future<List<BidModel>> getAuctionBids(String auctionId) async {
    final response = await _dio.get('/auctions/$auctionId/bids');
    return (response.data as List).map((e) => BidModel.fromJson(e)).toList();
  }

  // ============ Question Endpoints ============

  Future<QuestionModel> askQuestion({
    required String auctionId,
    required String question,
  }) async {
    final response = await _dio.post('/auctions/$auctionId/questions', data: {
      'question': question,
    });
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return QuestionModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'فشل في إرسال السؤال');
  }

  Future<QuestionModel> answerQuestion({
    required String auctionId,
    required String questionId,
    required String answer,
  }) async {
    final response = await _dio.put(
      '/auctions/$auctionId/questions/$questionId/answer',
      data: {'answer': answer},
    );
    
    if (response.data['success'] == true) {
      return QuestionModel(
        id: questionId,
        question: '',
        answer: answer,
        createdAt: DateTime.now(),
      );
    }
    throw Exception(response.data['message'] ?? 'فشل في حفظ الإجابة');
  }

  // ============ User Endpoints ============

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get('/users/me');
    // API returns { success: true, data: {...} }
    final userData = response.data['data'] ?? response.data;
    return UserModel.fromJson(userData);
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? avatarUrl,
    String? bio,
    String? address,
    String? city,
    String? province,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['fullName'] = fullName;
    if (email != null) data['email'] = email;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (bio != null) data['bio'] = bio;
    if (address != null) data['address'] = address;
    if (city != null) data['city'] = city;
    if (province != null) data['province'] = province;

    await _dio.put('/users/me', data: data);
  }

  /// Get user's saved/bookmarked auctions (watchlist)
  Future<List<AuctionModel>> getSavedAuctions() async {
    final response = await _dio.get('/auctions', queryParameters: {
      'watchlist': true,
    });
    if (response.data['success'] == true) {
      final List<dynamic> auctions = response.data['auctions'] ?? [];
      return auctions.where((a) => a['is_watched'] == 1 || a['is_watched'] == true).map((a) => AuctionModel.fromJson(a)).toList();
    }
    return [];
  }

  /// Toggle watchlist status for an auction
  Future<bool> toggleWatchlist(String auctionId) async {
    final response = await _dio.post('/auctions/$auctionId/watch');
    if (response.data['success'] == true) {
      return response.data['isWatched'] == true;
    }
    throw Exception(response.data['message'] ?? 'فشل في تحديث المحفوظات');
  }

  Future<List<AuctionModel>> getMyBids() async {
    final response = await _dio.get('/users/me/bids');
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => AuctionModel.fromJson(e)).toList();
  }

  Future<List<AuctionModel>> getMyPurchases() async {
    final response = await _dio.get('/users/me/purchases');
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => AuctionModel.fromJson(e)).toList();
  }

  Future<List<AuctionModel>> getMyAuctions() async {
    final response = await _dio.get('/users/me/auctions');
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => AuctionModel.fromJson(e)).toList();
  }

  Future<List<AuctionModel>> getMyListings() async {
    final response = await _dio.get('/users/me/auctions');
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => AuctionModel.fromJson(e)).toList();
  }

  /// Get user's help codes (order numbers for support)
  Future<List<dynamic>> getHelpCodes() async {
    final response = await _dio.get('/users/help-codes');
    if (response.data['success'] == true) {
      return response.data['data'] as List? ?? [];
    }
    return [];
  }

  /// Generate a help code for a won auction
  Future<String> generateHelpCode(String auctionId) async {
    final response = await _dio.post('/users/help-codes', data: {
      'auctionId': auctionId,
    });
    if (response.data['success'] == true) {
      return response.data['data']['helpCode'] ?? '';
    }
    throw Exception(response.data['message'] ?? 'فشل في إنشاء رقم الطلب');
  }

  // ============ Category Endpoints ============

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get('/categories');
    // API returns {data: [...]} or {success: true, data: [...]}
    final List<dynamic> categoriesData;
    if (response.data is List) {
      categoriesData = response.data;
    } else if (response.data is Map && response.data['data'] != null) {
      categoriesData = response.data['data'] as List;
    } else {
      categoriesData = [];
    }
    return categoriesData.map((e) => CategoryModel.fromJson(e)).toList();
  }

  // ============ Notification Endpoints ============

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _dio.get('/notifications');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<int> getUnreadNotificationCount() async {
    final response = await _dio.get('/notifications/unread-count');
    return response.data['count'] ?? 0;
  }

  Future<void> markNotificationRead(String id) async {
    await _dio.patch('/notifications/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _dio.patch('/notifications/read-all');
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete('/notifications/$id');
  }

  // ============ Wallet Endpoints ============

  Future<Map<String, dynamic>> getWallet() async {
    final response = await _dio.get('/wallet');
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getWalletTransactions({String? type}) async {
    final response = await _dio.get('/wallet/transactions', queryParameters: {
      if (type != null) 'type': type,
    });
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getWalletHolds() async {
    final response = await _dio.get('/wallet/holds');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> requestDeposit({
    required double amount,
    required String method,
    String? reference,
  }) async {
    await _dio.post('/wallet/deposit', data: {
      'amount': amount,
      'method': method,
      if (reference != null) 'reference': reference,
    });
  }

  Future<void> requestWithdraw({
    required double amount,
    required String method,
    required Map<String, dynamic> accountDetails,
  }) async {
    await _dio.post('/wallet/withdraw', data: {
      'amount': amount,
      'method': method,
      'accountDetails': accountDetails,
    });
  }

  Future<void> cancelWithdraw(String transactionId) async {
    await _dio.delete('/wallet/withdraw/$transactionId');
  }

  // ============ My Products/Auctions Endpoints ============

  Future<List<AuctionModel>> getMyProducts() async {
    final response = await _dio.get('/users/me/products');
    
    // Response is an array directly
    final data = response.data is List ? response.data : [];
    return data.map<AuctionModel>((e) => AuctionModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getParticipatedAuctions() async {
    final response = await _dio.get('/users/me/participated-auctions');
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getWonAuctions() async {
    final response = await _dio.get('/users/me/won-auctions');
    return Map<String, dynamic>.from(response.data);
  }

  // ============ Chat Endpoints ============

  /// Get all conversations for current user
  Future<List<Map<String, dynamic>>> getConversations() async {
    final response = await _dio.get('/chat/conversations');
    if (response.data['success'] == true) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'فشل في جلب المحادثات');
  }

  /// Get or create conversation for auction
  Future<Map<String, dynamic>> getOrCreateConversation(String auctionId) async {
    final response = await _dio.post('/chat/conversation', data: {
      'auctionId': auctionId,
    });
    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'فشل في إنشاء المحادثة');
  }

  /// Get messages for conversation
  Future<List<Map<String, dynamic>>> getMessages(String conversationId, {int page = 1}) async {
    final response = await _dio.get('/chat/messages/$conversationId', queryParameters: {
      'page': page,
    });
    if (response.data['success'] == true) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'فشل في جلب الرسائل');
  }

  /// Send message
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String body,
    String messageType = 'text',
    String? attachmentUrl,
  }) async {
    final response = await _dio.post('/chat/messages', data: {
      'conversationId': conversationId,
      'body': body,
      'messageType': messageType,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
    });
    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'فشل في إرسال الرسالة');
  }

  /// Update conversation status
  Future<void> updateConversationStatus(String conversationId, String status) async {
    await _dio.put('/chat/conversation/$conversationId/status', data: {
      'status': status,
    });
  }

  /// Get auction completion details
  Future<Map<String, dynamic>> getAuctionCompletionDetails(String auctionId) async {
    final response = await _dio.get('/chat/auction/$auctionId/details');
    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'فشل في جلب تفاصيل المزاد');
  }

  // ============ Address Endpoints ============

  /// Get user addresses
  Future<List<AddressModel>> getAddresses() async {
    final response = await _dio.get('/users/addresses');
    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((a) => AddressModel.fromJson(a))
          .toList();
    }
    throw Exception(response.data['message'] ?? 'فشل في جلب العناوين');
  }

  /// Add new address
  Future<AddressModel> addAddress(AddressModel address) async {
    final response = await _dio.post('/users/addresses', data: address.toJson());
    if (response.data['success'] == true) {
      return AddressModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'فشل في إضافة العنوان');
  }

  /// Update address
  Future<void> updateAddress(String addressId, AddressModel address) async {
    final response = await _dio.put('/users/addresses/$addressId', data: address.toJson());
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل في تحديث العنوان');
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    final response = await _dio.delete('/users/addresses/$addressId');
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل في حذف العنوان');
    }
  }

  /// Set address as primary
  Future<void> setPrimaryAddress(String addressId) async {
    final response = await _dio.put('/users/addresses/$addressId/primary');
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل في تعيين العنوان الرئيسي');
    }
  }

  // ============ User Wallet Endpoints ============

  /// Get wallet balance and transactions from users endpoint
  Future<Map<String, dynamic>> getUserWallet() async {
    final response = await _dio.get('/users/wallet');
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception(response.data['message'] ?? 'فشل في جلب المحفظة');
  }

  /// Request deposit to user wallet
  Future<void> requestUserDeposit(double amount) async {
    final response = await _dio.post('/users/wallet/deposit', data: {
      'amount': amount,
    });
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل في طلب الإيداع');
    }
  }

  /// Request withdrawal from user wallet
  Future<void> requestUserWithdrawal(double amount) async {
    final response = await _dio.post('/users/wallet/withdraw', data: {
      'amount': amount,
    });
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل في طلب السحب');
    }
  }

  // ============ Shops Endpoints ============

  /// Get verified shops
  Future<List<ShopModel>> getVerifiedShops({int limit = 10}) async {
    final response = await _dio.get('/users/verified-shops', queryParameters: {
      'limit': limit,
    });
    
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((shop) => ShopModel.fromJson(shop)).toList();
    }
    throw Exception(response.data['message'] ?? 'فشل في جلب المحلات المعتمدة');
  }

  /// Get auctions by seller ID
  Future<List<AuctionModel>> getAuctionsBySeller(String sellerId) async {
    final response = await _dio.get('/auctions', queryParameters: {
      'seller_id': sellerId,
      'limit': 50,
    });
    
    if (response.data['success'] == true) {
      final List<dynamic> auctions = response.data['auctions'] ?? [];
      return auctions.map((a) => AuctionModel.fromJson(a)).toList();
    }
    throw Exception(response.data['message'] ?? 'فشل في جلب منتجات المحل');
  }

  /// Get auctions by category ID
  Future<List<AuctionModel>> getAuctionsByCategory(String categoryId) async {
    final response = await _dio.get('/auctions', queryParameters: {
      'category': categoryId,
      'limit': 50,
    });
    
    if (response.data['success'] == true) {
      final List<dynamic> auctions = response.data['auctions'] ?? [];
      return auctions.map((a) => AuctionModel.fromJson(a)).toList();
    }
    throw Exception(response.data['message'] ?? 'فشل في جلب منتجات القسم');
  }
}
