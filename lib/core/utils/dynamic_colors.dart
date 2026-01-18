import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Dynamic colors helper for theme-aware colors
class DynamicColors {
  /// Get card background color based on theme
  static Color cardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.cardDark : Colors.white;
  }

  /// Get surface color based on theme
  static Color surface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.surfaceDark : AppColors.surface;
  }

  /// Get surface variant color based on theme
  static Color surfaceVariant(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;
  }

  /// Get background color based on theme
  static Color background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.backgroundDark : AppColors.background;
  }

  /// Get primary text color based on theme
  static Color textPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
  }

  /// Get secondary text color based on theme
  static Color textSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
  }

  /// Get hint text color based on theme
  static Color textHint(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.textHintDark : AppColors.textHint;
  }

  /// Get border color based on theme
  static Color border(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.borderDark : AppColors.border;
  }

  /// Get divider color based on theme
  static Color divider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.dividerDark : AppColors.divider;
  }

  /// Get shimmer base color based on theme
  static Color shimmerBase(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase;
  }

  /// Get shimmer highlight color based on theme
  static Color shimmerHighlight(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlight;
  }

  /// Get dark header background gradient colors
  static List<Color> headerGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark 
        ? [AppColors.surfaceDark, AppColors.backgroundDark, const Color(0xFF0a0a0f)]
        : [const Color(0xFF1a1a2e), const Color(0xFF16213e), const Color(0xFF0f0f1a)];
  }

  /// Get primary color based on theme
  static Color primary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.primaryDarkTheme : AppColors.primary;
  }

  /// Get accent/secondary color
  static Color accent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.secondaryDarkTheme : AppColors.secondary;
  }

  /// Check if current theme is dark
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get shadow color based on theme
  static Color shadow(BuildContext context, {double opacity = 0.1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Colors.black.withOpacity(isDark ? opacity * 3 : opacity);
  }

  /// Get icon color based on theme
  static Color icon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
  }

  /// Get error color based on theme
  static Color error(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.errorDark : AppColors.error;
  }

  /// Get success color based on theme
  static Color success(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.successDark : AppColors.success;
  }

  /// Get warning color based on theme
  static Color warning(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.warningDark : AppColors.warning;
  }
}
