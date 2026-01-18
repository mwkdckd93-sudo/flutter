import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

/// Auction List Provider - manages auction listings with filters
class AuctionListProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<AuctionModel> _auctions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  
  // Filters
  String? _categoryId;
  String? _province;
  int? _minPrice;
  int? _maxPrice;
  String? _condition;
  String? _search;
  String _sortBy = 'ending_soon';

  // Getters
  List<AuctionModel> get auctions => _auctions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String? get categoryId => _categoryId;
  String? get province => _province;
  String? get search => _search;
  String get sortBy => _sortBy;

  AuctionListProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  /// Set filters
  void setFilters({
    String? categoryId,
    String? province,
    int? minPrice,
    int? maxPrice,
    String? condition,
    String? search,
    String? sortBy,
  }) {
    _categoryId = categoryId;
    _province = province;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _condition = condition;
    _search = search;
    if (sortBy != null) _sortBy = sortBy;
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _categoryId = null;
    _province = null;
    _minPrice = null;
    _maxPrice = null;
    _condition = null;
    _search = null;
    _sortBy = 'ending_soon';
    notifyListeners();
  }

  /// Load auctions
  Future<void> loadAuctions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    
    if (!refresh && _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _auctions = await _apiService.getAuctions(
        category: _categoryId,
        province: _province,
        minPrice: _minPrice?.toDouble(),
        maxPrice: _maxPrice?.toDouble(),
        search: _search,
        page: 1,
        limit: 20,
      );

      print('📦 Parsed auctions count: ${_auctions.length}');
      _hasMore = _auctions.length >= 20;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في تحميل المزادات';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more auctions (pagination)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newAuctions = await _apiService.getAuctions(
        category: _categoryId,
        province: _province,
        minPrice: _minPrice?.toDouble(),
        maxPrice: _maxPrice?.toDouble(),
        search: _search,
        page: _currentPage + 1,
        limit: 20,
      );

      _auctions.addAll(newAuctions);
      _currentPage++;
      _hasMore = newAuctions.length >= 20;
      
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Search auctions
  Future<void> searchAuctions(String query) async {
    _search = query.isEmpty ? null : query;
    await loadAuctions(refresh: true);
  }

  /// Clear search
  void clearSearch() {
    _search = null;
    _auctions = [];
    notifyListeners();
  }
}
