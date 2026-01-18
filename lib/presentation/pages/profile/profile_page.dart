import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/reels_service.dart';
import '../../../data/models/auction_model.dart';
import '../../../data/models/reel_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_utils.dart';
import '../auth/login_page.dart';
import '../auction/auction_detail_page.dart';
import '../reels/reels_page.dart';
import '../settings/theme_settings_page.dart';
import 'edit_profile_page.dart';
import 'help_codes_page.dart';
import 'settings_page.dart';
import 'wallet_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Products data
  List<AuctionModel> _myProducts = [];
  List<AuctionModel> _myBids = [];
  List<AuctionModel> _savedAuctions = [];
  List<ReelModel> _myReels = [];
  bool _isLoadingProducts = false;
  bool _isLoadingBids = false;
  bool _isLoadingSaved = false;
  bool _isLoadingReels = false;
  bool _showPhoneNumber = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _loadPhoneVisibility();
  }

  Future<void> _loadPhoneVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _showPhoneNumber = prefs.getBool('show_phone_number') ?? true;
      });
    }
  }

  Future<void> _togglePhoneVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !_showPhoneNumber;
    await prefs.setBool('show_phone_number', newValue);
    if (mounted) {
      setState(() {
        _showPhoneNumber = newValue;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _loadMyProducts();
    _loadSavedAuctions();
    _loadMyReels();
  }

  Future<void> _loadMyProducts() async {
    if (_isLoadingProducts) return;
    setState(() => _isLoadingProducts = true);
    try {
      final products = await ApiService.instance.getMyAuctions();
      if (mounted) {
        setState(() => _myProducts = products);
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _loadMyBids() async {
    if (_isLoadingBids) return;
    setState(() => _isLoadingBids = true);
    try {
      final bids = await ApiService.instance.getMyBids();
      if (mounted) {
        setState(() => _myBids = bids);
      }
    } catch (e) {
      debugPrint('Error loading bids: $e');
    } finally {
      if (mounted) setState(() => _isLoadingBids = false);
    }
  }

  Future<void> _loadSavedAuctions() async {
    if (_isLoadingSaved) return;
    setState(() => _isLoadingSaved = true);
    try {
      final saved = await ApiService.instance.getSavedAuctions();
      if (mounted) {
        setState(() => _savedAuctions = saved);
      }
    } catch (e) {
      debugPrint('Error loading saved auctions: $e');
    } finally {
      if (mounted) setState(() => _isLoadingSaved = false);
    }
  }

  Future<void> _loadMyReels() async {
    if (_isLoadingReels) return;
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    
    setState(() => _isLoadingReels = true);
    try {
      print('🎬 Loading reels for user: ${user.id}');
      final reels = await ReelsService.instance.getUserReels(user.id);
      print('🎬 Loaded ${reels.length} reels');
      if (mounted) {
        setState(() => _myReels = reels);
      }
    } catch (e) {
      print('❌ Error loading reels: $e');
      debugPrint('Error loading reels: $e');
    } finally {
      if (mounted) setState(() => _isLoadingReels = false);
    }
  }

  Future<void> _deleteReel(ReelModel reel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الريل'),
        content: const Text('هل أنت متأكد من حذف هذا الريل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ReelsService.instance.deleteReel(reel.id);
        if (mounted) {
          setState(() => _myReels.removeWhere((r) => r.id == reel.id));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الريل بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في حذف الريل: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    String baseUrl = AppConstants.baseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    return '$baseUrl$url';
  }

  String _hidePhoneNumber(String phone) {
    if (phone.length <= 4) return '****';
    return '${'*' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    // إذا لم يكن المستخدم مسجل دخول
    if (!authProvider.isLoggedIn || user == null) {
      return _buildLoginPrompt(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Modern App Bar with gradient
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f0f1a)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Row(
                      children: [
                        // User name
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (user.isVerified)
                                const Icon(Icons.verified, color: Color(0xFF00BCD4), size: 20),
                            ],
                          ),
                        ),
                        // Settings button
                        GestureDetector(
                          onTap: () => _showSettingsBottomSheet(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildProfileHeader(context, user),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF1a1a2e),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF00BCD4),
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.play_circle_outline)),
                    Tab(icon: Icon(Icons.bookmark_border)),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductsGrid(context),   // منتجاتي
            _buildReelsGrid(context),      // ريلزاتي
            _buildSavedGrid(context),      // المحفوظات
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف الأول: الصورة + الإحصائيات
          Row(
            children: [
              // صورة الملف الشخصي
              GestureDetector(
                onTap: () => _showProfilePhotoOptions(context, user),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(
                                user.fullName.isNotEmpty
                                    ? user.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // الإحصائيات
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('${user.totalAuctions}', 'منتجاتي'),
                    _buildStatColumn('${user.totalBids}', 'مزايداتي'),
                    _buildStatColumn(
                      user.rating > 0 ? user.rating.toStringAsFixed(1) : '-',
                      'التقييم',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // الاسم والبايو
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a2e),
            ),
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              user.bio!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF636E72),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (user.email != null && user.email!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 14, color: Color(0xFF00BCD4)),
                const SizedBox(width: 6),
                Text(
                  user.email!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF00BCD4)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _showPhoneNumber ? user.phone : _hidePhoneNumber(user.phone),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF636E72),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _togglePhoneVisibility,
                child: Icon(
                  _showPhoneNumber ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                  color: const Color(0xFF00BCD4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    ).then((_) {
                      // Refresh user data when returning from edit profile
                      if (mounted) {
                        context.read<AuthProvider>().refreshUser();
                      }
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1a1a2e),
                    side: const BorderSide(color: Color(0xFF00BCD4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'تعديل الملف الشخصي',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WalletPage()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Icon(Icons.account_balance_wallet_outlined, size: 22, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a2e),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF636E72),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsGrid(BuildContext context) {
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myProducts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.grid_on,
        title: 'لا توجد منتجات',
        subtitle: 'أضف منتجك الأول للبيع بالمزاد',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(1),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: _myProducts.length,
        itemBuilder: (context, index) => _buildAuctionTile(_myProducts[index]),
      ),
    );
  }

  Widget _buildBidsGrid(BuildContext context) {
    if (_isLoadingBids) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myBids.isEmpty) {
      return _buildEmptyState(
        icon: Icons.gavel,
        title: 'لا توجد مزايدات',
        subtitle: 'ابدأ المزايدة على المنتجات',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyBids,
      child: GridView.builder(
        padding: const EdgeInsets.all(1),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: _myBids.length,
        itemBuilder: (context, index) => _buildAuctionTile(_myBids[index]),
      ),
    );
  }

  Widget _buildReelsGrid(BuildContext context) {
    if (_isLoadingReels) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myReels.isEmpty) {
      return _buildEmptyState(
        icon: Icons.play_circle_outline,
        title: 'لا توجد ريلز',
        subtitle: 'أنشئ ريلز لعرض منتجاتك',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyReels,
      child: GridView.builder(
        padding: const EdgeInsets.all(1),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.6,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: _myReels.length,
        itemBuilder: (context, index) => _buildReelTile(_myReels[index]),
      ),
    );
  }

  Widget _buildReelTile(ReelModel reel) {
    return GestureDetector(
      onTap: () {
        // فتح الريل للمشاهدة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReelsPage(initialReelId: reel.id, showBottomNav: true),
          ),
        );
      },
      onLongPress: () => _showReelOptions(reel),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // الصورة المصغرة
          if (reel.thumbnailUrl != null)
            CachedNetworkImage(
              imageUrl: reel.thumbnailUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[900]),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.play_circle_outline, color: Colors.white54, size: 40),
              ),
            )
          else
            Container(
              color: Colors.grey[900],
              child: const Icon(Icons.play_circle_outline, color: Colors.white54, size: 40),
            ),
          
          // أيقونة الفيديو
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    '${reel.viewsCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          
          // زر الخيارات
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _showReelOptions(reel),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.more_vert, color: Colors.white, size: 16),
              ),
            ),
          ),
          
          // عنوان المزاد
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Text(
                reel.auctionTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReelOptions(ReelModel reel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.visibility, color: Color(0xFF00BCD4)),
              title: const Text('عرض الريل'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReelsPage(initialReelId: reel.id, showBottomNav: true),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new, color: Color(0xFF00BCD4)),
              title: const Text('عرض المزاد'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuctionDetailPage(auctionId: reel.auctionId),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('حذف الريل', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteReel(reel);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedGrid(BuildContext context) {
    if (_isLoadingSaved) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_savedAuctions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_border,
        title: 'لا توجد محفوظات',
        subtitle: 'احفظ المنتجات لمشاهدتها لاحقاً',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSavedAuctions,
      child: GridView.builder(
        padding: const EdgeInsets.all(1),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: _savedAuctions.length,
        itemBuilder: (context, index) => _buildAuctionTile(_savedAuctions[index]),
      ),
    );
  }

  Widget _buildAuctionTile(AuctionModel auction) {
    final imageUrl = auction.images.isNotEmpty ? _getImageUrl(auction.images.first) : '';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuctionDetailPage(auctionId: auction.id),
          ),
        ).then((_) {
          if (mounted) _loadData();
        }); // Refresh data when returning
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[200]),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.image, color: Colors.grey[400]),
                  ),
                )
              : Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.image, color: Colors.grey[400]),
                ),
          
          // Price overlay
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                CurrencyUtils.formatIQD(auction.currentPrice),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Status indicator
          if (auction.status == AuctionStatus.active)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          
          // Bid count for my bids
          if (auction.bidCount > 0)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.gavel, color: Colors.white, size: 10),
                    const SizedBox(width: 2),
                    Text(
                      '${auction.bidCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: const Color(0xFF00BCD4)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1a1a2e),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF636E72),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();
    final user = context.read<AuthProvider>().user;
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // رأس القائمة مع معلومات المستخدم
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : null,
                            child: user?.avatarUrl == null
                                ? Text(
                                    user?.fullName.isNotEmpty == true
                                        ? user!.fullName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user?.phone ?? '',
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
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      
                      // حسابي
                      _buildSectionTitle('حسابك'),
                      _buildSettingsItem(
                        icon: Icons.edit_outlined,
                        title: 'تعديل الملف الشخصي',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfilePage()),
                          );
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.bookmark_border,
                        title: 'المحفوظات',
                        onTap: () {
                          Navigator.pop(context);
                          _tabController.animateTo(2);
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.notifications_outlined,
                        title: 'الإشعارات',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'المحفظة',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WalletPage()),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      
                      // المزادات
                      _buildSectionTitle('المزادات'),
                      _buildSettingsItem(
                        icon: Icons.gavel,
                        title: 'مزاداتي',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'مشترياتي',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.confirmation_number_outlined,
                        title: 'أرقام طلباتي',
                        subtitle: 'للمساعدة والدعم',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HelpCodesPage()),
                          );
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'المحادثات',
                        badge: chatProvider.totalUnreadCount,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      
                      // المزيد
                      _buildSectionTitle('المزيد'),
                      _buildSettingsItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'المظهر',
                        subtitle: 'فاتح / داكن',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ThemeSettingsPage()),
                          );
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.settings_outlined,
                        title: 'الإعدادات',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsPage()),
                          );
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.help_outline,
                        title: 'المساعدة والدعم',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.info_outline,
                        title: 'حول التطبيق',
                        onTap: () {
                          Navigator.pop(context);
                          _showAboutDialog(context);
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      
                      // تسجيل الخروج
                      _buildSettingsItem(
                        icon: Icons.logout,
                        title: 'تسجيل الخروج',
                        isDestructive: true,
                        onTap: () {
                          Navigator.pop(context);
                          _showLogoutConfirmation(context);
                        },
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.gavel, color: Colors.blue.shade700, size: 28),
            ),
            const SizedBox(width: 12),
            const Text('مزاد'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'منصة المزادات الأولى في العراق',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            _buildAboutRow('الإصدار', '1.0.0'),
            _buildAboutRow('البناء', '2026.01'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    int badge = 0,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.black87,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            )
          : null,
      trailing: badge > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfilePhotoOptions(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAFAFA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (user.avatarUrl != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.visibility, color: Color(0xFF00BCD4)),
                ),
                title: const Text('عرض الصورة', style: TextStyle(color: Color(0xFF1a1a2e))),
                onTap: () {
                  Navigator.pop(context);
                  _showProfilePhoto(context, user);
                },
              ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a2e).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Color(0xFF1a1a2e)),
              ),
              title: const Text('تغيير الصورة', style: TextStyle(color: Color(0xFF1a1a2e))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                ).then((_) {
                  if (mounted) {
                    context.read<AuthProvider>().refreshUser();
                  }
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showProfilePhoto(BuildContext context, dynamic user) {
    if (user.avatarUrl == null) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: CircleAvatar(
            radius: 120,
            backgroundImage: NetworkImage(user.avatarUrl!),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 64,
                  color: Color(0xFF00BCD4),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'لم تقم بتسجيل الدخول',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a2e),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'سجل دخولك للوصول لحسابك',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF636E72),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Delegate للـ TabBar الثابت
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
