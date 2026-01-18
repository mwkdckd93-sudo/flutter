import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../data/services/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/category_provider.dart';

class CreateAuctionPage extends StatefulWidget {
  const CreateAuctionPage({super.key});

  @override
  State<CreateAuctionPage> createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startPriceController = TextEditingController();
  final _minIncrementController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _apiService = ApiService.instance;
  
  int _currentStep = 0;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedDuration;
  String? _selectedCondition;
  bool _hasWarranty = false;
  List<String> _selectedProvinces = [];
  
  // Images - local files and uploaded URLs
  List<File> _localImageFiles = [];
  List<String> _uploadedImageUrls = [];
  bool _isUploading = false;
  bool _isSubmitting = false;
  double _uploadProgress = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _defaultCategories = [
    {'id': 'cat-1', 'name': 'إلكترونيات', 'icon': Icons.devices, 'color': const Color(0xFF2196F3)},
    {'id': 'cat-2', 'name': 'موبايلات', 'icon': Icons.phone_iphone, 'color': const Color(0xFF9C27B0)},
    {'id': 'cat-3', 'name': 'أجهزة منزلية', 'icon': Icons.kitchen, 'color': const Color(0xFFFF9800)},
    {'id': 'cat-4', 'name': 'كيمينك', 'icon': Icons.sports_esports, 'color': const Color(0xFFE91E63)},
    {'id': 'cat-5', 'name': 'أثاث', 'icon': Icons.chair, 'color': const Color(0xFF795548)},
    {'id': 'cat-6', 'name': 'ساعات', 'icon': Icons.watch, 'color': const Color(0xFF607D8B)},
    {'id': 'cat-7', 'name': 'كاميرات', 'icon': Icons.camera_alt, 'color': const Color(0xFF00BCD4)},
    {'id': 'cat-8', 'name': 'سيارات', 'icon': Icons.directions_car, 'color': const Color(0xFF4CAF50)},
  ];

  final List<Map<String, dynamic>> _durations = [
    {'label': '1 يوم', 'value': '1', 'hours': 24, 'subtitle': 'مزاد سريع'},
    {'label': '3 أيام', 'value': '3', 'hours': 72, 'subtitle': 'قصير المدة'},
    {'label': '7 أيام', 'value': '7', 'hours': 168, 'subtitle': 'الأكثر شيوعاً'},
    {'label': '14 يوم', 'value': '14', 'hours': 336, 'subtitle': 'متوسط المدة'},
    {'label': '30 يوم', 'value': '30', 'hours': 720, 'subtitle': 'طويل المدة'},
  ];

  final Map<String, String> _conditionMapping = {
    'جديد': 'new',
    'مستعمل - ممتاز': 'like_new',
    'مستعمل - جيد': 'good',
    'مستعمل - مقبول': 'fair',
  };

  final List<String> _conditions = ['جديد', 'مستعمل - ممتاز', 'مستعمل - جيد', 'مستعمل - مقبول'];

  final List<String> _provinces = [
    'بغداد', 'البصرة', 'أربيل', 'النجف', 'كربلاء', 
    'الموصل', 'كركوك', 'السليمانية', 'دهوك', 'الأنبار',
    'ديالى', 'واسط', 'ميسان', 'ذي قار', 'المثنى', 
    'القادسية', 'بابل', 'صلاح الدين',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startPriceController.dispose();
    _minIncrementController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({bool fromCamera = false}) async {
    try {
      HapticFeedback.lightImpact();
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _localImageFiles.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      _showError('فشل في اختيار الصورة: $e');
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      HapticFeedback.lightImpact();
      
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        final remainingSlots = 5 - _localImageFiles.length;
        final filesToAdd = pickedFiles.take(remainingSlots).toList();
        
        setState(() {
          _localImageFiles.addAll(filesToAdd.map((xFile) => File(xFile.path)));
        });

        if (pickedFiles.length > remainingSlots) {
          _showError('يمكنك إضافة ${remainingSlots} صور فقط. تم تجاهل الباقي.');
        }
      }
    } catch (e) {
      _showError('فشل في اختيار الصور: $e');
    }
  }

  void _removeImage(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _localImageFiles.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'اختر مصدر الصورة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.photo_library_outlined,
                    label: 'المعرض',
                    color: const Color(0xFF1E88E5),
                    onTap: () {
                      Navigator.pop(context);
                      _pickMultipleImages();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'الكاميرا',
                    color: const Color(0xFF43A047),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(fromCamera: true);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _uploadAllImages() async {
    if (_localImageFiles.isEmpty) return true;
    if (_uploadedImageUrls.length == _localImageFiles.length) return true;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      _uploadedImageUrls.clear();
      
      for (int i = 0; i < _localImageFiles.length; i++) {
        final url = await _apiService.uploadImage(_localImageFiles[i]);
        _uploadedImageUrls.add(url);
        
        setState(() {
          _uploadProgress = (i + 1) / _localImageFiles.length;
        });
      }

      setState(() => _isUploading = false);
      return true;
    } catch (e) {
      setState(() => _isUploading = false);
      _showError('فشل في رفع الصور: $e');
      return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        HapticFeedback.lightImpact();
        setState(() => _currentStep++);
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep--);
      _animationController.reset();
      _animationController.forward();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_localImageFiles.isEmpty) {
          _showError('يرجى إضافة صورة واحدة على الأقل');
          return false;
        }
        return true;
      case 1:
        if (_titleController.text.isEmpty) {
          _showError('يرجى إدخال اسم المنتج');
          return false;
        }
        if (_selectedCategoryId == null) {
          _showError('يرجى اختيار التصنيف');
          return false;
        }
        if (_selectedCondition == null) {
          _showError('يرجى اختيار حالة المنتج');
          return false;
        }
        return true;
      case 2:
        if (_startPriceController.text.isEmpty) {
          _showError('يرجى إدخال سعر البداية');
          return false;
        }
        if (_selectedDuration == null) {
          _showError('يرجى اختيار مدة المزاد');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submitAuction() async {
    HapticFeedback.mediumImpact();
    
    setState(() => _isSubmitting = true);

    try {
      // First upload images
      final uploadSuccess = await _uploadAllImages();
      if (!uploadSuccess) {
        setState(() => _isSubmitting = false);
        return;
      }

      // Get duration hours
      final durationData = _durations.firstWhere(
        (d) => d['value'] == _selectedDuration,
        orElse: () => _durations[2], // default 7 days
      );
      final durationHours = durationData['hours'] as int;

      // Get condition value
      final conditionValue = _conditionMapping[_selectedCondition] ?? 'good';

      // Prepare warranty data
      final warranty = {
        'hasWarranty': _hasWarranty,
        if (_hasWarranty) 'durationMonths': 12,
      };

      // Create auction
      await _apiService.createAuction(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        condition: conditionValue,
        warranty: warranty,
        images: _uploadedImageUrls,
        startingPrice: double.parse(_startPriceController.text),
        minBidIncrement: _minIncrementController.text.isEmpty 
            ? 5000 
            : double.parse(_minIncrementController.text),
        durationHours: durationHours,
        shippingProvinces: _selectedProvinces,
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _SuccessDialog(
            onClose: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showError('فشل في إنشاء المزاد: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildCurrentStep(),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final stepTitles = ['الصور', 'التفاصيل', 'التسعير', 'المراجعة'];
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_currentStep > 0) {
                _previousStep();
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              padding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إضافة منتج جديد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'الخطوة ${_currentStep + 1} من 4: ${stepTitles[_currentStep]}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: isCompleted || isCurrent
                          ? const LinearGradient(
                              colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                            )
                          : null,
                      color: isCompleted || isCurrent ? null : Colors.grey.shade200,
                    ),
                  ),
                ),
                if (index < 3) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildImagesStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildPricingStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildImagesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            icon: Icons.photo_library_outlined,
            title: 'صور المنتج',
            subtitle: 'أضف صور واضحة وعالية الجودة (حد أقصى 5 صور)',
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Main image area
                GestureDetector(
                  onTap: _localImageFiles.isEmpty ? _showImageSourceDialog : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _localImageFiles.isEmpty ? Colors.grey.shade50 : null,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _localImageFiles.isEmpty ? Colors.grey.shade300 : Colors.transparent,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      image: _localImageFiles.isNotEmpty
                          ? DecorationImage(
                              image: FileImage(_localImageFiles[0]),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _localImageFiles.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 40,
                                  color: Color(0xFF1E88E5),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'اضغط لإضافة الصورة الرئيسية',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E88E5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'JPG, PNG حتى 10 ميجابايت',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E88E5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'الصورة الرئيسية',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: GestureDetector(
                                  onTap: () => _removeImage(0),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade500,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Additional images
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_localImageFiles.length < 5)
                        _buildAddImageButton(),
                      ..._localImageFiles.skip(1).toList().asMap().entries.map((entry) {
                        return _buildThumbnailImage(entry.key + 1);
                      }),
                    ],
                  ),
                ),
                // Upload progress
                if (_isUploading) ...[
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF1E88E5)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'جاري رفع الصور... ${(_uploadProgress * 100).toInt()}%',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTipsCard([
            'استخدم إضاءة طبيعية جيدة',
            'صوّر المنتج من زوايا مختلفة',
            'أظهر أي عيوب أو خدوش بوضوح',
            'تجنب استخدام صور من الإنترنت',
          ]),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey.shade600, size: 28),
            const SizedBox(height: 2),
            Text(
              'إضافة',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(int index) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(left: 10),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(_localImageFiles[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              icon: Icons.edit_note,
              title: 'معلومات المنتج',
              subtitle: 'أدخل تفاصيل المنتج بدقة',
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: _titleController,
                    label: 'اسم المنتج',
                    hint: 'مثال: iPhone 15 Pro Max 256GB',
                    icon: Icons.label_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: _descriptionController,
                    label: 'وصف المنتج',
                    hint: 'اكتب وصفاً تفصيلياً يتضمن المواصفات والحالة...',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              icon: Icons.category_outlined,
              title: 'التصنيف',
              subtitle: 'اختر التصنيف المناسب لمنتجك',
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _defaultCategories.map((cat) {
                      final isSelected = _selectedCategoryId == cat['id'];
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedCategoryId = cat['id'];
                            _selectedCategoryName = cat['name'];
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? (cat['color'] as Color).withOpacity(0.1) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? cat['color'] as Color : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 20,
                                color: isSelected ? cat['color'] as Color : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat['name'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? cat['color'] as Color : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              icon: Icons.verified_outlined,
              title: 'حالة المنتج',
              subtitle: 'حدد حالة المنتج بدقة',
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  ...List.generate(_conditions.length, (index) {
                    final condition = _conditions[index];
                    final isSelected = _selectedCondition == condition;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCondition = condition);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E88E5).withOpacity(0.05) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              condition,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  _buildWarrantyToggle(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarrantyToggle() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _hasWarranty = !_hasWarranty);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hasWarranty ? Colors.green.withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasWarranty ? Colors.green : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _hasWarranty ? Icons.verified : Icons.verified_outlined,
              color: _hasWarranty ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ضمان على المنتج',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _hasWarranty ? Colors.green.shade700 : Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    _hasWarranty ? 'المنتج يشمل ضمان' : 'لا يوجد ضمان',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Switch(
              value: _hasWarranty,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _hasWarranty = val);
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            icon: Icons.monetization_on_outlined,
            title: 'التسعير',
            subtitle: 'حدد سعر البداية والحد الأدنى للزيادة',
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildPriceField(
                  controller: _startPriceController,
                  label: 'سعر البداية',
                  hint: '0',
                  icon: Icons.sell_outlined,
                ),
                const SizedBox(height: 20),
                _buildPriceField(
                  controller: _minIncrementController,
                  label: 'الحد الأدنى للزيادة',
                  hint: '5000',
                  icon: Icons.trending_up,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            icon: Icons.timer_outlined,
            title: 'مدة المزاد',
            subtitle: 'اختر المدة المناسبة لمزادك',
            child: Column(
              children: [
                const SizedBox(height: 16),
                ...List.generate(_durations.length, (index) {
                  final duration = _durations[index];
                  final isSelected = _selectedDuration == duration['value'];
                  final isPopular = duration['value'] == '7';
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedDuration = duration['value']);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E88E5).withOpacity(0.05) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      duration['label'] as String,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade700,
                                      ),
                                    ),
                                    if (isPopular) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'الأكثر شيوعاً',
                                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  duration['subtitle'] as String,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            icon: Icons.local_shipping_outlined,
            title: 'مناطق الشحن',
            subtitle: 'اختر المحافظات التي يمكنك الشحن إليها',
            child: Column(
              children: [
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _provinces.map((province) {
                    final isSelected = _selectedProvinces.contains(province);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (isSelected) {
                            _selectedProvinces.remove(province);
                          } else {
                            _selectedProvinces.add(province);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          province,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Preview
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _localImageFiles.isNotEmpty
                      ? Image.file(
                          _localImageFiles[0],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleController.text.isEmpty ? 'اسم المنتج' : _titleController.text,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (_selectedCategoryName != null) _buildReviewTag(_selectedCategoryName!, Colors.blue),
                          if (_selectedCondition != null) _buildReviewTag(_selectedCondition!, Colors.orange),
                          if (_hasWarranty) _buildReviewTag('ضمان', Colors.green),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildReviewInfoItem(
                              'سعر البداية',
                              '${_startPriceController.text.isEmpty ? '0' : _startPriceController.text} د.ع',
                              Icons.sell_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildReviewInfoItem(
                              'مدة المزاد',
                              _selectedDuration != null ? '$_selectedDuration يوم' : '-',
                              Icons.timer_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildReviewSection('الوصف', _descriptionController.text.isEmpty ? 'لا يوجد وصف' : _descriptionController.text),
          const SizedBox(height: 16),
          _buildReviewSection(
            'مناطق الشحن',
            _selectedProvinces.isEmpty ? 'لم يتم تحديد مناطق' : _selectedProvinces.join('، '),
          ),
          const SizedBox(height: 16),
          _buildReviewSection(
            'عدد الصور',
            '${_localImageFiles.length} صور',
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildReviewTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildReviewInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('السابق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: (_isSubmitting || _isUploading) 
                    ? null 
                    : (_currentStep == 3 ? _submitAuction : _nextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentStep == 3 ? Colors.green : const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting || _isUploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 3 ? 'نشر المنتج' : 'التالي',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Icon(_currentStep == 3 ? Icons.publish : Icons.arrow_forward, size: 20),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF1E88E5), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildTipsCard(List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'نصائح للصور المثالية',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Expanded(child: Text(tip, style: TextStyle(fontSize: 13, color: Colors.amber.shade900))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade700),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        suffixText: 'د.ع',
        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  final VoidCallback onClose;

  const _SuccessDialog({required this.onClose});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 64),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'تم إضافة المنتج بنجاح! 🎉',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'سيتم مراجعة منتجك من قبل فريقنا ونشره قريباً',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('حسناً', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
