import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../core/constants/app_colors.dart';

/// Theme Settings Page - تغيير المظهر
class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('المظهر'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Preview Card
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.surfaceDark,
                            AppColors.backgroundDark,
                          ]
                        : [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.secondary.withOpacity(0.1),
                          ],
                  ),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Stack(
                  children: [
                    // Moon/Sun Animation
                    Positioned(
                      top: 30,
                      right: 30,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return RotationTransition(
                            turns: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          key: ValueKey(isDark),
                          size: 60,
                          color: isDark 
                              ? AppColors.secondaryDarkTheme 
                              : AppColors.secondary,
                        ),
                      ),
                    ),
                    // Theme Name
                    Positioned(
                      bottom: 30,
                      left: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isDark 
                                ? 'مريح للعين في الإضاءة المنخفضة' 
                                : 'مثالي للاستخدام النهاري',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark 
                                  ? AppColors.textSecondaryDark 
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Theme Options
              Text(
                'اختر المظهر',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Light Mode
              _ThemeOptionCard(
                icon: Icons.light_mode,
                title: 'فاتح',
                subtitle: 'الوضع الكلاسيكي الفاتح',
                isSelected: themeProvider.themeMode == ThemeMode.light,
                onTap: () => themeProvider.setLightMode(),
                iconColor: AppColors.secondary,
              ),
              
              const SizedBox(height: 12),
              
              // Dark Mode
              _ThemeOptionCard(
                icon: Icons.dark_mode,
                title: 'داكن',
                subtitle: 'وضع مظلم مريح للعين',
                isSelected: themeProvider.themeMode == ThemeMode.dark,
                onTap: () => themeProvider.setDarkMode(),
                iconColor: AppColors.primaryDarkTheme,
              ),
              
              const SizedBox(height: 12),
              
              // System Mode
              _ThemeOptionCard(
                icon: Icons.settings_suggest,
                title: 'تلقائي',
                subtitle: 'يتبع إعدادات النظام',
                isSelected: themeProvider.themeMode == ThemeMode.system,
                onTap: () => themeProvider.setSystemMode(),
                iconColor: AppColors.success,
              ),
              
              const SizedBox(height: 32),
              
              // Quick Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppColors.surfaceVariantDark 
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.swap_horiz,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تبديل سريع',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'انتقل بين الفاتح والداكن',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeColor: theme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Color iconColor;

  const _ThemeOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.1)
                : isDark
                    ? AppColors.surfaceDark
                    : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.primaryColor
                  : isDark
                      ? AppColors.borderDark
                      : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
