import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_utils.dart';
import '../auction/auction_detail_page.dart';
import '../reels/reels_page.dart';

/// Public User Profile Page - Instagram Style
class UserProfilePage extends StatefulWidget {
  final String userId;
  final String? userName;

  const UserProfilePage({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Dio _dio;
  Map<String, dynamic>? _userProfile;
  List<dynamic> _auctions = [];
  List<dynamic> _reels = [];
  bool _isLoading = true;
  bool _isLoadingAuctions = false;
  bool _isLoadingReels = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    String baseUrl = AppConstants.baseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'ngrok-skip-browser-warning': 'true'},
    ));
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  double _parsePrice(dynamic price) {
    if (price == null) return 0;
    if (price is num) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0;
    return 0;
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _dio.get('/api/users/${widget.userId}/profile');

      if (response.data['success'] == true) {
        setState(() {
          _userProfile = response.data['data'];
          _isLoading = false;
        });
        _loadAuctions();
        _loadReels();
      } else {
        setState(() {
          _error = 'فشل في تحميل الملف الشخصي';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'فشل في تحميل الملف الشخصي';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAuctions() async {
    if (_isLoadingAuctions) return;
    setState(() => _isLoadingAuctions = true);

    try {
      final response = await _dio.get('/api/users/${widget.userId}/auctions');
      if (response.data['success'] == true) {
        setState(() => _auctions = response.data['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading auctions: $e');
    } finally {
      setState(() => _isLoadingAuctions = false);
    }
  }

  Future<void> _loadReels() async {
    if (_isLoadingReels) return;
    setState(() => _isLoadingReels = true);

    try {
      final response = await _dio.get('/api/users/${widget.userId}/reels');
      if (response.data['success'] == true) {
        setState(() => _reels = response.data['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading reels: $e');
    } finally {
      setState(() => _isLoadingReels = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorView()
                : _buildContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final username = _userProfile?['username'] ?? widget.userName ?? 'المستخدم';
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            username,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_userProfile?['isVerified'] == 1 || _userProfile?['isVerified'] == true) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 18),
          ],
        ],
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loadUserProfile,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(child: _buildProfileHeader()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                indicatorWeight: 1,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on, size: 24)),
                  Tab(icon: Icon(Icons.play_circle_outline, size: 24)),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAuctionsGrid(),
          _buildReelsGrid(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final profile = _userProfile!;
    final avatarUrl = _getImageUrl(profile['avatarUrl']);
    final fullName = profile['fullName'] ?? 'مستخدم';
    final bio = profile['bio'] ?? '';
    final totalAuctions = profile['totalAuctions'] ?? 0;
    final totalReels = profile['totalReels'] ?? 0;
    final rating = profile['rating'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Avatar + Stats
          Row(
            children: [
              // Avatar with gradient border
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple,
                      Colors.pink,
                      Colors.orange,
                      Colors.yellow.shade700,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.grey[200],
                    child: avatarUrl.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: avatarUrl,
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _buildAvatarPlaceholder(fullName),
                              errorWidget: (_, __, ___) => _buildAvatarPlaceholder(fullName),
                            ),
                          )
                        : _buildAvatarPlaceholder(fullName),
                  ),
                ),
              ),
              
              const SizedBox(width: 24),
              
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('$totalAuctions', 'مزاد'),
                    _buildStatColumn('$totalReels', 'ريلز'),
                    _buildStatColumn(_formatRating(rating), 'تقييم'),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Name
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          // Bio
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              bio,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // Member since
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'عضو منذ ${_formatDate(profile['memberSince'])}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('متابعة', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('رسالة', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: const Icon(Icons.person_add_outlined, size: 18),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder(String? name) {
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAuctionsGrid() {
    if (_isLoadingAuctions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_auctions.isEmpty) {
      return _buildEmptyState(Icons.grid_on, 'لا توجد مزادات');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: _auctions.length,
      itemBuilder: (context, index) => _buildAuctionTile(_auctions[index]),
    );
  }

  Widget _buildAuctionTile(Map<String, dynamic> auction) {
    final imageUrl = _getImageUrl(auction['primaryImage']);
    final price = _parsePrice(auction['currentPrice']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AuctionDetailPage(auctionId: auction['id']),
            ),
          ),
        );
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
                CurrencyUtils.formatIQD(price),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Status indicator
          if (auction['status'] == 'active')
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
        ],
      ),
    );
  }

  Widget _buildReelsGrid() {
    if (_isLoadingReels) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reels.isEmpty) {
      return _buildEmptyState(Icons.play_circle_outline, 'لا توجد ريلز');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: _reels.length,
      itemBuilder: (context, index) => _buildReelTile(_reels[index]),
    );
  }

  Widget _buildReelTile(Map<String, dynamic> reel) {
    final thumbnailUrl = _getImageUrl(reel['thumbnailUrl'] ?? reel['auctionImage']);
    final views = reel['viewsCount'] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReelsPage(
              initialReelId: reel['id'],
              userId: widget.userId,
              showBackButton: true,
            ),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          thumbnailUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[900]),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.play_arrow, color: Colors.white38),
                  ),
                )
              : Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.play_arrow, color: Colors.white38),
                ),
          
          // Play icon
          const Center(
            child: Icon(Icons.play_arrow, color: Colors.white70, size: 32),
          ),
          
          // Views count
          Positioned(
            bottom: 6,
            left: 6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                const SizedBox(width: 2),
                Text(
                  _formatCount(views),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: Icon(icon, size: 40, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatRating(dynamic rating) {
    if (rating == null) return '0.0';
    if (rating is String) return double.tryParse(rating)?.toStringAsFixed(1) ?? '0.0';
    if (rating is num) return rating.toDouble().toStringAsFixed(1);
    return '0.0';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatCount(dynamic count) {
    final num value = count is num ? count : 0;
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toInt().toString();
  }
}

// Tab Bar Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
