/// Model for verified shops
class ShopModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final double rating;
  final int productCount;
  final int completedAuctions;
  final DateTime? createdAt;

  const ShopModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.rating = 4.5,
    this.productCount = 0,
    this.completedAuctions = 0,
    this.createdAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      productCount: json['productCount'] as int? ?? 0,
      completedAuctions: json['completedAuctions'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'productCount': productCount,
      'completedAuctions': completedAuctions,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
