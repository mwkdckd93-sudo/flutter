

/// Bid Model
class BidModel {
  final String id;
  final String auctionId;
  final String bidderId;
  final String bidderName;
  final String? bidderAvatar;
  final double amount;
  final DateTime createdAt;
  final bool isAutoBid;
  final bool isWinning;

  const BidModel({
    required this.id,
    required this.auctionId,
    required this.bidderId,
    required this.bidderName,
    this.bidderAvatar,
    required this.amount,
    required this.createdAt,
    this.isAutoBid = false,
    this.isWinning = false,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    // Handle amount as either num or String
    double parseAmount(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }
    
    return BidModel(
      id: json['id']?.toString() ?? '',
      auctionId: (json['auctionId'] ?? json['auction_id'])?.toString() ?? '',
      bidderId: (json['bidderId'] ?? json['bidder_id'])?.toString() ?? '',
      bidderName: (json['bidderName'] ?? json['bidder_name'])?.toString() ?? '',
      bidderAvatar: (json['bidderAvatar'] ?? json['bidder_avatar'])?.toString(),
      amount: parseAmount(json['amount']),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : (json['created_at'] != null 
              ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
      isAutoBid: json['isAutoBid'] == true || json['is_auto_bid'] == true,
      isWinning: json['isWinning'] == true || json['is_winning'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auctionId': auctionId,
      'bidderId': bidderId,
      'bidderName': bidderName,
      'bidderAvatar': bidderAvatar,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'isAutoBid': isAutoBid,
      'isWinning': isWinning,
    };
  }

  BidModel copyWith({
    String? id,
    String? auctionId,
    String? bidderId,
    String? bidderName,
    String? bidderAvatar,
    double? amount,
    DateTime? createdAt,
    bool? isAutoBid,
    bool? isWinning,
  }) {
    return BidModel(
      id: id ?? this.id,
      auctionId: auctionId ?? this.auctionId,
      bidderId: bidderId ?? this.bidderId,
      bidderName: bidderName ?? this.bidderName,
      bidderAvatar: bidderAvatar ?? this.bidderAvatar,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      isAutoBid: isAutoBid ?? this.isAutoBid,
      isWinning: isWinning ?? this.isWinning,
    );
  }
}

/// Auto-Bid Configuration
class AutoBidConfig {
  final String auctionId;
  final double maxAmount;
  final bool isActive;

  const AutoBidConfig({
    required this.auctionId,
    required this.maxAmount,
    this.isActive = true,
  });

  factory AutoBidConfig.fromJson(Map<String, dynamic> json) {
    return AutoBidConfig(
      auctionId: json['auctionId'] as String,
      maxAmount: (json['maxAmount'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auctionId': auctionId,
      'maxAmount': maxAmount,
      'isActive': isActive,
    };
  }
}
