import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/models/reel_model.dart';
import '../data/services/reels_service.dart';

/// Reels Provider - Manages reels state
class ReelsProvider extends ChangeNotifier {
  final ReelsService _reelsService;

  List<ReelModel> _reels = [];
  List<ReelCommentModel> _comments = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  int _currentIndex = 0;

  // Upload state
  bool _isUploading = false;
  double _uploadProgress = 0;

  // Getters
  List<ReelModel> get reels => _reels;
  List<ReelCommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get currentIndex => _currentIndex;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;

  ReelModel? get currentReel => 
      _reels.isNotEmpty && _currentIndex < _reels.length 
          ? _reels[_currentIndex] 
          : null;

  ReelsProvider({ReelsService? reelsService})
      : _reelsService = reelsService ?? ReelsService.instance;

  /// Load initial reels
  Future<void> loadReels({String? auctionId, String? userId, bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newReels = await _reelsService.getReels(
        page: _currentPage,
        auctionId: auctionId,
        userId: userId,
      );

      if (refresh) {
        _reels = newReels;
      } else {
        _reels = [..._reels, ...newReels];
      }

      _hasMore = newReels.length >= 10;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
      print('Error loading reels: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more reels
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newReels = await _reelsService.getReels(page: _currentPage);
      
      _reels = [..._reels, ...newReels];
      _hasMore = newReels.length >= 10;
      _currentPage++;
    } catch (e) {
      print('Error loading more reels: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Set current reel index
  void setCurrentIndex(int index) {
    if (index != _currentIndex && index >= 0 && index < _reels.length) {
      _currentIndex = index;
      notifyListeners();

      // Track view
      _reelsService.addView(_reels[index].id);

      // Preload more if near end
      if (index >= _reels.length - 3 && _hasMore) {
        loadMore();
      }
    }
  }

  /// Toggle like
  Future<void> toggleLike(String reelId) async {
    final index = _reels.indexWhere((r) => r.id == reelId);
    if (index == -1) return;

    final reel = _reels[index];
    
    // Optimistic update
    _reels[index] = reel.copyWith(
      isLiked: !reel.isLiked,
      likesCount: reel.isLiked ? reel.likesCount - 1 : reel.likesCount + 1,
    );
    notifyListeners();

    try {
      final isLiked = await _reelsService.toggleLike(reelId);
      
      // Verify server response matches
      if (isLiked != _reels[index].isLiked) {
        _reels[index] = _reels[index].copyWith(
          isLiked: isLiked,
          likesCount: isLiked ? reel.likesCount + 1 : reel.likesCount,
        );
        notifyListeners();
      }
    } catch (e) {
      // Revert on error
      _reels[index] = reel;
      notifyListeners();
    }
  }

  /// Load comments
  Future<void> loadComments(String reelId) async {
    try {
      _comments = await _reelsService.getComments(reelId);
      notifyListeners();
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  /// Add comment
  Future<void> addComment(String reelId, String comment) async {
    try {
      final newComment = await _reelsService.addComment(reelId, comment);
      _comments = [newComment, ..._comments];
      
      // Update comments count
      final index = _reels.indexWhere((r) => r.id == reelId);
      if (index != -1) {
        _reels[index] = _reels[index].copyWith(
          commentsCount: _reels[index].commentsCount + 1,
        );
      }
      
      notifyListeners();
    } catch (e) {
      throw Exception('فشل في إضافة التعليق');
    }
  }

  /// Upload new reel
  Future<String?> uploadReel({
    required File videoFile,
    required String auctionId,
    String? caption,
    int? duration,
  }) async {
    _isUploading = true;
    _uploadProgress = 0;
    notifyListeners();

    try {
      final reelId = await _reelsService.uploadReel(
        videoFile: videoFile,
        auctionId: auctionId,
        caption: caption,
        duration: duration,
        onProgress: (sent, total) {
          _uploadProgress = sent / total;
          notifyListeners();
        },
      );

      // Refresh reels
      await loadReels(refresh: true);

      return reelId;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isUploading = false;
      _uploadProgress = 0;
      notifyListeners();
    }
  }

  /// Delete reel
  Future<bool> deleteReel(String reelId) async {
    try {
      await _reelsService.deleteReel(reelId);
      _reels.removeWhere((r) => r.id == reelId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear comments
  void clearComments() {
    _comments = [];
    notifyListeners();
  }
}
