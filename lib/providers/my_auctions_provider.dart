import 'package:flutter/material.dart';
import '../data/services/api_service.dart';
import '../data/models/models.dart';

class MyAuctionsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.instance;

  bool _isLoading = false;
  String? _error;

  List<AuctionModel> _myAuctions = [];
  List<Map<String, dynamic>> _participatedAuctions = [];
  List<AuctionModel> _wonAuctions = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AuctionModel> get myAuctions => _myAuctions;
  List<Map<String, dynamic>> get participatedAuctions => _participatedAuctions;
  List<AuctionModel> get wonAuctions => _wonAuctions;

  Future<void> loadAllAuctions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadMyAuctions(),
        _loadParticipatedAuctions(),
        _loadWonAuctions(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMyAuctions() async {
    try {
      final products = await _apiService.getMyProducts();
      _myAuctions = products;
    } catch (e) {
      debugPrint('Error loading my auctions: $e');
    }
  }

  Future<void> _loadParticipatedAuctions() async {
    try {
      final response = await _apiService.getParticipatedAuctions();
      if (response['success'] == true) {
        _participatedAuctions = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading participated auctions: $e');
    }
  }

  Future<void> _loadWonAuctions() async {
    try {
      final response = await _apiService.getWonAuctions();
      if (response['success'] == true) {
        final data = response['data'] as List? ?? [];
        _wonAuctions = data.map((e) => AuctionModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading won auctions: $e');
    }
  }

  Future<void> refreshMyAuctions() async {
    await _loadMyAuctions();
    notifyListeners();
  }

  Future<void> refreshParticipatedAuctions() async {
    await _loadParticipatedAuctions();
    notifyListeners();
  }

  Future<void> refreshWonAuctions() async {
    await _loadWonAuctions();
    notifyListeners();
  }
}
