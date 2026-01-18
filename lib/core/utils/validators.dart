/// Validation utilities
class Validators {
  Validators._();

  /// Validate Iraqi phone number
  static String? validateIraqiPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    // Remove any formatting
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Iraqi phone patterns: 07XX XXX XXXX
    final iraqiPattern = RegExp(r'^(07[3-9]\d{8}|964[3-9]\d{9})$');

    if (!iraqiPattern.hasMatch(cleaned)) {
      return 'رقم الهاتف غير صالح';
    }

    return null;
  }

  /// Validate full name
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم الكامل مطلوب';
    }

    if (value.trim().length < 3) {
      return 'الاسم قصير جداً';
    }

    if (!value.contains(' ')) {
      return 'يرجى إدخال الاسم الكامل';
    }

    return null;
  }

  /// Validate price
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'السعر مطلوب';
    }

    final price = double.tryParse(value.replaceAll(',', ''));
    if (price == null || price <= 0) {
      return 'السعر غير صالح';
    }

    if (price < 1000) {
      return 'الحد الأدنى للسعر 1,000 د.ع';
    }

    return null;
  }

  /// Validate bid increment
  static String? validateBidIncrement(String? value, double currentPrice) {
    if (value == null || value.isEmpty) {
      return 'مبلغ الزيادة مطلوب';
    }

    final increment = double.tryParse(value.replaceAll(',', ''));
    if (increment == null || increment <= 0) {
      return 'المبلغ غير صالح';
    }

    // Minimum increment is 5% of current price or 1000 IQD, whichever is higher
    final minIncrement = (currentPrice * 0.05).clamp(1000, double.infinity);
    if (increment < minIncrement) {
      return 'الحد الأدنى للزيادة ${minIncrement.toInt()} د.ع';
    }

    return null;
  }

  /// Validate max auto-bid
  static String? validateMaxAutoBid(String? value, double currentPrice, double minIncrement) {
    if (value == null || value.isEmpty) {
      return 'الحد الأقصى للمزايدة التلقائية مطلوب';
    }

    final maxBid = double.tryParse(value.replaceAll(',', ''));
    if (maxBid == null || maxBid <= 0) {
      return 'المبلغ غير صالح';
    }

    final minimumRequired = currentPrice + minIncrement;
    if (maxBid < minimumRequired) {
      return 'يجب أن يكون أكبر من ${minimumRequired.toInt()} د.ع';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  /// Validate address landmark
  static String? validateLandmark(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال أقرب نقطة دالة';
    }

    if (value.trim().length < 10) {
      return 'يرجى إدخال وصف أكثر تفصيلاً';
    }

    return null;
  }
}
