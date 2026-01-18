import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/reel_model.dart';
import 'api_service.dart';

/// Reels Service for video content
class ReelsService {
  static ReelsService? _instance;
  late final Dio _dio;

  ReelsService._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Get token from ApiService
        final token = ApiService.instance.authToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  static ReelsService get instance {
    _instance ??= ReelsService._();
    return _instance!;
  }

  /// Get base URL for media
  String get _mediaBaseUrl {
    final url = AppConstants.baseUrl;
    if (url.endsWith('/api')) {
      return url.substring(0, url.length - 4);
    }
    return url;
  }

  /// Get reels feed
  Future<List<ReelModel>> getReels({int page = 1, int limit = 10, String? auctionId, String? userId}) async {
    final response = await _dio.get('/reels', queryParameters: {
      'page': page,
      'limit': limit,
      if (auctionId != null) 'auctionId': auctionId,
      if (userId != null) 'userId': userId,
    });

    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) {
        // Add base URL to video/thumbnail URLs
        if (json['video_url'] != null && !json['video_url'].startsWith('http')) {
          json['video_url'] = '$_mediaBaseUrl${json['video_url']}';
        }
        if (json['thumbnail_url'] != null && !json['thumbnail_url'].startsWith('http')) {
          json['thumbnail_url'] = '$_mediaBaseUrl${json['thumbnail_url']}';
        }
        return ReelModel.fromJson(json);
      }).toList();
    }
    throw Exception(response.data['message'] ?? 'فشل في جلب الريلز');
  }

  /// Get single reel
  Future<ReelModel> getReel(String id) async {
    final response = await _dio.get('/reels/$id');

    if (response.data['success'] == true) {
      final json = response.data['data'];
      if (json['video_url'] != null && !json['video_url'].startsWith('http')) {
        json['video_url'] = '$_mediaBaseUrl${json['video_url']}';
      }
      if (json['thumbnail_url'] != null && !json['thumbnail_url'].startsWith('http')) {
        json['thumbnail_url'] = '$_mediaBaseUrl${json['thumbnail_url']}';
      }
      return ReelModel.fromJson(json);
    }
    throw Exception(response.data['message'] ?? 'الريل غير موجود');
  }

  /// Upload a new reel
  Future<String> uploadReel({
    required File videoFile,
    required String auctionId,
    String? caption,
    int? duration,
    Function(int, int)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'video': await MultipartFile.fromFile(
        videoFile.path,
        filename: videoFile.path.split('/').last,
      ),
      'auctionId': auctionId,
      if (caption != null) 'caption': caption,
      if (duration != null) 'duration': duration,
    });

    final response = await _dio.post(
      '/reels',
      data: formData,
      onSendProgress: onProgress,
    );

    if (response.data['success'] == true) {
      return response.data['data']['id'];
    }
    throw Exception(response.data['message'] ?? 'فشل في رفع الريل');
  }

  /// Upload thumbnail
  Future<String> uploadThumbnail(String reelId, File thumbnailFile) async {
    final formData = FormData.fromMap({
      'thumbnail': await MultipartFile.fromFile(
        thumbnailFile.path,
        filename: thumbnailFile.path.split('/').last,
      ),
    });

    final response = await _dio.post('/reels/$reelId/thumbnail', data: formData);

    if (response.data['success'] == true) {
      return '$_mediaBaseUrl${response.data['data']['thumbnail_url']}';
    }
    throw Exception(response.data['message'] ?? 'فشل في رفع الصورة المصغرة');
  }

  /// Like/Unlike reel
  Future<bool> toggleLike(String reelId) async {
    final response = await _dio.post('/reels/$reelId/like');

    if (response.data['success'] == true) {
      return response.data['liked'] == true;
    }
    throw Exception(response.data['message'] ?? 'فشل في تحديث الإعجاب');
  }

  /// Add view
  Future<void> addView(String reelId) async {
    try {
      await _dio.post('/reels/$reelId/view');
    } catch (e) {
      // Ignore view tracking errors
    }
  }

  /// Get comments
  Future<List<ReelCommentModel>> getComments(String reelId, {int page = 1}) async {
    final response = await _dio.get('/reels/$reelId/comments', queryParameters: {
      'page': page,
    });

    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ReelCommentModel.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'فشل في جلب التعليقات');
  }

  /// Add comment
  Future<ReelCommentModel> addComment(String reelId, String comment) async {
    final response = await _dio.post('/reels/$reelId/comments', data: {
      'comment': comment,
    });

    if (response.data['success'] == true) {
      return ReelCommentModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'فشل في إضافة التعليق');
  }

  /// Delete reel
  Future<void> deleteReel(String reelId) async {
    final response = await _dio.delete('/reels/$reelId');

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل في حذف الريل');
    }
  }

  /// Get user's reels
  Future<List<ReelModel>> getUserReels(String userId, {int page = 1}) async {
    final response = await _dio.get('/reels/user/$userId', queryParameters: {
      'page': page,
    });

    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) {
        if (json['video_url'] != null && !json['video_url'].startsWith('http')) {
          json['video_url'] = '$_mediaBaseUrl${json['video_url']}';
        }
        if (json['thumbnail_url'] != null && !json['thumbnail_url'].startsWith('http')) {
          json['thumbnail_url'] = '$_mediaBaseUrl${json['thumbnail_url']}';
        }
        return ReelModel.fromJson(json);
      }).toList();
    }
    throw Exception(response.data['message'] ?? 'فشل في جلب ريلز المستخدم');
  }
}
