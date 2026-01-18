import 'package:flutter/foundation.dart';
import '../data/services/services.dart';

/// Notification Provider - manages notifications
class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnread => _unreadCount > 0;

  NotificationProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  /// Load notifications
  Future<void> loadNotifications({bool unreadOnly = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getNotifications();
      _notifications = data;
      _unreadCount = data.where((n) => n['is_read'] != true).length;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في تحميل الإشعارات';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get unread count only
  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _apiService.getUnreadNotificationCount();
      notifyListeners();
    } catch (e) {
      // Handle silently
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.markNotificationRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1 && _notifications[index]['is_read'] != true) {
        _notifications[index]['is_read'] = true;
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
        notifyListeners();
      }
    } catch (e) {
      // Handle silently
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _apiService.markAllNotificationsRead();
      
      // Update local state
      for (var notification in _notifications) {
        notification['is_read'] = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في تحديد الإشعارات كمقروءة';
      notifyListeners();
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiService.deleteNotification(notificationId);
      
      // Update local state
      final notification = _notifications.firstWhere(
        (n) => n['id'] == notificationId,
        orElse: () => {},
      );
      if (notification.isNotEmpty && notification['is_read'] != true) {
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      }
      _notifications.removeWhere((n) => n['id'] == notificationId);
      notifyListeners();
    } catch (e) {
      _error = 'فشل في حذف الإشعار';
      notifyListeners();
    }
  }

  /// Handle real-time notification
  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  /// Get notification icon based on type
  String getNotificationIcon(String type) {
    switch (type) {
      case 'bid':
        return '💰';
      case 'outbid':
        return '⚠️';
      case 'won':
        return '🏆';
      case 'question':
        return '❓';
      case 'answer':
        return '💬';
      case 'delivery':
        return '📦';
      case 'system':
        return '📢';
      default:
        return '🔔';
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
