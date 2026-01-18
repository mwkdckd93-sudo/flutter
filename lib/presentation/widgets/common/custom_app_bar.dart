import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom AppBar with modern design
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final bool showSearch;
  final bool showNotifications;
  final bool showBack;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool transparent;
  final Widget? bottom;
  final double elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.showSearch = false,
    this.showNotifications = false,
    this.showBack = false,
    this.onSearchTap,
    this.onNotificationTap,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.transparent = false,
    this.bottom,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    bottom != null ? kToolbarHeight + 48 : kToolbarHeight,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: transparent ? null : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundColor != null 
            ? [backgroundColor!, backgroundColor!]
            : [
                const Color(0xFF1E88E5),
                const Color(0xFF1565C0),
              ],
        ),
        boxShadow: transparent ? null : [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: centerTitle,
        leading: _buildLeading(context),
        title: _buildTitle(context),
        actions: _buildActions(context),
        bottom: bottom != null ? PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: bottom!,
        ) : null,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    
    if (showBack || Navigator.canPop(context)) {
      return Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      );
    }
    
    return null;
  }

  Widget _buildTitle(BuildContext context) {
    if (showLogo) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: Color(0xFF1E88E5),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // App Name with gradient effect
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFE3F2FD)],
            ).createShader(bounds),
            child: const Text(
              'مزاد',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      );
    }
    
    if (title != null) {
      return Text(
        title!,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> actionWidgets = [];
    
    if (showSearch) {
      actionWidgets.add(
        _ActionButton(
          icon: Icons.search_rounded,
          onTap: onSearchTap ?? () {
            // Default search action
          },
        ),
      );
    }
    
    if (showNotifications) {
      actionWidgets.add(
        _NotificationButton(
          onTap: onNotificationTap ?? () {
            // Default notification action
          },
        ),
      );
    }
    
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }
    
    if (actionWidgets.isNotEmpty) {
      actionWidgets.add(const SizedBox(width: 8));
    }
    
    return actionWidgets;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? Colors.white, size: 22),
        onPressed: onTap,
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback onTap;
  final int unreadCount;

  const _NotificationButton({
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
            onPressed: onTap,
          ),
          if (unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Sliver AppBar version for scrollable pages
class CustomSliverAppBar extends StatelessWidget {
  final String? title;
  final bool showLogo;
  final bool showSearch;
  final bool showNotifications;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final List<Widget>? actions;
  final Widget? flexibleSpace;
  final double expandedHeight;
  final bool pinned;
  final bool floating;

  const CustomSliverAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.showSearch = false,
    this.showNotifications = false,
    this.onSearchTap,
    this.onNotificationTap,
    this.actions,
    this.flexibleSpace,
    this.expandedHeight = 120,
    this.pinned = true,
    this.floating = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      backgroundColor: const Color(0xFF1E88E5),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E88E5),
                Color(0xFF1565C0),
              ],
            ),
          ),
          child: flexibleSpace,
        ),
        title: showLogo ? _buildLogo() : (title != null ? Text(
          title!,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ) : null),
        centerTitle: true,
      ),
      leading: Navigator.canPop(context) ? Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ) : null,
      actions: _buildActions(context),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.gavel_rounded,
            color: Color(0xFF1E88E5),
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'مزاد',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> actionWidgets = [];
    
    if (showSearch) {
      actionWidgets.add(
        _ActionButton(
          icon: Icons.search_rounded,
          onTap: onSearchTap ?? () {},
        ),
      );
    }
    
    if (showNotifications) {
      actionWidgets.add(
        _NotificationButton(
          onTap: onNotificationTap ?? () {},
        ),
      );
    }
    
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }
    
    return actionWidgets;
  }
}

/// Simple page header for internal pages
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E88E5),
            Color(0xFF1565C0),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (Navigator.canPop(context)) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}
