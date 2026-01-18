import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../data/services/socket_service.dart';
import '../../core/constants/app_colors.dart';
import 'auth/login_page.dart';
import 'home/home_page.dart';
import 'explore/explore_page.dart';
import 'activity/activity_page.dart';
import 'profile/profile_page.dart';
import 'reels/reels_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = [
    const HomePage(),
    const ExplorePage(),
    const ReelsPage(),
    const ActivityPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    
    // Connect to Socket as guest if not logged in for real-time updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isLoggedIn) {
        SocketService.instance.connectAsGuest();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    // Check for protected tabs (مزاداتي، حسابي)
    if (index == 3 || index == 4) {
      final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
      if (!isLoggedIn) {
        // Jump back to previous page and show login
        _pageController.jumpToPage(_currentIndex);
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const LoginPage())
        );
        return;
      }
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.3),
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
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'الرئيسية',
                isSelected: _currentIndex == 0,
                isDark: isDark,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.category_outlined,
                selectedIcon: Icons.category,
                label: 'الأقسام',
                isSelected: _currentIndex == 1,
                isDark: isDark,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.video_library_outlined,
                selectedIcon: Icons.video_library,
                label: 'ريلز',
                isSelected: _currentIndex == 2,
                isDark: isDark,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.gavel_outlined,
                selectedIcon: Icons.gavel,
                label: 'مزاداتي',
                isSelected: _currentIndex == 3,
                isDark: isDark,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'حسابي',
                isSelected: _currentIndex == 4,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required bool isDark,
  }) {
    final accentColor = isDark ? AppColors.primaryDarkTheme : const Color(0xFF00BCD4);
    
    return GestureDetector(
      onTap: () {
        // Check for protected tabs (مزاداتي، حسابي)
        if (index == 3 || index == 4) {
          final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
          if (!isLoggedIn) {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const LoginPage())
            );
            return;
          }
        }
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? accentColor : Colors.white60,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
