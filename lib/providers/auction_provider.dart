import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

/// Auction Provider - Manages auction data from API
class AuctionProvider extends ChangeNotifier {
  final ApiService _apiService;
  final SocketService _socketService;
  StreamSubscription<AuctionModel>? _newAuctionSubscription;
  StreamSubscription<Map<String, dynamic>>? _priceUpdateSubscription;

  List<AuctionModel> _auctions = [];
  List<AuctionModel> _featuredAuctions = [];
  List<AuctionModel> _myBids = [];
  List<AuctionModel> _myListings = [];
  AuctionModel? _currentAuction;
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String? _auctionsError;  // Separate error for auctions
  String? _myListingsError;  // Separate error for my listings
  String? _myBidsError;  // Separate error for my bids
  
  int _currentPage = 1;
  bool _hasMore = true;
  
  String? _selectedCategory;
  String? _selectedProvince;
  double? _minPrice;
  double? _maxPrice;
  String? _searchQuery;

  // Getters
  List<AuctionModel> get auctions => _auctions;
  List<AuctionModel> get featuredAuctions => _featuredAuctions;
  List<AuctionModel> get myBids => _myBids;
  List<AuctionModel> get myListings => _myListings;
  AuctionModel? get currentAuction => _currentAuction;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String? get auctionsError => _auctionsError;
  String? get myListingsError => _myListingsError;
  String? get myBidsError => _myBidsError;
  bool get hasMore => _hasMore;

  AuctionProvider({ApiService? apiService, SocketService? socketService})
      : _apiService = apiService ?? ApiService.instance,
        _socketService = socketService ?? SocketService.instance {
    _subscribeToUpdates();
  }

  /// Subscribe to socket updates
  void _subscribeToUpdates() {
    // Listen for new auctions
    _newAuctionSubscription = _socketService.newAuctionStream.listen((auction) {
      print('📦 New auction received: ${auction.title}');
      if (!_auctions.any((a) => a.id == auction.id)) {
        _auctions.insert(0, auction);
        notifyListeners();
      }
    });

    // Listen for price updates (bids)
    _priceUpdateSubscription = _socketService.priceUpdateStream.listen((data) {
      final auctionId = data['auctionId'] as String?;
      final newPrice = data['newPrice'];
      final bidCount = data['bidCount'] as int?;
      
      if (auctionId != null && newPrice != null) {
        print('💰 Price update for $auctionId: $newPrice');
        _updateAuctionPrice(auctionId, (newPrice as num).toDouble(), bidCount);
      }
    });
  }

  /// Update auction price in all lists
  void _updateAuctionPrice(String auctionId, double newPrice, int? bidCount) {
    bool updated = false;
    
    // Update in main auctions list
    for (int i = 0; i < _auctions.length; i++) {
      if (_auctions[i].id == auctionId) {
        _auctions[i] = _auctions[i].copyWith(
          currentPrice: newPrice,
          bidCount: bidCount ?? _auctions[i].bidCount + 1,
        );
        updated = true;
        break;
      }
    }

    // Update in featured auctions
    for (int i = 0; i < _featuredAuctions.length; i++) {
      if (_featuredAuctions[i].id == auctionId) {
        _featuredAuctions[i] = _featuredAuctions[i].copyWith(
          currentPrice: newPrice,
          bidCount: bidCount ?? _featuredAuctions[i].bidCount + 1,
        );
        updated = true;
        break;
      }
    }

    // Update in my bids
    for (int i = 0; i < _myBids.length; i++) {
      if (_myBids[i].id == auctionId) {
        _myBids[i] = _myBids[i].copyWith(
          currentPrice: newPrice,
          bidCount: bidCount ?? _myBids[i].bidCount + 1,
        );
        updated = true;
        break;
      }
    }

    if (updated) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _newAuctionSubscription?.cancel();
    _priceUpdateSubscription?.cancel();
    super.dispose();
  }

  /// Fetch auctions from API
  Future<void> fetchAuctions({bool refresh = false, int retryCount = 0}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _auctions = [];
    }

    _isLoading = true;
    _auctionsError = null;
    notifyListeners();

    try {
      final newAuctions = await _apiService.getAuctions(
        category: _selectedCategory,
        province: _selectedProvince,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        search: _searchQuery,
        page: _currentPage,
      );

      if (newAuctions.isEmpty) {
        _hasMore = false;
      } else {
        _auctions.addAll(newAuctions);
        _currentPage++;
      }
      _auctionsError = null;
    } catch (e) {
      print('Error fetching auctions: $e');
      
      // Retry up to 2 times with delay
      if (retryCount < 2) {
        _isLoading = false;
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
        return fetchAuctions(refresh: refresh, retryCount: retryCount + 1);
      }
      
      _auctionsError = 'فشل في تحميل المزادات';
    } finally {
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
        category: _selectedCategory,
        province: _selectedProvince,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        search: _searchQuery,
        page: _currentPage,
      );

      if (newAuctions.isEmpty) {
        _hasMore = false;
      } else {
        _auctions.addAll(newAuctions);
        _currentPage++;
      }
    } catch (e) {
      print('Error loading more: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Set filter and refetch
  void setFilter({
    String? category,
    String? province,
    double? minPrice,
    double? maxPrice,
    String? search,
  }) {
    _selectedCategory = category;
    _selectedProvince = province;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _searchQuery = search;
    fetchAuctions(refresh: true);
  }

  /// Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _selectedProvince = null;
    _minPrice = null;
    _maxPrice = null;
    _searchQuery = null;
    fetchAuctions(refresh: true);
  }

  /// Get single auction details
  Future<void> fetchAuctionDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentAuction = await _apiService.getAuctionById(id);
    } catch (e) {
      _error = 'فشل في تحميل تفاصيل المزاد';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch my bids
  Future<void> fetchMyBids() async {
    _isLoading = true;
    _myBidsError = null;
    notifyListeners();

    try {
      _myBids = await _apiService.getMyBids();
      _myBidsError = null;
    } catch (e) {
      _myBidsError = 'فشل في تحميل مزايداتك';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch my listings
  Future<void> fetchMyListings() async {
    _isLoading = true;
    _myListingsError = null;
    notifyListeners();

    try {
      _myListings = await _apiService.getMyListings();
      _myListingsError = null;
    } catch (e) {
      _myListingsError = 'فشل في تحميل معروضاتك';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new auction
  Future<String?> createAuction({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final auctionId = await _apiService.createAuction(
        title: title,
        description: description,
        categoryId: categoryId,
        condition: condition,
        warranty: warranty,
        images: images,
        startingPrice: startingPrice,
        minBidIncrement: minBidIncrement,
        durationHours: durationHours,
        shippingProvinces: shippingProvinces,
      );
      
      // Refresh my listings to get the new auction
      await fetchMyListings();
      
      _isLoading = false;
      notifyListeners();
      return auctionId;
    } catch (e) {
      _error = 'فشل في إنشاء المزاد';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Place bid via REST (alternative to socket)
  Future<bool> placeBid(String auctionId, double amount) async {
    try {
      await _apiService.placeBid(auctionId: auctionId, amount: amount);
      // Refresh auction details
      await fetchAuctionDetails(auctionId);
      return true;
    } catch (e) {
      _error = 'فشل في تقديم المزايدة';
      notifyListeners();
      return false;
    }
  }

  /// Update current auction price (from socket)
  void updateAuctionPrice(String auctionId, double newPrice, int bidCount) {
    // Update in list
    final index = _auctions.indexWhere((a) => a.id == auctionId);
    if (index != -1) {
      _auctions[index] = _auctions[index].copyWith(
        currentPrice: newPrice,
        bidCount: bidCount,
      );
    }

    // Update current if viewing
    if (_currentAuction?.id == auctionId) {
      _currentAuction = _currentAuction!.copyWith(
        currentPrice: newPrice,
        bidCount: bidCount,
      );
    }

    notifyListeners();
  }

  /// Update auction in list from detail page
  void updateAuctionInList(AuctionModel updatedAuction) {
    // Update in main auctions list
    final index = _auctions.indexWhere((a) => a.id == updatedAuction.id);
    if (index != -1) {
      _auctions[index] = updatedAuction;
    }

    // Update in featured auctions
    final featuredIndex = _featuredAuctions.indexWhere((a) => a.id == updatedAuction.id);
    if (featuredIndex != -1) {
      _featuredAuctions[featuredIndex] = updatedAuction;
    }

    // Update in my bids
    final bidsIndex = _myBids.indexWhere((a) => a.id == updatedAuction.id);
    if (bidsIndex != -1) {
      _myBids[bidsIndex] = updatedAuction;
    }

    notifyListeners();
  }

  /// Add or update auction in my bids list when user places a bid
  void addToMyBids(AuctionModel auction) {
    // Check if already in list
    final existingIndex = _myBids.indexWhere((a) => a.id == auction.id);
    if (existingIndex != -1) {
      // Update existing
      _myBids[existingIndex] = auction;
    } else {
      // Add to beginning
      _myBids.insert(0, auction);
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
