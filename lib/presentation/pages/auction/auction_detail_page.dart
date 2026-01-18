import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/models/auction_model.dart';
import '../../../data/services/api_service.dart';
import '../../../providers/auction_detail_provider.dart';
import '../../../providers/auction_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../dialogs/bid_dialogs.dart';
import '../../widgets/widgets.dart';
import '../../widgets/modern_image_gallery.dart';
import '../auth/login_page.dart';
import '../chat/chat_page.dart';
import '../profile/user_profile_page.dart';
import '../reels/upload_reel_page.dart';

class AuctionDetailPage extends StatefulWidget {
  final String auctionId;

  const AuctionDetailPage({
    super.key,
    required this.auctionId,
  });

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  late AuctionDetailProvider _provider;
  AuctionProvider? _auctionProvider;

  @override
  void initState() {
    super.initState();
    _provider = AuctionDetailProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadAuction(widget.auctionId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference early to use in dispose
    _auctionProvider ??= context.read<AuctionProvider>();
  }

  @override
  void dispose() {
    // Update the auction in the main list when leaving
    if (_provider.auction != null && _auctionProvider != null) {
      _auctionProvider!.updateAuctionInList(_provider.auction!);
    }
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.user?.id;
    final isLoggedIn = authProvider.isLoggedIn;
    
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        body: Consumer<AuctionDetailProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(provider.error!),
                    TextButton(
                      onPressed: () => provider.loadAuction(widget.auctionId),
                      child: const Text('أعد المحاولة'),
                    ),
                  ],
                ),
              );
            }

            final auction = provider.auction;
            if (auction == null) {
              return const Center(child: Text('لم يتم العثور على المزاد'));
            }

            return _AuctionDetailContent(
              auction: auction,
              provider: provider,
              currentUserId: currentUserId,
              isLoggedIn: isLoggedIn,
            );
          },
        ),
      ),
    );
  }
}

class _AuctionDetailContent extends StatelessWidget {
  final AuctionModel auction;
  final AuctionDetailProvider provider;
  final String? currentUserId;
  final bool isLoggedIn;

  const _AuctionDetailContent({
    required this.auction,
    required this.provider,
    required this.currentUserId,
    required this.isLoggedIn,
  });

  bool get isOwner => currentUserId != null && auction.sellerId == currentUserId;
  bool get isHighestBidder => currentUserId != null && (provider.auction?.highestBidderId ?? auction.highestBidderId) == currentUserId;
  double get nextMinBid => provider.nextMinBid;
  bool get hasEnded => provider.hasEnded;
  bool get isAboutToEnd => provider.isAboutToEnd;
  bool get canBid => !isOwner && !isHighestBidder && !hasEnded;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(child: _buildMainInfo(context)),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    labelColor: Color(0xFF1E88E5),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF1E88E5),
                    indicatorWeight: 3,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    tabs: [
                      Tab(text: 'التفاصيل'),
                      Tab(text: 'المزايدات'),
                      Tab(text: 'الأسئلة'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildDetailsTab(context),
              _buildBidsTab(context),
              _buildQnATab(context),
            ],
          ),
        ),
        bottomNavigationBar: Consumer<AuctionDetailProvider>(
          builder: (context, p, _) {
            // Use fresh provider data for highest bidder check
            final liveAuction = p.auction ?? auction;
            final isCurrentUserHighestBidder = currentUserId != null &&
                liveAuction.highestBidderId == currentUserId;
            return _buildBottomActionBar(context, p, liveAuction, isCurrentUserHighestBidder);
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 480,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            auction.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: auction.isFavorite ? Colors.red : Colors.black,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white, 
            padding: const EdgeInsets.all(8),
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share_outlined, color: Colors.black),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
             padding: const EdgeInsets.all(8),
             shape: const CircleBorder(),
          ),
        ),
        const SizedBox(width: 8),
        // زر إضافة ريل
        if (currentUserId == auction.sellerId)
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadReelPage(
                    preSelectedAuctionId: auction.id,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.video_call_outlined, color: Colors.black),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(8),
              shape: const CircleBorder(),
            ),
            tooltip: 'إضافة ريل',
          ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: ModernImageGallery(images: auction.images, height: 480),
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  auction.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.3),
                ),
              ),
              if (isAboutToEnd)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ينتهي قريباً',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            children: [
              _buildTag(auction.categoryName, Colors.blue),
              _buildTag(auction.condition.arabicName, Colors.orange),
              if (auction.warranty.hasWarranty)
               _buildTag(auction.warranty.displayText, Colors.green),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'أعلى سعر',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyUtils.formatIQD(auction.currentPrice),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 45,
                  color: Colors.grey.shade200,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'ينتهي خلال',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    _buildSimpleTimer(),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSimpleTimer() {
    if (hasEnded) return const Text('منتهي', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red));
    
    // Using simple text based on provider.timeRemaining
    // This assumes provider notifies on tick. 
    // If not, CountdownTimerWidget is better but this matches the design request.
    // For seamless integration with existing widgets, we can wrap existing CountdownTimerWidget logic 
    // or just use text if provider updates enough.
    // Let's rely on CountdownTimerWidget logic but formatted cleanly.
    
    final time = provider.timeRemaining;
    if (time.inSeconds <= 0) return const Text('منتهي', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red));
    
    final h = time.inHours;
    final m = time.inMinutes.remainder(60);
    final s = time.inSeconds.remainder(60);
    
    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 16, color: isAboutToEnd ? Colors.red : Colors.grey),
        const SizedBox(width: 4),
        Text(
          '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isAboutToEnd ? Colors.red : Colors.black87,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    final showCompletion = hasEnded && (isOwner || isHighestBidder);
    if (showCompletion && provider.completionDetails == null && !provider.isCompletionLoading) {
      Future.microtask(() => provider.loadCompletionDetails());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (showCompletion) _buildCompletionCard(context),
        if (showCompletion) const SizedBox(height: 16),
        
        // الوصف
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.description_outlined, color: Color(0xFF00BCD4), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('الوصف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a1a2e))),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                auction.description,
                style: const TextStyle(
                  height: 1.8,
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // معلومات البائع - Clickable to open profile
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(
                  userId: auction.sellerId,
                  userName: auction.sellerName,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_outline, color: Color(0xFF6C5CE7), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('معلومات البائع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1a1a2e))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C5CE7), Color(0xFF8B7CF7)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C5CE7).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: auction.sellerAvatar != null 
                        ? ClipOval(
                            child: Image.network(
                              auction.sellerAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  auction.sellerName.isNotEmpty ? auction.sellerName[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              auction.sellerName.isNotEmpty ? auction.sellerName[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auction.sellerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1a1a2e),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'تاجر موثوق',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF00BCD4),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildCompletionCard(BuildContext context) {
    final details = provider.completionDetails;
    final loading = provider.isCompletionLoading;
    final isSellerView = isOwner;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: loading || details == null
          ? Row(
              children: const [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 12),
                Text('جاري جلب تفاصيل الفائز...'),
              ],
            )
          : Builder(builder: (_) {
              final target = isSellerView ? details['buyer'] : details['seller'];
              if (target == null) {
                return const Text('لا يوجد فائز بعد');
              }

              final name = target['name']?.toString() ?? 'غير معروف';
              final phone = target['phone']?.toString();
              
              // Safely convert finalPrice to double
              double? finalPrice;
              final priceValue = details['finalPrice'];
              if (priceValue != null) {
                if (priceValue is num) {
                  finalPrice = priceValue.toDouble();
                } else if (priceValue is String) {
                  finalPrice = double.tryParse(priceValue);
                }
              }
              final priceText = finalPrice != null
                  ? CurrencyUtils.formatIQD(finalPrice)
                  : '-';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        isSellerView ? 'تفاصيل المشتري الفائز' : 'تفاصيل البائع',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF1E88E5),
                        child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('السعر النهائي: $priceText'),
                            if (phone != null) ...[
                              const SizedBox(height: 4),
                              Text('هاتف: $phone'),
                            ] else ...[
                              const SizedBox(height: 4),
                              const Text('الهاتف متاح للطرف المخول'),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openChat(context),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Text(isSellerView ? 'تواصل مع المشتري' : 'تواصل مع البائع'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              );
            }),
    );
  }

  Widget _buildBidsTab(BuildContext context) {
    if (provider.bids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.gavel, size: 48, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد مزايدات حتى الآن',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'كن أول من يزايد!',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.bids.length + 1,
      itemBuilder: (context, index) {
        if (index == provider.bids.length) return const SizedBox(height: 100);
        final bid = provider.bids[index];
        final isFirst = index == 0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isFirst 
              ? const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                )
              : null,
            color: isFirst ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFirst ? Colors.green.withOpacity(0.3) : Colors.grey.shade100,
              width: isFirst ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isFirst 
                  ? Colors.green.withOpacity(0.15) 
                  : Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // الترتيب
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: isFirst 
                    ? const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)])
                    : null,
                  color: isFirst ? null : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isFirst 
                    ? const Icon(Icons.emoji_events, color: Colors.white, size: 18)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              
              // صورة المستخدم
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFirst 
                      ? [const Color(0xFF4CAF50), const Color(0xFF81C784)]
                      : [const Color(0xFF6C5CE7), const Color(0xFF8B7CF7)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isFirst ? Colors.green : const Color(0xFF6C5CE7)).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    bid.bidderName.isNotEmpty ? bid.bidderName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // اسم المزايد والوقت
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            bid.bidderName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isFirst ? Colors.green[800] : const Color(0xFF1a1a2e),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isFirst) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'الأعلى',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          _getRelativeTime(bid.createdAt),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // المبلغ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isFirst ? Colors.green : const Color(0xFF1a1a2e),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  CurrencyUtils.formatIQD(bid.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQnATab(BuildContext context) {
    return Column(
      children: [
        // زر إضافة سؤال
        Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () => _showAskQuestionDialog(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF00BCD4).withOpacity(0.1), const Color(0xFF00BCD4).withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.help_outline, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لديك سؤال؟',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1a1a2e)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'اسأل البائع وسيجيبك',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.add_circle_outline, color: Color(0xFF00BCD4), size: 24),
                ],
              ),
            ),
          ),
        ),

        // قائمة الأسئلة
        Expanded(
          child: provider.questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.question_answer_outlined, size: 48, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد أسئلة بعد',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'كن أول من يسأل!',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.questions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == provider.questions.length) return const SizedBox(height: 100);
                    final q = provider.questions[index];
                    final isAnswered = q.isAnswered && q.answer != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // السؤال
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C5CE7).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.help_outline, size: 18, color: Color(0xFF6C5CE7)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        q.question,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1a1a2e)),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            q.askerName ?? 'مستخدم',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                                          const SizedBox(width: 4),
                                          Text(
                                            _getRelativeTime(q.createdAt),
                                            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isAnswered)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'بانتظار الرد',
                                      style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // الإجابة
                          if (isAnswered) ...[
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              height: 1,
                              color: Colors.grey[100],
                            ),
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00BCD4).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.2)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00BCD4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'رد البائع',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF00BCD4)),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.verified, size: 14, color: Color(0xFF00BCD4)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          q.answer!,
                                          style: const TextStyle(fontSize: 14, color: Color(0xFF1a1a2e), height: 1.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (isOwner) ...[
                            // زر الإجابة للبائع
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: GestureDetector(
                                onTap: () => _showAnswerQuestionDialog(context, q),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.reply, size: 18, color: Color(0xFF00BCD4)),
                                      SizedBox(width: 8),
                                      Text('أجب على هذا السؤال', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAskQuestionDialog(BuildContext ctx) {
    if (currentUserId == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول لطرح سؤال')),
      );
      return;
    }

    final controller = TextEditingController();
    showDialog(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.help_outline, color: Color(0xFF00BCD4)),
            ),
            const SizedBox(width: 12),
            const Text('اسأل البائع'),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'اكتب سؤالك هنا...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().length < 5) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('السؤال يجب أن يكون 5 أحرف على الأقل')),
                );
                return;
              }
              try {
                await ApiService.instance.askQuestion(auctionId: auction.id, question: controller.text.trim());
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('تم إرسال سؤالك بنجاح'), backgroundColor: Colors.green),
                );
                provider.loadAuction(auction.id); // تحديث البيانات
              } catch (e) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _showAnswerQuestionDialog(BuildContext ctx, dynamic question) {
    final controller = TextEditingController();
    showDialog(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.reply, color: Color(0xFF00BCD4)),
            SizedBox(width: 12),
            Text('أجب على السؤال'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(question.question, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'اكتب إجابتك هنا...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().length < 2) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('الإجابة مطلوبة')),
                );
                return;
              }
              try {
                await ApiService.instance.answerQuestion(
                  auctionId: auction.id, 
                  questionId: question.id, 
                  answer: controller.text.trim(),
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('تم حفظ الإجابة'), backgroundColor: Colors.green),
                );
                provider.loadAuction(auction.id);
              } catch (e) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('حفظ الإجابة'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    AuctionDetailProvider liveProvider,
    AuctionModel liveAuction,
    bool isCurrentUserHighestBidder,
  ) {
    final liveHasEnded = liveProvider.hasEnded;
    final liveIsOwner = currentUserId != null && liveAuction.sellerId == currentUserId;

    // If auction ended
    if (liveHasEnded) {
      // Check if current user is the winner or seller
      final isWinner = currentUserId != null && liveAuction.winnerId == currentUserId;
      final canChat = isWinner || liveIsOwner;
      
      if (canChat && auction.winnerId != null) {
        return Container(
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openChat(context),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(isWinner ? 'تواصل مع البائع' : 'تواصل مع المشتري'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1a1a2e),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: () => _showAuctionResultDialog(context),
                  icon: Icon(Icons.info_outline, color: Colors.green.shade600),
                ),
              ),
            ],
          ),
        );
      }
      
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
            child: const Text('المزاد منتهي', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
        ),
      );
    }

    // If owner - show edit button
      if (liveIsOwner) {
      return Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to edit page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('صفحة التحرير قيد التطوير')),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('تحرير المنتج'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () {
                  // TODO: Show delete confirmation
                },
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              ),
            ),
          ],
        ),
      );
    }

    // If user is the highest bidder - show success message
    if (isCurrentUserHighestBidder) {
      return Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            border: Border.all(color: Colors.green.shade300),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                'أنت أعلى مزايد حالياً',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Regular bidding bar
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleQuickBid(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text( 
                'زاود بـ ${nextMinBid.toStringAsFixed(0)} د.ع',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () => _showCustomBidDialog(context),
              icon: const Icon(Icons.add, color: Colors.black87),
            ),
          )
        ],
      ),
    );
  }

  void _handleQuickBid(BuildContext context) async {
    // Check if user is logged in
    if (!isLoggedIn) {
      _showLoginPrompt(context);
      return;
    }
    
    final success = await provider.placeQuickBid();
    if (success && provider.auction != null) {
      // Add to my bids list
      context.read<AuctionProvider>().addToMyBids(provider.auction!);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'تم تقديم مزايدتك بنجاح!' : (provider.error ?? 'فشل تقديم العرض')),
          backgroundColor: success ? Colors.green : Colors.red,
        )
      );
    }
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('يجب تسجيل الدخول'),
        content: const Text('لتقديم مزايدة، يجب عليك تسجيل الدخول أولاً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Directionality(
                    textDirection: TextDirection.rtl,
                    child: LoginPage(),
                  ),
                ),
              );
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  void _showCustomBidDialog(BuildContext context) {
    // Check if user is logged in
    if (!isLoggedIn) {
      _showLoginPrompt(context);
      return;
    }
    
    showDialog(
      context: context,
      builder: (dialogContext) => CustomBidDialog(
        currentPrice: auction.currentPrice,
        minIncrement: auction.minBidIncrement,
        onBid: (amount) async {
          final success = await provider.placeBid(amount);
          if (success && provider.auction != null) {
            // Add to my bids list
            context.read<AuctionProvider>().addToMyBids(provider.auction!);
          }
          if (dialogContext.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? 'تم تقديم مزايدتك بنجاح!' : (provider.error ?? 'فشل تقديم العرض')),
                backgroundColor: success ? Colors.green : Colors.red,
              )
            );
          }
        },
      ),
    );
  }

  String _getRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    return 'منذ ${diff.inDays} يوم';
  }

  void _openChat(BuildContext context) async {
    // Get or create conversation for this auction
    try {
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.openConversation(auction.id);
      
      if (chatProvider.currentConversation != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              conversationId: chatProvider.currentConversation!['id'] as String,
              auctionId: auction.id,
              otherUserName: isOwner ? 'المشتري' : auction.sellerName,
              auctionTitle: auction.title,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في فتح المحادثة: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAuctionResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نتيجة المزاد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _resultRow('المنتج', auction.title),
            _resultRow('السعر النهائي', '${auction.currentPrice.toStringAsFixed(0)} د.ع'),
            _resultRow('عدد المزايدات', '${auction.bidCount}'),
            if (auction.winnerName != null)
              _resultRow('الفائز', auction.winnerName!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _tabBar,
          const Divider(height: 1),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

