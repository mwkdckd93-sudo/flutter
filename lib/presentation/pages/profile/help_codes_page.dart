import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/services/api_service.dart';
import '../../../core/utils/currency_utils.dart';

class HelpCodesPage extends StatefulWidget {
  const HelpCodesPage({super.key});

  @override
  State<HelpCodesPage> createState() => _HelpCodesPageState();
}

class _HelpCodesPageState extends State<HelpCodesPage> {
  List<HelpCodeModel> _helpCodes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHelpCodes();
  }

  Future<void> _loadHelpCodes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final helpCodesData = await ApiService.instance.getHelpCodes();
      if (mounted) {
        setState(() {
          _helpCodes = helpCodesData.map((data) => HelpCodeModel.fromJson(data)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('تم نسخ رقم الطلب: $code'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareCode(String code, String auctionTitle) {
    final message = '''🎫 رقم طلب المساعدة: $code
📦 المنتج: $auctionTitle

للاستفسار أو المساعدة، أرسل هذا الرقم للدعم الفني عبر واتساب''';

    // Use share_plus or similar
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الرسالة - يمكنك لصقها في واتساب'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        foregroundColor: Colors.white,
        title: const Text('أرقام طلباتي'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _helpCodes.isEmpty
                  ? _buildEmptyWidget()
                  : RefreshIndicator(
                      onRefresh: _loadHelpCodes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _helpCodes.length,
                        itemBuilder: (context, index) {
                          return _buildHelpCodeCard(_helpCodes[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد أرقام طلبات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'عند فوزك بمزاد، سيظهر رقم الطلب هنا',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يمكنك استخدامه للتواصل مع الدعم',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadHelpCodes,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCodeCard(HelpCodeModel helpCode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // رأس البطاقة مع الصورة والعنوان
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // صورة المنتج
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: helpCode.auction.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: helpCode.auction.imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                // معلومات المنتج
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        helpCode.auction.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyUtils.formatIQD(helpCode.auction.price),
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.store, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            helpCode.seller.name,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
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
          
          // خط فاصل
          Divider(height: 1, color: Colors.grey.shade200),
          
          // رقم الطلب
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_number, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'رقم الطلب للمساعدة',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(helpCode.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(helpCode.status),
                        style: TextStyle(
                          color: _getStatusColor(helpCode.status),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // رقم الكود الكبير
                GestureDetector(
                  onTap: () => _copyToClipboard(helpCode.helpCode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          helpCode.helpCode,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                            color: Color(0xFF1a1a2e),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.copy, color: Colors.blue, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // أزرار الإجراءات
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareCode(helpCode.helpCode, helpCode.auction.title),
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('مشاركة'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(helpCode.helpCode),
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('نسخ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'used':
        return Colors.orange;
      case 'expired':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'used':
        return 'مستخدم';
      case 'expired':
        return 'منتهي';
      default:
        return status;
    }
  }
}

// نموذج البيانات
class HelpCodeModel {
  final String id;
  final String helpCode;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final AuctionInfo auction;
  final SellerInfo seller;

  HelpCodeModel({
    required this.id,
    required this.helpCode,
    required this.type,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    required this.auction,
    required this.seller,
  });

  factory HelpCodeModel.fromJson(Map<String, dynamic> json) {
    return HelpCodeModel(
      id: json['id'] ?? '',
      helpCode: json['helpCode'] ?? '',
      type: json['type'] ?? 'winner',
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      auction: AuctionInfo.fromJson(json['auction'] ?? {}),
      seller: SellerInfo.fromJson(json['seller'] ?? {}),
    );
  }
}

class AuctionInfo {
  final String id;
  final String title;
  final double price;
  final String status;
  final String? imageUrl;

  AuctionInfo({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
    this.imageUrl,
  });

  factory AuctionInfo.fromJson(Map<String, dynamic> json) {
    return AuctionInfo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}

class SellerInfo {
  final String name;
  final String? phone;

  SellerInfo({
    required this.name,
    this.phone,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      name: json['name'] ?? '',
      phone: json['phone'],
    );
  }
}
