import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_time_utils.dart';

/// Real-time Countdown Timer Widget
class CountdownTimerWidget extends StatelessWidget {
  final Duration duration;
  final bool isCompact;
  final bool showWarning;

  const CountdownTimerWidget({
    super.key,
    required this.duration,
    this.isCompact = false,
    this.showWarning = true,
  });

  @override
  Widget build(BuildContext context) {
    final parts = DateTimeUtils.getCountdownParts(duration);
    final isEnding = duration.inMinutes <= 5 && duration.inSeconds > 0;
    final hasEnded = duration <= Duration.zero;

    if (hasEnded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.auctionEnded.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'انتهى المزاد',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.auctionEnded,
          ),
        ),
      );
    }

    if (isCompact) {
      return _buildCompactTimer(parts, isEnding);
    }

    return _buildFullTimer(parts, isEnding);
  }

  Widget _buildCompactTimer(Map<String, int> parts, bool isEnding) {
    final timerText = parts['days']! > 0
        ? '${parts['days']}d ${_format(parts['hours']!)}:${_format(parts['minutes']!)}:${_format(parts['seconds']!)}'
        : '${_format(parts['hours']!)}:${_format(parts['minutes']!)}:${_format(parts['seconds']!)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEnding ? AppColors.error.withValues(alpha: 0.1) : AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 14,
            color: isEnding ? AppColors.error : AppColors.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            timerText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: isEnding ? AppColors.error : AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTimer(Map<String, int> parts, bool isEnding) {
    return Column(
      children: [
        if (showWarning && isEnding)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.secondaryDark, size: 18),
                SizedBox(width: 8),
                Text(
                  'المزاد على وشك الانتهاء!',
                  style: TextStyle(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnding
                  ? [AppColors.error.withValues(alpha: 0.1), AppColors.error.withValues(alpha: 0.05)]
                  : [AppColors.primary.withValues(alpha: 0.1), AppColors.primary.withValues(alpha: 0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEnding ? AppColors.error.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (parts['days']! > 0) ...[
                _buildTimeBlock(parts['days']!.toString(), 'يوم', isEnding),
                _buildSeparator(isEnding),
              ],
              _buildTimeBlock(_format(parts['hours']!), 'ساعة', isEnding),
              _buildSeparator(isEnding),
              _buildTimeBlock(_format(parts['minutes']!), 'دقيقة', isEnding),
              _buildSeparator(isEnding),
              _buildTimeBlock(_format(parts['seconds']!), 'ثانية', isEnding),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBlock(String value, String label, bool isEnding) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isEnding ? AppColors.error : AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isEnding ? AppColors.error : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(bool isEnding) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isEnding ? AppColors.error : AppColors.primary,
        ),
      ),
    );
  }

  String _format(int value) => value.toString().padLeft(2, '0');
}
