import 'package:flutter/foundation.dart';
import '../data/services/services.dart';

/// Wallet Provider - manages wallet data
class WalletProvider extends ChangeNotifier {
  final ApiService _apiService;

  int _balance = 0;
  int _heldBalance = 0;
  int _pendingDeposits = 0;
  int _pendingWithdrawals = 0;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _holds = [];
  bool _isLoading = false;
  bool _isLoadingTransactions = false;
  String? _error;

  // Getters
  int get balance => _balance;
  int get heldBalance => _heldBalance;
  int get availableBalance => _balance - _heldBalance;
  int get pendingDeposits => _pendingDeposits;
  int get pendingWithdrawals => _pendingWithdrawals;
  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get holds => _holds;
  bool get isLoading => _isLoading;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String? get error => _error;

  WalletProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  /// Load wallet data
  Future<void> loadWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getWallet();
      _balance = data['balance'] ?? 0;
      _heldBalance = data['heldBalance'] ?? 0;
      _pendingDeposits = data['pendingDeposits'] ?? 0;
      _pendingWithdrawals = data['pendingWithdrawals'] ?? 0;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في تحميل بيانات المحفظة';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load transactions
  Future<void> loadTransactions({String? type, bool refresh = false}) async {
    _isLoadingTransactions = true;
    notifyListeners();

    try {
      final data = await _apiService.getWalletTransactions(type: type);
      _transactions = data;
      _isLoadingTransactions = false;
      notifyListeners();
    } catch (e) {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

  /// Load holds
  Future<void> loadHolds() async {
    try {
      final data = await _apiService.getWalletHolds();
      _holds = data;
      notifyListeners();
    } catch (e) {
      // Handle silently
    }
  }

  /// Load wallet data (alias for loadWallet)
  Future<void> loadWalletData() async {
    await loadWallet();
    await loadTransactions();
  }

  /// Pending balance (alias for pendingDeposits + pendingWithdrawals)
  int get pendingBalance => _pendingDeposits + _pendingWithdrawals;

  /// Deposit (simplified alias)
  Future<bool> deposit(int amount, String method) async {
    return requestDeposit(amount: amount, paymentMethod: method);
  }

  /// Withdraw (simplified alias)
  Future<bool> withdraw(int amount, String method) async {
    return requestWithdraw(
      amount: amount,
      withdrawMethod: method,
      accountDetails: {},
    );
  }

  /// Request deposit
  Future<bool> requestDeposit({
    required int amount,
    required String paymentMethod,
    String? paymentReference,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.requestDeposit(
        amount: amount.toDouble(),
        method: paymentMethod,
        reference: paymentReference,
      );
      await loadWallet();
      return true;
    } catch (e) {
      _error = 'فشل في تقديم طلب الإيداع';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Request withdrawal
  Future<bool> requestWithdraw({
    required int amount,
    required String withdrawMethod,
    required Map<String, dynamic> accountDetails,
  }) async {
    if (amount > availableBalance) {
      _error = 'الرصيد المتاح غير كافي';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.requestWithdraw(
        amount: amount.toDouble(),
        method: withdrawMethod,
        accountDetails: accountDetails,
      );
      await loadWallet();
      return true;
    } catch (e) {
      _error = 'فشل في تقديم طلب السحب';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancel withdrawal
  Future<bool> cancelWithdraw(String transactionId) async {
    try {
      await _apiService.cancelWithdraw(transactionId);
      await loadWallet();
      await loadTransactions();
      return true;
    } catch (e) {
      _error = 'فشل في إلغاء طلب السحب';
      notifyListeners();
      return false;
    }
  }

  /// Format price in Iraqi Dinar
  String formatPrice(int amount) {
    return '${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    )} د.ع';
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
