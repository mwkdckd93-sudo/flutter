import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/providers.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/models/auction_model.dart';
import '../../../data/services/api_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/cards/auction_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  
  // Categories with gradients
  final List<Map<String, dynamic>> _categories = [
    {'id': 'cat-1', 'name': 'إلكترونيات', 'icon': Icons.devices_rounded, 'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)]},
    {'id': 'cat-2', 'name': 'موبايلات', 'icon': Icons.phone_android_rounded, 'gradient': [const Color(0xFF11998e), const Color(0xFF38ef7d)]},
    {'id': 'cat-3', 'name': 'أجهزة منزلية', 'icon': Icons.home_rounded, 'gradient': [const Color(0xFFeb3349), const Color(0xFFf45c43)]},
    {'id': 'cat-4', 'name': 'كيمينك', 'icon': Icons.sports_esports_rounded, 'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)]},
    {'id': 'cat-5', 'name': 'أثاث', 'icon': Icons.chair_rounded, 'gradient': [const Color(0xFFf093fb), const Color(0xFFf5576c)]},
    {'id': 'cat-6', 'name': 'ساعات', 'icon': Icons.watch_rounded, 'gradient': [const Color(0xFF5f72bd), const Color(0xFF9b23ea)]},
    {'id': 'cat-7', 'name': 'كاميرات', 'icon': Icons.camera_alt_rounded, 'gradient': [const Color(0xFF00c6fb), const Color(0xFF005bea)]},
    {'id': 'cat-8', 'name': 'المزيد', 'icon': Icons.apps_rounded, 'gradient': [const Color(0xFF636e72), const Color(0xFF2d3436)]},
  ];

  List<ShopModel> _verifiedShops = [];
  bool _isLoadingShops = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadVerifiedShops();
  }

  Future<void> _loadVerifiedShops() async {
    try {
      final shops = await ApiService.instance.getVerifiedShops(limit: 10);
      if (mounted) {
        setState(() {
          _verifiedShops = shops;
          _isLoadingShops = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load verified shops: $e');
      if (mounted) {
        setState(() => _isLoadingShops = false);
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AuctionProvider>().loadMore();
    }
  }
  
  void _onSearchChanged() {
    setState(() {});
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _onSearch(_searchController.text);
    });
  }

  void _onSearch(String query) {
    context.read<AuctionProvider>().setFilter(search: query.isNotEmpty ? query : null);
  }

  void _onCategorySelected(String categoryId, String categoryName) {
    _showCategoryProducts(categoryId, categoryName);
  }

  void _showShopProducts(ShopModel shop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF00ACC1)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: shop.avatarUrl != null && shop.avatarUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(imageUrl: shop.avatarUrl!, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.store_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  shop.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1a1a2e),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: Color(0xFF00BCD4), size: 18),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 16),
                              const SizedBox(width: 4),
                              Text(shop.rating.toStringAsFixed(1), style: TextStyle(color: isDark ? AppColors.textSecondaryDark : Colors.grey[600])),
                              const SizedBox(width: 12),
                              Text('${shop.productCount} منتج', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 20, color: isDark ? AppColors.textPrimaryDark : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<AuctionModel>>(
                  future: ApiService.instance.getAuctionsBySeller(shop.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: isDark ? AppColors.textSecondaryDark : Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('لا توجد منتجات حالياً', style: TextStyle(fontSize: 16, color: isDark ? AppColors.textSecondaryDark : Colors.grey[600])),
                          ],
                        ),
                      );
                    }
                    final auctions = snapshot.data!;
                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.65,
                      ),
                      itemCount: auctions.length,
                      itemBuilder: (context, index) {
                        final auction = auctions[index];
                        return AuctionCard(
                          auctionId: auction.id,
                          title: auction.title,
                          currentBid: auction.currentPrice,
                          imageUrl: auction.images.isNotEmpty ? auction.images.first : 'https://via.placeholder.com/300',
                          endTime: auction.endTime,
                          bidCount: auction.bidCount,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryProducts(String categoryId, String categoryName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1a1a2e),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 20, color: isDark ? AppColors.textPrimaryDark : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<AuctionModel>>(
                  future: ApiService.instance.getAuctionsByCategory(categoryId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: isDark ? AppColors.textSecondaryDark : Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('لا توجد منتجات في هذا القسم', style: TextStyle(fontSize: 16, color: isDark ? AppColors.textSecondaryDark : Colors.grey[600])),
                          ],
                        ),
                      );
                    }
                    final auctions = snapshot.data!;
                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.65,
                      ),
                      itemCount: auctions.length,
                      itemBuilder: (context, index) {
                        final auction = auctions[index];
                        return AuctionCard(
                          auctionId: auction.id,
                          title: auction.title,
                          currentBid: auction.currentPrice,
                          imageUrl: auction.images.isNotEmpty ? auction.images.first : 'https://via.placeholder.com/300',
                          endTime: auction.endTime,
                          bidCount: auction.bidCount,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = context.watch<AuctionProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<AuctionProvider>().fetchAuctions(refresh: true),
            _loadVerifiedShops(),
          ]);
        },
        color: const Color(0xFF00BCD4),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header - Same style as home page
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                      ? [AppColors.surfaceDark, AppColors.backgroundDark, const Color(0xFF0a0a0f)]
                      : [const Color(0xFF1a1a2e), const Color(0xFF16213e), const Color(0xFF0f0f1a)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Icon(Icons.explore_rounded, color: Color(0xFF00BCD4), size: 26),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('استكشف', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                  SizedBox(height: 2),
                                  Text('تصفح الأقسام والمحلات', style: TextStyle(fontSize: 13, color: Colors.white70)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Icon(Icons.search_rounded, color: isDark ? AppColors.textHintDark : Colors.grey[400], size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onSubmitted: _onSearch,
                                  style: TextStyle(color: isDark ? AppColors.textPrimaryDark : Colors.black),
                                  decoration: InputDecoration(
                                    hintText: 'ابحث عن منتجات، محلات...',
                                    hintStyle: TextStyle(color: isDark ? AppColors.textHintDark : Colors.grey[400], fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: Icon(Icons.clear_rounded, color: isDark ? AppColors.textHintDark : Colors.grey[400], size: 20),
                                  onPressed: () { _searchController.clear(); _onSearch(''); },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Categories Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.category_rounded, color: Color(0xFF6C5CE7), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text('الأقسام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1a1a2e))),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Categories Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final gradientList = category['gradient'];
                    final gradientColors = gradientList is List ? gradientList.cast<Color>() : [const Color(0xFF667eea), const Color(0xFF764ba2)];
                    return GestureDetector(
                      onTap: () => _onCategorySelected(category['id'], category['name']),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: Icon(category['icon'] as IconData, color: Colors.white, size: 26),
                          ),
                          const SizedBox(height: 8),
                          Text(category['name'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1a1a2e)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Verified Shops Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BCD4).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified_rounded, color: Color(0xFF00BCD4), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text('محلات معتمدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1a1a2e))),
                      ],
                    ),
                    TextButton(onPressed: () {}, style: TextButton.styleFrom(foregroundColor: const Color(0xFF00BCD4)), child: const Text('عرض الكل')),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Shops List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 150,
                child: _isLoadingShops
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)))
                  : _verifiedShops.isEmpty
                    ? Center(child: Text('لا توجد محلات معتمدة حالياً', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : Colors.grey[500])))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _verifiedShops.length,
                        itemBuilder: (context, index) {
                          final shop = _verifiedShops[index];
                          return GestureDetector(
                            onTap: () => _showShopProducts(shop),
                            child: Container(
                              width: 130,
                              margin: const EdgeInsets.only(left: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDark : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF00ACC1)]), shape: BoxShape.circle),
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(color: isDark ? AppColors.surfaceVariantDark : Colors.white, shape: BoxShape.circle),
                                      child: shop.avatarUrl != null && shop.avatarUrl!.isNotEmpty
                                        ? ClipOval(child: CachedNetworkImage(imageUrl: shop.avatarUrl!, fit: BoxFit.cover, placeholder: (c, u) => Icon(Icons.store_rounded, color: Colors.grey[400], size: 22), errorWidget: (c, u, e) => Icon(Icons.store_rounded, color: Colors.grey[400], size: 22)))
                                        : Icon(Icons.store_rounded, color: Colors.grey[400], size: 22),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(child: Text(shop.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1a1a2e)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        const SizedBox(width: 3),
                                        const Icon(Icons.verified, color: Color(0xFF00BCD4), size: 12),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 12),
                                      const SizedBox(width: 2),
                                      Text(shop.rating.toStringAsFixed(1), style: TextStyle(fontSize: 10, color: isDark ? AppColors.textSecondaryDark : Colors.grey[600])),
                                      Text(' • ${shop.productCount} منتج', style: TextStyle(fontSize: 9, color: isDark ? AppColors.textSecondaryDark : Colors.grey[500])),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // All Products Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFE17055).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.local_offer_rounded, color: Color(0xFFE17055), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text('جميع المنتجات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1a1a2e))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: isDark ? AppColors.surfaceVariantDark : const Color(0xFF1a1a2e), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const Icon(Icons.grid_view_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text('${auctionProvider.auctions.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Products Grid
            if (auctionProvider.isLoading && auctionProvider.auctions.isEmpty)
              const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)))))
            else if (auctionProvider.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: isDark ? AppColors.textSecondaryDark : Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(auctionProvider.error!, style: TextStyle(color: isDark ? AppColors.textSecondaryDark : Colors.grey[600])),
                        TextButton.icon(onPressed: () => auctionProvider.fetchAuctions(refresh: true), icon: const Icon(Icons.refresh_rounded), label: const Text('إعادة المحاولة'), style: TextButton.styleFrom(foregroundColor: const Color(0xFF00BCD4))),
                      ],
                    ),
                  ),
                ),
              )
            else if (auctionProvider.auctions.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: isDark ? AppColors.textSecondaryDark : Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('لا توجد منتجات', style: TextStyle(fontSize: 18, color: isDark ? AppColors.textSecondaryDark : Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.65),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final auction = auctionProvider.auctions[index];
                      return AuctionCard(
                        auctionId: auction.id,
                        title: auction.title,
                        currentBid: auction.currentPrice,
                        imageUrl: auction.images.isNotEmpty ? auction.images.first : 'https://via.placeholder.com/300',
                        endTime: auction.endTime,
                        bidCount: auction.bidCount,
                      );
                    },
                    childCount: auctionProvider.auctions.length,
                  ),
                ),
              ),

            if (auctionProvider.isLoadingMore)
              const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4))))),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
