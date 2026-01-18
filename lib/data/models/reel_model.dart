/// Reel Model
class ReelModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String auctionId;
  final String auctionTitle;
  final double auctionPrice;
  final String? auctionStatus;
  final String? auctionImage;
  final String videoUrl;
  final String? thumbnailUrl;
  final int duration;
  final String? caption;
  final int likesCount;
  final int viewsCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final DateTime createdAt;

  ReelModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.auctionId,
    required this.auctionTitle,
    required this.auctionPrice,
    this.auctionStatus,
    this.auctionImage,
    required this.videoUrl,
    this.thumbnailUrl,
    this.duration = 0,
    this.caption,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    // Parse auction_price which may come as String from MySQL
    double parsePrice(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }
    
    return ReelModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? 'مستخدم',
      userAvatar: json['user_avatar'],
      auctionId: json['auction_id'] ?? '',
      auctionTitle: json['auction_title'] ?? '',
      auctionPrice: parsePrice(json['auction_price']),
      auctionStatus: json['auction_status'],
      auctionImage: json['auction_image'],
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      duration: json['duration'] ?? 0,
      caption: json['caption'],
      likesCount: json['likes_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      isLiked: json['is_liked'] == true || json['is_liked'] == 1,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'auction_id': auctionId,
      'auction_title': auctionTitle,
      'auction_price': auctionPrice,
      'auction_status': auctionStatus,
      'auction_image': auctionImage,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'caption': caption,
      'likes_count': likesCount,
      'views_count': viewsCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ReelModel copyWith({
    int? likesCount,
    int? viewsCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return ReelModel(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      auctionId: auctionId,
      auctionTitle: auctionTitle,
      auctionPrice: auctionPrice,
      auctionStatus: auctionStatus,
      auctionImage: auctionImage,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
      caption: caption,
      likesCount: likesCount ?? this.likesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }
}

/// Reel Comment Model
class ReelCommentModel {
  final String id;
  final String reelId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String comment;
  final DateTime createdAt;

  ReelCommentModel({
    required this.id,
    required this.reelId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.comment,
    required this.createdAt,
  });

  factory ReelCommentModel.fromJson(Map<String, dynamic> json) {
    return ReelCommentModel(
      id: json['id'] ?? '',
      reelId: json['reel_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? 'مستخدم',
      userAvatar: json['user_avatar'],
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}
