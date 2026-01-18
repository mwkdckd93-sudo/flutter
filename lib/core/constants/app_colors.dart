import 'package:flutter/material.dart';

/// App Color Palette - Material Design 3
class AppColors {
  AppColors._();

  // ============ LIGHT THEME COLORS ============

  // Primary Colors
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1565C0);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6F00);
  static const Color secondaryLight = Color(0xFFFFAB40);
  static const Color secondaryDark = Color(0xFFE65100);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFBBDEFB);

  // Neutral Colors - Light
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);

  // Text Colors - Light
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Auction Status Colors
  static const Color auctionActive = Color(0xFF4CAF50);
  static const Color auctionEnding = Color(0xFFFF9800);
  static const Color auctionEnded = Color(0xFF9E9E9E);

  // Bid Status Colors
  static const Color bidWinning = Color(0xFF4CAF50);
  static const Color bidOutbid = Color(0xFFE53935);

  // Divider & Border - Light
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);

  // Shimmer Colors - Light
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ============ DARK THEME COLORS ============

  // Dark Primary Colors (slightly brighter for dark backgrounds)
  static const Color primaryDarkTheme = Color(0xFF42A5F5);
  static const Color primaryLightDarkTheme = Color(0xFF90CAF9);
  static const Color primaryDarkDarkTheme = Color(0xFF1E88E5);

  // Dark Secondary Colors
  static const Color secondaryDarkTheme = Color(0xFFFFB74D);
  static const Color secondaryLightDarkTheme = Color(0xFFFFCC80);

  // Dark Background Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  static const Color surfaceElevatedDark = Color(0xFF2D2D2D);

  // Dark Text Colors
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textHintDark = Color(0xFF6E6E6E);
  static const Color textOnPrimaryDark = Color(0xFF000000);

  // Dark Divider & Border
  static const Color dividerDark = Color(0xFF3D3D3D);
  static const Color borderDark = Color(0xFF4A4A4A);

  // Dark Shimmer Colors
  static const Color shimmerBaseDark = Color(0xFF2A2A2A);
  static const Color shimmerHighlightDark = Color(0xFF3D3D3D);

  // Dark Card Colors
  static const Color cardDark = Color(0xFF252525);
  static const Color cardElevatedDark = Color(0xFF2F2F2F);

  // Dark Status Colors (brighter for visibility)
  static const Color successDark = Color(0xFF66BB6A);
  static const Color warningDark = Color(0xFFFFCA28);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color infoDark = Color(0xFF42A5F5);
}

