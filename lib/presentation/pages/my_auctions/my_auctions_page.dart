import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/providers.dart';

class MyAuctionsPage extends StatefulWidget {
  const MyAuctionsPage({super.key});

  @override
  State<MyAuctionsPage> createState() => _MyAuctionsPageState();
}

class _MyAuctionsPageState extends State<MyAuctionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyAuctionsProvider>().loadAllAuctions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'مزاداتي',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'مزاداتي'),
            Tab(text: 'مشاركاتي'),
            Tab(text: 'فزت بها'),
          ],
        ),
      ),
      body: Consumer<MyAuctionsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && 
              provider.myAuctions.isEmpty && 
              provider.participatedAuctions.isEmpty && 
              provider.wonAuctions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMyAuctionsList(provider),
              _buildParticipatedList(provider),
              _buildWonList(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMyAuctionsList(MyAuctionsProvider provider) {
    final myAuctions = provider.myAuctions;
    
    if (myAuctions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.gavel_outlined,
        title: 'لا توجد مزادات',
        subtitle: 'أنشئ مزادك الأول الآن',
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => provider.refreshMyAuctions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myAuctions.length,
        itemBuilder: (context, index) {
          final auction = myAuctions[index];
          return _AuctionListItem(
            title: auction.title,
            price: _formatPrice(auction.currentPrice),
            status: auction.status.name,
            bidsCount: '${auction.bidCount}',
            imageUrl: auction.images.isNotEmpty ? auction.images.first : '',
            onTap: () {
              Navigator.pushNamed(context, '/auction-detail', arguments: auction.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildParticipatedList(MyAuctionsProvider provider) {
    final participatedAuctions = provider.participatedAuctions;
    
    if (participatedAuctions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.how_to_vote_outlined,
        title: 'لا توجد مشاركات',
        subtitle: 'شارك في المزادات لتظهر هنا',
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => provider.refreshParticipatedAuctions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: participatedAuctions.length,
        itemBuilder: (context, index) {
          final auction = participatedAuctions[index];
          final auctionData = auction['auction'] ?? auction;
          return _ParticipatedAuctionItem(
            title: auctionData['title'] ?? auctionData['product']?['name'] ?? '',
            myBid: _formatPrice(auction['amount'] ?? auction['myBid']),
            currentPrice: _formatPrice(auctionData['currentBid']),
            status: auctionData['status'] ?? 'active',
            imageUrl: auctionData['product']?['images']?[0] ?? '',
            isWinning: auction['isWinning'] == true,
            onTap: () {
              Navigator.pushNamed(context, '/auction-detail', arguments: auctionData['id']);
            },
          );
        },
      ),
    );
  }

  Widget _buildWonList(MyAuctionsProvider provider) {
    final wonAuctions = provider.wonAuctions;
    
    if (wonAuctions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'لا توجد مزادات فائزة',
        subtitle: 'شارك في المزادات للفوز بها',
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => provider.refreshWonAuctions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: wonAuctions.length,
        itemBuilder: (context, index) {
          final auction = wonAuctions[index];
          return _WonAuctionItem(
            title: auction.title,
            finalPrice: _formatPrice(auction.currentPrice),
            wonDate: _formatDate(auction.endTime.toIso8601String()),
            imageUrl: auction.images.isNotEmpty ? auction.images.first : '',
            isPaid: false,
            onTap: () {
              Navigator.pushNamed(context, '/auction-detail', arguments: auction.id);
            },
          );
        },
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final num = double.tryParse(price.toString()) ?? 0;
    return num.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date.toString();
    }
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
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 50,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionListItem extends StatelessWidget {
  final String title;
  final String price;
  final String status;
  final String bidsCount;
  final String imageUrl;
  final VoidCallback onTap;

  const _AuctionListItem({
    required this.title,
    required this.price,
    required this.status,
    required this.bidsCount,
    required this.imageUrl,
    required this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'ended':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _statusText {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'pending':
        return 'قيد المراجعة';
      case 'ended':
        return 'منتهي';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_outlined,
                      color: AppColors.textSecondary,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$price د.ع',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$bidsCount مزايدة',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipatedAuctionItem extends StatelessWidget {
  final String title;
  final String myBid;
  final String currentPrice;
  final String status;
  final String imageUrl;
  final bool isWinning;
  final VoidCallback onTap;

  const _ParticipatedAuctionItem({
    required this.title,
    required this.myBid,
    required this.currentPrice,
    required this.status,
    required this.imageUrl,
    required this.isWinning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isWinning
              ? Border.all(color: AppColors.success, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_outlined,
                      color: AppColors.textSecondary,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isWinning)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'الأعلى ✓',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مزايدتي',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '$myBid د.ع',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isWinning
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'السعر الحالي',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '$currentPrice د.ع',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _WonAuctionItem extends StatelessWidget {
  final String title;
  final String finalPrice;
  final String wonDate;
  final String imageUrl;
  final bool isPaid;
  final VoidCallback onTap;

  const _WonAuctionItem({
    required this.title,
    required this.finalPrice,
    required this.wonDate,
    required this.imageUrl,
    required this.isPaid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Trophy + Image
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_outlined,
                          color: AppColors.textSecondary,
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🏆', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$finalPrice د.ع',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'فزت بتاريخ $wonDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Payment Status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isPaid
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isPaid ? 'تم الدفع' : 'بانتظار الدفع',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPaid ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
