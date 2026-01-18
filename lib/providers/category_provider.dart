import 'package:flutter/foundation.dart';
import '../data/services/services.dart';

/// Category Model
class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final int auctionCount;

  const CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.auctionCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      // Use nameAr (Arabic name) if available, fallback to name
      name: (json['nameAr'] ?? json['name']) as String,
      icon: json['icon'] as String?,
      auctionCount: json['auctionCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'auctionCount': auctionCount,
    };
  }
}

/// Category Provider - Manages categories from API
class CategoryProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  /// Fetch categories from API
  Future<void> fetchCategories() async {
    if (_categories.isNotEmpty) return; // Already loaded

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getCategories();
      _categories = response;
    } catch (e) {
      _error = 'فشل في تحميل التصنيفات';
      print('Error fetching categories: $e');
      
      // Fallback to default categories
      _categories = [
        const CategoryModel(id: '1', name: 'إلكترونيات', icon: 'devices'),
        const CategoryModel(id: '2', name: 'موبايلات', icon: 'smartphone'),
        const CategoryModel(id: '3', name: 'أجهزة منزلية', icon: 'kitchen'),
        const CategoryModel(id: '4', name: 'كيمينك', icon: 'sports_esports'),
        const CategoryModel(id: '5', name: 'أثاث', icon: 'chair'),
        const CategoryModel(id: '6', name: 'ساعات', icon: 'watch'),
        const CategoryModel(id: '7', name: 'كاميرات', icon: 'camera_alt'),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
