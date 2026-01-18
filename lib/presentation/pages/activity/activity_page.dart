import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../providers/providers.dart';
import '../auction/auction_detail_page.dart';
import '../create_auction/create_auction_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  void initState() {
    super.initState();
    // Fetch activity data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuctionProvider>().fetchMyBids();
      context.read<AuctionProvider>().fetchMyListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Column(
          children: [
            // Modern Header with curved bottom
            Container(
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
                child: Column(
                  children: [
                    // Title Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.history, color: Color(0xFF00BCD4), size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'نشاطي',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'تابع مزاداتك ومعروضاتك',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // زر إضافة مزاد
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CreateAuctionPage()),
                              );
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00BCD4),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 28),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tab Bar
                    const TabBar(
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      dividerColor: Colors.transparent,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      tabs: [
                        Tab(text: 'مزايداتي', icon: Icon(Icons.gavel_outlined, size: 22)),
                        Tab(text: 'معروضاتي', icon: Icon(Icons.storefront_outlined, size: 22)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            // Tab Content
            const Expanded(
              child: TabBarView(
                children: [
                  _MyBidsList(),
                  _MyListingsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyBidsList extends StatelessWidget {
  const _MyBidsList();

  @override
  Widget build(BuildContext context) {
    final auctionProvider = context.watch<AuctionProvider>();

    if (auctionProvider.isLoading && auctionProvider.myBids.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (auctionProvider.myBidsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              auctionProvider.myBidsError!,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => auctionProvider.fetchMyBids(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (auctionProvider.myBids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'لم تشارك في أي مزاد بعد',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Navigate to explore
              },
              child: const Text('استكشف المزادات'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => auctionProvider.fetchMyBids(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: auctionProvider.myBids.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final auction = auctionProvider.myBids[index];
          
          // Determine status
          String status;
          Color statusColor;
          
          if (auction.status.value == 'active') {
            status = 'مزاد جاري';
            statusColor = Colors.green;
          } else if (auction.status.value == 'sold' && auction.winnerId != null) {
            status = 'ربحت المزاد! 🎉';
            statusColor = Colors.blue;
          } else {
            status = 'انتهى المزاد';
            statusColor = Colors.grey;
          }

          return _ActivityItemCard(
            auctionId: auction.id,
            title: auction.title,
            price: auction.currentPrice,
            status: status,
            statusColor: statusColor,
            imageUrl: auction.images.isNotEmpty 
                ? auction.images.first 
                : 'https://via.placeholder.com/300',
          );
        },
      ),
    );
  }
}

class _MyListingsList extends StatelessWidget {
  const _MyListingsList();

  @override
  Widget build(BuildContext context) {
    final auctionProvider = context.watch<AuctionProvider>();

    if (auctionProvider.isLoading && auctionProvider.myListings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (auctionProvider.myListingsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              auctionProvider.myListingsError!,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => auctionProvider.fetchMyListings(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (auctionProvider.myListings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'لم تنشر أي منتج بعد',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Navigate to create auction
              },
              child: const Text('أضف منتج جديد'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => auctionProvider.fetchMyListings(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: auctionProvider.myListings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final auction = auctionProvider.myListings[index];
          
          String status;
          Color statusColor;
          
          if (auction.status.value == 'pending') {
            status = 'قيد المراجعة';
            statusColor = Colors.orange;
          } else if (auction.status.value == 'active') {
            status = 'جاري (${auction.bidCount} مزايدات)';
            statusColor = Colors.blue;
          } else if (auction.status.value == 'sold') {
            status = 'تم البيع ✓';
            statusColor = Colors.green;
          } else {
            status = 'منتهي';
            statusColor = Colors.grey;
          }

          return _ActivityItemCard(
            auctionId: auction.id,
            title: auction.title,
            price: auction.currentPrice,
            status: status,
            statusColor: statusColor,
            isMyListing: true,
            imageUrl: auction.images.isNotEmpty 
                ? auction.images.first 
                : 'https://via.placeholder.com/300',
          );
        },
      ),
    );
  }
}

class _ActivityItemCard extends StatelessWidget {
  final String auctionId;
  final String title;
  final double price;
  final String status;
  final Color statusColor;
  final bool isMyListing;
  final String imageUrl;

  const _ActivityItemCard({
    required this.auctionId,
    required this.title,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.imageUrl,
    this.isMyListing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1, // Slight elevation for depth
      color: Theme.of(context).cardColor,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Directionality(
                textDirection: TextDirection.rtl,
                child: AuctionDetailPage(auctionId: auctionId),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) => Container(
                    color: Colors.grey[200], 
                    width: 80, 
                    height: 80, 
                    child: const Icon(Icons.image_not_supported, color: Colors.grey)
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${isMyListing ? "أعلى سعر" : "سعرك"}: ${CurrencyUtils.formatIQD(price)}',
                       style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor, 
                          fontSize: 11, 
                          fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isMyListing)
                IconButton(
                  onPressed: () {}, 
                  icon: const Icon(Icons.more_vert),
                  color: Colors.grey[600],
                )
            ],
          ),
        ),
      ),
    );
  }
}
