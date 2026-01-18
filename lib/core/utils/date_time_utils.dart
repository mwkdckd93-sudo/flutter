/// Date/Time formatting utilities
class DateTimeUtils {
  DateTimeUtils._();

  /// Format duration as HH:MM:SS
  static String formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return '${days}d ${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
    }

    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  /// Format duration for countdown display
  static String formatCountdown(Duration duration) {
    if (duration.isNegative) return 'انتهى';

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return '$days يوم ${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
    } else if (hours > 0) {
      return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
    } else {
      return '${_twoDigits(minutes)}:${_twoDigits(seconds)}';
    }
  }

  /// Get countdown parts for individual display
  static Map<String, int> getCountdownParts(Duration duration) {
    if (duration.isNegative) {
      return {'days': 0, 'hours': 0, 'minutes': 0, 'seconds': 0};
    }

    return {
      'days': duration.inDays,
      'hours': duration.inHours.remainder(24),
      'minutes': duration.inMinutes.remainder(60),
      'seconds': duration.inSeconds.remainder(60),
    };
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// Format date in Arabic
  static String formatDateArabic(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format time in Arabic
  static String formatTimeArabic(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '${_twoDigits(hour)}:${_twoDigits(time.minute)} $period';
  }

  /// Get relative time in Arabic
  static String getRelativeTimeArabic(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return mins == 1 ? 'منذ دقيقة' : 'منذ $mins دقائق';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours == 1 ? 'منذ ساعة' : 'منذ $hours ساعات';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return days == 1 ? 'منذ يوم' : 'منذ $days أيام';
    } else {
      return formatDateArabic(dateTime);
    }
  }
}
