import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../auth/login_page.dart';
import '../../../data/models/models.dart';

// Moved from main.dart
class DemoAuctionDetailPage extends StatefulWidget {
  const DemoAuctionDetailPage({super.key});

  @override
  State<DemoAuctionDetailPage> createState() => _DemoAuctionDetailPageState();
}

class _DemoAuctionDetailPageState extends State<DemoAuctionDetailPage> {
  late AuctionModel _mockAuction;
  List<BidModel> _bids = [];
  List<QuestionModel> _questions = [];
  late DateTime _endTime;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initMockData();
    _startTimer();
  }

  void _initMockData() {
    // Set auction to end in 2 hours from now
    _endTime = DateTime.now().add(const Duration(hours: 2, minutes: 15, seconds: 30));
    
    _bids = [
      BidModel(
        id: '3',
        auctionId: 'demo-1',
        bidderId: 'user-3',
        bidderName: 'أحمد محمد',
        amount: 185000,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isWinning: true,
      ),
      BidModel(
        id: '2',
        auctionId: 'demo-1',
        bidderId: 'user-2',
        bidderName: 'علي حسين',
        amount: 175000,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        isAutoBid: true,
      ),
      BidModel(
        id: '1',
        auctionId: 'demo-1',
        bidderId: 'user-1',
        bidderName: 'محمد علي',
        amount: 160000,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    _questions = [
      QuestionModel(
        id: 'q1',
        auctionId: 'demo-1',
        askerId: 'user-4',
        askerName: 'سارة أحمد',
        question: 'هل الجهاز يدعم اللغة العربية؟',
        answer: 'نعم، الجهاز يدعم اللغة العربية بالكامل مع واجهة مستخدم كاملة.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        answeredAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      QuestionModel(
        id: 'q2',
        auctionId: 'demo-1',
        askerId: 'user-5',
        askerName: 'حسين كاظم',
        question: 'هل يوجد ضمان على الجهاز؟',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    _mockAuction = AuctionModel(
      id: 'demo-1',
      title: 'آيفون 15 برو ماكس - 256 جيجا',
      description: '''
جهاز آيفون 15 برو ماكس بحالة ممتازة جداً
- اللون: تيتانيوم طبيعي
- السعة: 256 جيجابايت
- البطارية: 95%
- مستخدم لمدة 3 أشهر فقط
- جميع الملحقات الأصلية متوفرة
- الكرتون الأصلي والفاتورة متوفرة
- لا يوجد أي خدش أو ضرر

سبب البيع: الترقية لجهاز أحدث
''',
      categoryId: 'electronics',
      categoryName: 'إلكترونيات',
      condition: ProductCondition.used,
      warranty: const WarrantyInfo(hasWarranty: true, durationMonths: 9),
      images: [
        'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-7inch-naturaltitanium?wid=800&hei=800&fmt=jpeg',
        'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-7inch-bluetitanium?wid=800&hei=800&fmt=jpeg',
        'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-7inch-whitetitanium?wid=800&hei=800&fmt=jpeg',
      ],
      sellerId: 'seller-1',
      sellerName: 'متجر التقنية',
      sellerRating: 4.8,
      startingPrice: 150000,
      currentPrice: 185000,
      minBidIncrement: 5000,
      bidCount: 3,
      startTime: DateTime.now().subtract(const Duration(days: 1)),
      endTime: _endTime,
      shippingProvinces: ['بغداد', 'البصرة', 'أربيل', 'النجف', 'كربلاء'],
      status: AuctionStatus.active,
      recentBids: _bids,
      questions: _questions,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    );

    _updateTimeRemaining();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _updateTimeRemaining();
        });
        _startTimer();
      }
    });
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    if (now.isAfter(_endTime)) {
      _timeRemaining = Duration.zero;
    } else {
      _timeRemaining = _endTime.difference(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _DemoAuctionContent(
        auction: _mockAuction,
        bids: _bids,
        questions: _questions,
        timeRemaining: _timeRemaining,
        onPlaceBid: _handlePlaceBid,
        onAskQuestion: _handleAskQuestion,
      ),
    );
  }

  void _handlePlaceBid(double amount) {
    setState(() {
      final newBid = BidModel(
        id: 'bid-${_bids.length + 1}',
        auctionId: 'demo-1',
        bidderId: 'current_user',
        bidderName: 'أنت',
        amount: amount,
        createdAt: DateTime.now(),
        isWinning: true,
      );
      
      // Update previous winning bid
      _bids = _bids.map((b) => b.copyWith(isWinning: false)).toList();
      _bids.insert(0, newBid);
      
      _mockAuction = _mockAuction.copyWith(
        currentPrice: amount,
        bidCount: _mockAuction.bidCount + 1,
        recentBids: _bids,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('تم تقديم مزايدتك بنجاح!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleAskQuestion(String question) {
    setState(() {
      final newQuestion = QuestionModel(
        id: 'q-${_questions.length + 1}',
        auctionId: 'demo-1',
        askerId: 'current_user',
        askerName: 'أنت',
        question: question,
        createdAt: DateTime.now(),
      );
      _questions.add(newQuestion);
      _mockAuction = _mockAuction.copyWith(questions: _questions);
    });
  }
}

// Custom content widget for demo
class _DemoAuctionContent extends StatelessWidget {
  final AuctionModel auction;
  final List<BidModel> bids;
  final List<QuestionModel> questions;
  final Duration timeRemaining;
  final Function(double) onPlaceBid;
  final Function(String) onAskQuestion;

  const _DemoAuctionContent({
    required this.auction,
    required this.bids,
    required this.questions,
    required this.timeRemaining,
    required this.onPlaceBid,
    required this.onAskQuestion,
  });

  double get nextMinBid => auction.currentPrice + auction.minBidIncrement;
  bool get hasEnded => timeRemaining <= Duration.zero;
  bool get isAboutToEnd => timeRemaining.inMinutes <= 5 && !hasEnded;

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
                  TabBar(
                    labelColor: const Color(0xFF1E88E5),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF1E88E5),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
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
              _buildDetailsTab(),
              _buildBidsTab(context),
              _buildQnATab(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomActionBar(context),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
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
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.favorite_border, color: Colors.black),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.share_outlined, color: Colors.black),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: auction.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  auction.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 64, color: Colors.grey),
                  ),
                );
              },
            ),
             // Gradient Overlay for text readability if needed
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
          
          // Clean Tags
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

          // Modern Price & Timer Component
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
                      '${auction.currentPrice.toStringAsFixed(0)} د.ع',
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
    
    final h = timeRemaining.inHours;
    final m = timeRemaining.inMinutes.remainder(60);
    final s = timeRemaining.inSeconds.remainder(60);

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

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('الوصف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(auction.description, style: const TextStyle(height: 1.6, color: Colors.black87, fontSize: 15)),
        const SizedBox(height: 24),
        const Text('معلومات البائع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF1E88E5),
            child: Text(auction.sellerName[0], style: const TextStyle(color: Colors.white)),
          ),
          title: Text(auction.sellerName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              Text(' ${auction.sellerRating} • تاجر موثوق', style: const TextStyle(fontSize: 12)),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBidsTab(BuildContext context) {
    if (bids.isEmpty) {
      return const Center(child: Text('لا توجد مزايدات حتى الآن'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bids.length + 1, // +1 for spacer
      itemBuilder: (context, index) {
        if (index == bids.length) return const SizedBox(height: 100);
        final bid = bids[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bid.isWinning ? const Color(0xFFF1F8E9) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: bid.isWinning ? Colors.green.withOpacity(0.3) : Colors.grey.shade100),
            boxShadow: [
              if(bid.isWinning)
                BoxShadow(color: Colors.green.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ]
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: bid.isWinning ? Colors.green : Colors.grey.shade200,
                radius: 20,
                child: Icon(
                  bid.isWinning ? Icons.emoji_events : Icons.person,
                  color: bid.isWinning ? Colors.white : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.bidderName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      _getRelativeTime(bid.createdAt),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '${bid.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: bid.isWinning ? Colors.green : Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQnATab() {
     return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...questions.map((q) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.help_outline, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(q.question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
              if (q.isAnswered) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 26),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(q.answer!, style: TextStyle(color: Colors.grey.shade800)),
                  ),
                ),
              ]
            ],
          ),
        )),
        const SizedBox(height: 100),
      ],
     );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    if (hasEnded) {
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
              onPressed: () {
                final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
                if (!isLoggedIn) {
                   Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const LoginPage())
                  );
                  return;
                }
                onPlaceBid(nextMinBid);
              },
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
              onPressed: () {
                final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
                if (!isLoggedIn) {
                   Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const LoginPage())
                  );
                  return;
                }
                 showDialog(
                  context: context,
                  builder: (context) => _CustomBidDialogDemo(
                    currentPrice: auction.currentPrice,
                    minIncrement: auction.minBidIncrement,
                    onBid: onPlaceBid,
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.black87),
            ),
          )
        ],
      ),
    );
  }

  String _getRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    return 'منذ ${diff.inDays} يوم';
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 1; // Slight trick to avoid overlap issues

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

// Simple custom bid dialog for demo
class _CustomBidDialogDemo extends StatefulWidget {
  final double currentPrice;
  final double minIncrement;
  final Function(double) onBid;

  const _CustomBidDialogDemo({
    required this.currentPrice,
    required this.minIncrement,
    required this.onBid,
  });

  @override
  State<_CustomBidDialogDemo> createState() => _CustomBidDialogDemoState();
}

class _CustomBidDialogDemoState extends State<_CustomBidDialogDemo> {
  late double _bidAmount;

  @override
  void initState() {
    super.initState();
    _bidAmount = widget.currentPrice + widget.minIncrement;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('مزايدة مخصصة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('السعر الحالي: ${widget.currentPrice.toStringAsFixed(0)} د.ع'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _bidAmount > widget.currentPrice + widget.minIncrement
                    ? () => setState(() => _bidAmount -= widget.minIncrement)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '${_bidAmount.toStringAsFixed(0)} د.ع',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => setState(() => _bidAmount += widget.minIncrement),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            widget.onBid(_bidAmount);
            Navigator.pop(context);
          },
          child: const Text('تأكيد المزايدة'),
        ),
      ],
    );
  }
}
