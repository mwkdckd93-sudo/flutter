import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/reel_model.dart';
import '../../../providers/reels_provider.dart';
import '../../../providers/auth_provider.dart';
import '../auction/auction_detail_page.dart';
import '../profile/user_profile_page.dart';
import 'upload_reel_page.dart';

/// Reels Page - TikTok style vertical video feed
class ReelsPage extends StatefulWidget {
  final String? initialReelId;
  final String? auctionId;
  final String? userId;
  final bool showBackButton;
  final bool showBottomNav;

  const ReelsPage({
    super.key,
    this.initialReelId,
    this.auctionId,
    this.userId,
    this.showBackButton = false,
    this.showBottomNav = false,
  });

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late PageController _pageController;
  final Map<int, VideoPlayerController> _videoControllers = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Hide status bar for immersive experience (only if not showing bottom nav)
    if (!widget.showBottomNav) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    
    // Load reels
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReelsProvider>().loadReels(
        auctionId: widget.auctionId,
        userId: widget.userId,
        refresh: true,
      );
    });
  }

  @override
  void dispose() {
    // Restore system UI (only if we hid it)
    if (!widget.showBottomNav) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    
    _pageController.dispose();
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initVideoController(int index, String videoUrl) {
    if (_videoControllers.containsKey(index)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _videoControllers[index] = controller;

    controller.initialize().then((_) {
      if (mounted && index == _currentPage) {
        controller.setLooping(true);
        controller.play();
        setState(() {});
      }
    });
  }

  void _onPageChanged(int index) {
    // Pause previous video
    _videoControllers[_currentPage]?.pause();
    
    // Update state
    setState(() {
      _currentPage = index;
    });
    
    // Play current video
    _videoControllers[index]?.play();
    
    // Update provider
    context.read<ReelsProvider>().setCurrentIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ReelsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.reels.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.reels.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library_outlined, 
                       size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد ريلز',
                    style: TextStyle(color: Colors.grey[400], fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Video PageView
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: provider.reels.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final reel = provider.reels[index];
                  _initVideoController(index, reel.videoUrl);
                  
                  return _ReelItem(
                    reel: reel,
                    controller: _videoControllers[index],
                    isActive: index == _currentPage,
                    onLike: () => provider.toggleLike(reel.id),
                    onComment: () => _showCommentsSheet(reel),
                    onShare: () => _shareReel(reel),
                    onAuctionTap: () => _openAuction(reel.auctionId),
                    onPauseVideo: () {
                      _videoControllers[_currentPage]?.setVolume(0);
                      _videoControllers[_currentPage]?.pause();
                    },
                    onResumeVideo: () {
                      _videoControllers[_currentPage]?.setVolume(1);
                      _videoControllers[_currentPage]?.play();
                    },
                  );
                },
              ),
              
              // Back button (only when opened from another page)
              if (widget.showBackButton)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              
              // Upload button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 32),
                  onPressed: () {
                    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
                    if (!isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى تسجيل الدخول لرفع ريل')),
                      );
                      return;
                    }
                    // Pause video before navigating
                    _videoControllers[_currentPage]?.setVolume(0);
                    _videoControllers[_currentPage]?.pause();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UploadReelPage()),
                    ).then((_) {
                      // Resume video when coming back
                      _videoControllers[_currentPage]?.setVolume(1);
                      _videoControllers[_currentPage]?.play();
                    });
                  },
                  tooltip: 'رفع ريل',
                ),
              ),
              
              // Refresh button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 50,
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                  onPressed: () {
                    // Clear existing controllers
                    for (final controller in _videoControllers.values) {
                      controller.dispose();
                    }
                    _videoControllers.clear();
                    setState(() {
                      _currentPage = 0;
                    });
                    _pageController.jumpToPage(0);
                    provider.loadReels(refresh: true);
                  },
                  tooltip: 'تحديث',
                ),
              ),
              
              // Back button when showing bottom nav (opened from profile)
              if (widget.showBottomNav)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              
              // Bottom navigation bar when showBottomNav is true
              if (widget.showBottomNav)
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a1a2e),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(Icons.home_outlined, 'الرئيسية', () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }),
                          _buildNavItem(Icons.category_outlined, 'الأقسام', () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }),
                          _buildNavItem(Icons.video_library, 'ريلز', null, isSelected: true),
                          _buildNavItem(Icons.gavel_outlined, 'مزاداتي', () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }),
                          _buildNavItem(Icons.person, 'حسابي', () {
                            Navigator.of(context).pop();
                          }, isSelected: false),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback? onTap, {bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF00BCD4) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00BCD4) : Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsSheet(ReelModel reel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsSheet(reel: reel),
    );
  }

  void _shareReel(ReelModel reel) {
    // Deep link for app sharing
    final deepLink = 'mazad://reels/${reel.id}';
    final webLink = 'https://mazad.app/reels/${reel.id}';
    
    Share.share(
      '🎬 شاهد هذا المنتج على مزاد!\n\n'
      '📦 ${reel.auctionTitle}\n'
      '💰 ${reel.auctionPrice.toStringAsFixed(0)} د.ع\n\n'
      '📱 افتح في التطبيق:\n$deepLink\n\n'
      '🌐 أو من المتصفح:\n$webLink',
      subject: 'ريل من مزاد - ${reel.auctionTitle}',
    );
  }

  void _openAuction(String auctionId) {
    // Pause video and mute before navigating
    _videoControllers[_currentPage]?.setVolume(0);
    _videoControllers[_currentPage]?.pause();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuctionDetailPage(auctionId: auctionId),
      ),
    ).then((_) {
      // Resume video and unmute when coming back
      _videoControllers[_currentPage]?.setVolume(1);
      _videoControllers[_currentPage]?.play();
    });
  }
}

/// Single Reel Item with animations
class _ReelItem extends StatefulWidget {
  final ReelModel reel;
  final VideoPlayerController? controller;
  final bool isActive;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onAuctionTap;
  final VoidCallback? onPauseVideo;
  final VoidCallback? onResumeVideo;

  const _ReelItem({
    required this.reel,
    this.controller,
    required this.isActive,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onAuctionTap,
    this.onPauseVideo,
    this.onResumeVideo,
  });

  @override
  State<_ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<_ReelItem> with SingleTickerProviderStateMixin {
  bool _showPlayPauseIcon = false;
  bool _isPlaying = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    widget.controller?.addListener(_videoListener);
  }

  void _videoListener() {
    if (mounted) {
      final isPlaying = widget.controller?.value.isPlaying ?? false;
      if (_isPlaying != isPlaying) {
        setState(() => _isPlaying = isPlaying);
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_videoListener);
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (widget.controller?.value.isPlaying ?? false) {
      widget.controller?.pause();
      _showIcon(false);
    } else {
      widget.controller?.play();
      _showIcon(true);
    }
  }

  void _showIcon(bool isPlaying) {
    setState(() {
      _showPlayPauseIcon = true;
      _isPlaying = isPlaying;
    });
    
    _animationController.reset();
    _animationController.forward().then((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _showPlayPauseIcon = false);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final reel = widget.reel;
    
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video - Full screen with cover fit
          if (controller?.value.isInitialized ?? false)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller!.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            )
          else
            // Loading animation
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated loading spinner
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 6.28,
                          child: child,
                        );
                      },
                      onEnd: () {},
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'جاري التحميل...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Play/Pause animation overlay
          if (_showPlayPauseIcon)
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // Paused indicator (small)
          if (!(controller?.value.isPlaying ?? true) && !_showPlayPauseIcon && (controller?.value.isInitialized ?? false))
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white70,
                  size: 40,
                ),
              ),
            ),

          // Gradient overlay - top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Gradient overlay - bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Action buttons (right side)
          Positioned(
            right: 12,
            bottom: 140,
            child: Column(
              children: [
                // Like button with animation
                _AnimatedLikeButton(
                  isLiked: reel.isLiked,
                  count: reel.likesCount,
                  onTap: widget.onLike,
                ),
                const SizedBox(height: 16),
                
                // Comment button
                _ActionButton(
                  icon: Icons.comment_outlined,
                  label: _formatCount(reel.commentsCount),
                  onTap: widget.onComment,
                ),
                const SizedBox(height: 16),
                
                // Share button
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'مشاركة',
                  onTap: widget.onShare,
                ),
                const SizedBox(height: 16),
                
                // Views count
                Column(
                  children: [
                    const Icon(Icons.visibility, color: Colors.white70, size: 24),
                    const SizedBox(height: 2),
                    Text(
                      _formatCount(reel.viewsCount),
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom info (left side)
          Positioned(
            left: 16,
            right: 70,
            bottom: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // User info - Clickable to open profile
                GestureDetector(
                  onTap: () {
                    // Pause video before navigating
                    widget.onPauseVideo?.call();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfilePage(
                          userId: reel.userId,
                          userName: reel.userName,
                        ),
                      ),
                    ).then((_) {
                      // Resume video when coming back
                      widget.onResumeVideo?.call();
                    });
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: reel.userAvatar != null
                            ? NetworkImage(reel.userAvatar!)
                            : null,
                        child: reel.userAvatar == null
                            ? const Icon(Icons.person, size: 18, color: Colors.white70)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          reel.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
                
                // Caption
                if (reel.caption != null && reel.caption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      reel.caption!,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                
                const SizedBox(height: 10),
                
                // Auction card - compact
                GestureDetector(
                  onTap: widget.onAuctionTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Auction image
                        if (reel.auctionImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              reel.auctionImage!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey[800],
                                child: const Icon(Icons.image, color: Colors.white54, size: 20),
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),
                        
                        // Auction info
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                reel.auctionTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${_formatPrice(reel.auctionPrice)} د.ع',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Bid button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'زايد',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toStringAsFixed(0);
  }
}

/// Animated Like Button
class _AnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final int count;
  final VoidCallback onTap;

  const _AnimatedLikeButton({
    required this.isLiked,
    required this.count,
    required this.onTap,
  });

  @override
  State<_AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<_AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_AnimatedLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked && !oldWidget.isLiked) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        if (!widget.isLiked) {
          _controller.forward().then((_) => _controller.reverse());
        }
      },
      child: Column(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              widget.isLiked ? Icons.favorite : Icons.favorite_border,
              color: widget.isLiked ? Colors.red : Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatCount(widget.count),
            style: TextStyle(
              color: widget.isLiked ? Colors.red : Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Comments Bottom Sheet
class _CommentsSheet extends StatefulWidget {
  final ReelModel reel;

  const _CommentsSheet({required this.reel});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    context.read<ReelsProvider>().loadComments(widget.reel.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول للتعليق')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await context.read<ReelsProvider>().addComment(widget.reel.id, text);
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'التعليقات (${widget.reel.commentsCount})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const Divider(height: 1),
          
          // Comments list
          Expanded(
            child: Consumer<ReelsProvider>(
              builder: (context, provider, child) {
                if (provider.comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد تعليقات بعد',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.comments.length,
                  itemBuilder: (context, index) {
                    final comment = provider.comments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: comment.userAvatar != null
                                ? NetworkImage(comment.userAvatar!)
                                : null,
                            child: comment.userAvatar == null
                                ? const Icon(Icons.person, size: 18)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(comment.comment),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Comment input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'اكتب تعليقاً...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _isSending ? null : _sendComment,
                  icon: _isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.send,
                          color: Theme.of(context).primaryColor,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
