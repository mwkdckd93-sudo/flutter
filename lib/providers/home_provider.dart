import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';
import 'category_provider.dart';

/// Home Provider - manages home page data
class HomeProvider extends ChangeNotifier {
  final ApiService _apiService;
  final SocketService _socketService = SocketService.instance;
  StreamSubscription? _updateSubscription;

  List<Map<String, dynamic>> _categories = [];
  List<AuctionModel> _featuredAuctions = [];
  List<AuctionModel> _endingSoonAuctions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get categories => _categories;
  List<AuctionModel> get featuredAuctions => _featuredAuctions;
  List<AuctionModel> get endingSoonAuctions => _endingSoonAuctions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HomeProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance {
    _startListeningToSocket();
  }

  /// Load home page data
  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load in parallel
      final results = await Future.wait([
        _apiService.getCategories(),
        _apiService.getFeaturedAuctions(),
        _apiService.getEndingSoonAuctions(),
      ]);

      // Parse categories - returns List<CategoryModel>
      final categoriesList = results[0] as List<CategoryModel>;
      _categories = categoriesList.map((c) => c.toJson()).toList();

      _featuredAuctions = results[1] as List<AuctionModel>;
      _endingSoonAuctions = results[2] as List<AuctionModel>;
      
      // If featured empty, load regular auctions for display
      if (_featuredAuctions.isEmpty) {
        try {
          final regularAuctions = await _apiService.getAuctions(limit: 6);
          _featuredAuctions = regularAuctions;
        } catch (_) {}
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading home data: $e');
      // Don't show full error screen if partial data loaded, just log
      if (_categories.isEmpty && _featuredAuctions.isEmpty && _endingSoonAuctions.isEmpty) {
        _error = 'فشل في تحميل البيانات';
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadHomeData();
  }

  void _startListeningToSocket() {
    _updateSubscription?.cancel();
    _updateSubscription = _socketService.auctionListUpdateStream.listen((data) {
      _handleAuctionUpdate(data);
    });
  }

  void _handleAuctionUpdate(Map<String, dynamic> data) {
    if (_featuredAuctions.isEmpty && _endingSoonAuctions.isEmpty) return;

    final auctionId = data['auctionId'];
    final newPrice = (data['newPrice'] as num).toDouble();
    final bidCount = data['bidCount'] as int;
    
    DateTime? endTime;
    if (data['endTime'] != null) {
      endTime = DateTime.tryParse(data['endTime'].toString());
    }

    bool needsUpdate = false;

    // Update featured
    final featuredIndex = _featuredAuctions.indexWhere((a) => a.id == auctionId);
    if (featuredIndex != -1) {
      _featuredAuctions[featuredIndex] = _featuredAuctions[featuredIndex].copyWith(
        currentPrice: newPrice,
        bidCount: bidCount,
        endTime: endTime,
      );
      needsUpdate = true;
    }

    // Update ending soon
    final endSoonIndex = _endingSoonAuctions.indexWhere((a) => a.id == auctionId);
    if (endSoonIndex != -1) {
      _endingSoonAuctions[endSoonIndex] = _endingSoonAuctions[endSoonIndex].copyWith(
        currentPrice: newPrice,
        bidCount: bidCount,
        endTime: endTime,
      );
      needsUpdate = true;
    }

    if (needsUpdate) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }
}
