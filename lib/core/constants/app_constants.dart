/// App-wide constants
class AppConstants {
  AppConstants._();

  // API Configuration
  static const String baseUrl = 'https://api.hajja.app/api';
  static const String socketUrl = 'https://api.hajja.app';

  // Auction Settings
  static const int antiSnipingThresholdMinutes = 5;
  static const int antiSnipingExtensionMinutes = 2;
  static const int maxQuestionsPerUser = 2;

  // Pagination
  static const int defaultPageSize = 20;

  // Image Settings
  static const int maxProductImages = 10;
  static const int imageQuality = 85;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 24);
}

/// Iraqi Provinces
class IraqiProvinces {
  IraqiProvinces._();

  static const List<String> provinces = [
    'بغداد',
    'البصرة',
    'نينوى',
    'أربيل',
    'النجف',
    'كربلاء',
    'السليمانية',
    'ذي قار',
    'الأنبار',
    'ديالى',
    'كركوك',
    'صلاح الدين',
    'بابل',
    'دهوك',
    'واسط',
    'ميسان',
    'المثنى',
    'القادسية',
  ];

  static const Map<String, String> provincesEn = {
    'بغداد': 'Baghdad',
    'البصرة': 'Basra',
    'نينوى': 'Nineveh',
    'أربيل': 'Erbil',
    'النجف': 'Najaf',
    'كربلاء': 'Karbala',
    'السليمانية': 'Sulaymaniyah',
    'ذي قار': 'Dhi Qar',
    'الأنبار': 'Anbar',
    'ديالى': 'Diyala',
    'كركوك': 'Kirkuk',
    'صلاح الدين': 'Saladin',
    'بابل': 'Babylon',
    'دهوك': 'Duhok',
    'واسط': 'Wasit',
    'ميسان': 'Maysan',
    'المثنى': 'Muthanna',
    'القادسية': 'Qadisiyyah',
  };
}

/// Product Categories
class ProductCategories {
  ProductCategories._();

  static const List<Map<String, String>> categories = [
    {'id': 'electronics', 'name_ar': 'إلكترونيات', 'name_en': 'Electronics', 'icon': '📱'},
    {'id': 'fashion', 'name_ar': 'أزياء', 'name_en': 'Fashion', 'icon': '👔'},
    {'id': 'home', 'name_ar': 'المنزل والحديقة', 'name_en': 'Home & Garden', 'icon': '🏠'},
    {'id': 'sports', 'name_ar': 'رياضة', 'name_en': 'Sports', 'icon': '⚽'},
    {'id': 'collectibles', 'name_ar': 'مقتنيات', 'name_en': 'Collectibles', 'icon': '🏆'},
    {'id': 'jewelry', 'name_ar': 'مجوهرات', 'name_en': 'Jewelry', 'icon': '💎'},
    {'id': 'art', 'name_ar': 'فن', 'name_en': 'Art', 'icon': '🎨'},
    {'id': 'books', 'name_ar': 'كتب', 'name_en': 'Books', 'icon': '📚'},
    {'id': 'toys', 'name_ar': 'ألعاب', 'name_en': 'Toys', 'icon': '🎮'},
    {'id': 'antiques', 'name_ar': 'تحف', 'name_en': 'Antiques', 'icon': '🏺'},
    {'id': 'other', 'name_ar': 'أخرى', 'name_en': 'Other', 'icon': '📦'},
  ];
}
