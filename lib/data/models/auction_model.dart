import 'bid_model.dart';
import 'question_model.dart';


/// Product Condition Enum
enum ProductCondition {
  newProduct('جديد', 'new'),
  used('مستعمل', 'used');

  final String arabicName;
  final String value;
  const ProductCondition(this.arabicName, this.value);

  static ProductCondition fromValue(String value) {
    return ProductCondition.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProductCondition.used,
    );
  }
}

/// Auction Status Enum
enum AuctionStatus {
  pending('قيد المراجعة', 'pending'),
  active('نشط', 'active'),
  ending('ينتهي قريباً', 'ending'),
  ended('منتهي', 'ended'),
  sold('تم البيع', 'sold'),
  cancelled('ملغي', 'cancelled');

  final String arabicName;
  final String value;
  const AuctionStatus(this.arabicName, this.value);

  static AuctionStatus fromValue(String value) {
    return AuctionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AuctionStatus.pending,
    );
  }
}

/// Warranty Info
class WarrantyInfo {
  final bool hasWarranty;
  final int? durationMonths;
  final String? description;

  const WarrantyInfo({
    this.hasWarranty = false,
    this.durationMonths,
    this.description,
  });

  factory WarrantyInfo.fromJson(Map<String, dynamic> json) {
    return WarrantyInfo(
      hasWarranty: json['hasWarranty'] as bool? ?? false,
      durationMonths: json['durationMonths'] as int?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasWarranty': hasWarranty,
      'durationMonths': durationMonths,
      'description': description,
    };
  }

  String get displayText {
    if (!hasWarranty) return 'لا يوجد ضمان';
    if (durationMonths == null) return 'يوجد ضمان';
    return 'ضمان $durationMonths شهر';
  }
}

/// Auction Model
class AuctionModel {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String categoryName;
  final ProductCondition condition;
  final WarrantyInfo warranty;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final String? sellerAvatar;
  final double sellerRating;
  final double startingPrice;
  final double currentPrice;
  final double minBidIncrement;
  final int bidCount;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> shippingProvinces;
  final AuctionStatus status;
  final String? winnerId;
  final String? winnerName;
  final String? highestBidderId;
  final List<BidModel> recentBids;
  final List<QuestionModel> questions;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? approvedAt;

  const AuctionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.condition,
    required this.warranty,
    required this.images,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatar,
    this.sellerRating = 0,
    required this.startingPrice,
    required this.currentPrice,
    required this.minBidIncrement,
    this.bidCount = 0,
    required this.startTime,
    required this.endTime,
    required this.shippingProvinces,
    this.status = AuctionStatus.pending,
    this.winnerId,
    this.winnerName,
    this.highestBidderId,
    this.recentBids = const [],
    this.questions = const [],
    this.isFavorite = false,
    required this.createdAt,
    this.approvedAt,
  });

  factory AuctionModel.fromJson(Map<String, dynamic> json) {
    return AuctionModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      condition: ProductCondition.fromValue(json['condition'] as String? ?? 'used'),
      warranty: WarrantyInfo.fromJson(json['warranty'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      sellerId: json['sellerId'] as String? ?? '',
      sellerName: json['sellerName'] as String? ?? '',
      sellerAvatar: json['sellerAvatar'] as String?,
      sellerRating: (json['sellerRating'] as num?)?.toDouble() ?? 0,
      startingPrice: (json['startingPrice'] as num?)?.toDouble() ?? 0,
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0,
      minBidIncrement: (json['minBidIncrement'] as num?)?.toDouble() ?? 1000,
      bidCount: json['bidCount'] as int? ?? 0,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : DateTime.now().add(const Duration(days: 7)),
      shippingProvinces: List<String>.from(json['shippingProvinces'] ?? []),
      status: AuctionStatus.fromValue(json['status'] as String? ?? 'pending'),
      winnerId: json['winnerId'] as String?,
      winnerName: json['winnerName'] as String?,
      highestBidderId: json['highestBidderId'] as String?,
      recentBids: (json['recentBids'] as List<dynamic>?)
              ?.map((e) => BidModel.fromJson(e))
              .toList() ??
          [],
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuestionModel.fromJson(e))
              .toList() ??
          [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'condition': condition.value,
      'warranty': warranty.toJson(),
      'images': images,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerAvatar': sellerAvatar,
      'sellerRating': sellerRating,
      'startingPrice': startingPrice,
      'currentPrice': currentPrice,
      'minBidIncrement': minBidIncrement,
      'bidCount': bidCount,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'shippingProvinces': shippingProvinces,
      'status': status.value,
      'winnerId': winnerId,
      'winnerName': winnerName,
      'highestBidderId': highestBidderId,
      'recentBids': recentBids.map((e) => e.toJson()).toList(),
      'questions': questions.map((e) => e.toJson()).toList(),
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }

  AuctionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    String? categoryName,
    ProductCondition? condition,
    WarrantyInfo? warranty,
    List<String>? images,
    String? sellerId,
    String? sellerName,
    String? sellerAvatar,
    double? sellerRating,
    double? startingPrice,
    double? currentPrice,
    double? minBidIncrement,
    int? bidCount,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? shippingProvinces,
    AuctionStatus? status,
    String? winnerId,
    String? winnerName,
    String? highestBidderId,
    List<BidModel>? recentBids,
    List<QuestionModel>? questions,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return AuctionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      condition: condition ?? this.condition,
      warranty: warranty ?? this.warranty,
      images: images ?? this.images,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      sellerRating: sellerRating ?? this.sellerRating,
      startingPrice: startingPrice ?? this.startingPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      minBidIncrement: minBidIncrement ?? this.minBidIncrement,
      bidCount: bidCount ?? this.bidCount,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      shippingProvinces: shippingProvinces ?? this.shippingProvinces,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      winnerName: winnerName ?? this.winnerName,
      highestBidderId: highestBidderId ?? this.highestBidderId,
      recentBids: recentBids ?? this.recentBids,
      questions: questions ?? this.questions,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  /// Time remaining until auction ends
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }

  /// Check if auction is about to end (within anti-sniping threshold)
  bool get isAboutToEnd {
    return timeRemaining.inMinutes <= 5 && timeRemaining.inSeconds > 0;
  }

  /// Check if auction has ended
  bool get hasEnded {
    return DateTime.now().isAfter(endTime) || status == AuctionStatus.ended;
  }

  /// Check if auction is active
  bool get isActive {
    return status == AuctionStatus.active && !hasEnded;
  }

  /// Next minimum bid amount
  double get nextMinimumBid => currentPrice + minBidIncrement;

  /// Main image
  String get mainImage => images.isNotEmpty ? images.first : '';
}
