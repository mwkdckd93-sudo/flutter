import 'package:flutter/material.dart';
import 'admin_products_page.dart';
import 'admin_users_page.dart';
import 'admin_categories_page.dart';
import 'admin_reports_page.dart';
import 'admin_settings_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isExpanded = true;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'لوحة التحكم', 'icon': Icons.dashboard_rounded},
    {'title': 'المنتجات', 'icon': Icons.inventory_2_rounded},
    {'title': 'المستخدمين', 'icon': Icons.people_rounded},
    {'title': 'الأقسام', 'icon': Icons.category_rounded},
    {'title': 'التقارير', 'icon': Icons.analytics_rounded},
    {'title': 'الإعدادات', 'icon': Icons.settings_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // Sidebar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isExpanded ? 280 : 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                ),
              ),
              child: Column(
                children: [
                  // Logo Section
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BCD4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.gavel, color: Colors.white, size: 24),
                        ),
                        if (_isExpanded) ...[
                          const SizedBox(width: 12),
                          const Text(
                            'مزاد',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => setState(() => _isExpanded = !_isExpanded),
                            icon: const Icon(Icons.menu_open, color: Colors.white54),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const Divider(color: Colors.white12, height: 1),
                  
                  // Menu Items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        final item = _menuItems[index];
                        final isSelected = _selectedIndex == index;
                        
                        return Tooltip(
                          message: _isExpanded ? '' : item['title'],
                          preferBelow: false,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: _isExpanded ? 16 : 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF00BCD4).withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected 
                                  ? Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3))
                                  : null,
                            ),
                            child: ListTile(
                              onTap: () => setState(() => _selectedIndex = index),
                              leading: Icon(
                                item['icon'],
                                color: isSelected ? const Color(0xFF00BCD4) : Colors.white54,
                                size: 24,
                              ),
                              title: _isExpanded
                                  ? Text(
                                      item['title'],
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFF00BCD4) : Colors.white70,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    )
                                  : null,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: _isExpanded ? 16 : 12,
                                vertical: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Collapse Button (when expanded)
                  if (!_isExpanded)
                    IconButton(
                      onPressed: () => setState(() => _isExpanded = true),
                      icon: const Icon(Icons.menu, color: Colors.white54),
                    ),
                  
                  // Admin Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF00BCD4),
                          child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                        ),
                        if (_isExpanded) ...[
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المدير',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'admin@mazad.com',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.logout, color: Colors.white54, size: 20),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          _menuItems[_selectedIndex]['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a1a2e),
                          ),
                        ),
                        const Spacer(),
                        // Search Bar
                        Container(
                          width: 300,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'بحث...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Notifications
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1a1a2e)),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        // Messages
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.mail_outline, color: Color(0xFF1a1a2e)),
                        ),
                      ],
                    ),
                  ),
                  
                  // Page Content
                  Expanded(
                    child: _buildPageContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const AdminProductsPage();
      case 2:
        return const AdminUsersPage();
      case 3:
        return const AdminCategoriesPage();
      case 4:
        return const AdminReportsPage();
      case 5:
        return const AdminSettingsPage();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards Row
          Row(
            children: [
              _buildStatCard(
                'إجمالي المستخدمين',
                '1,234',
                Icons.people_rounded,
                const Color(0xFF6C5CE7),
                '+12% هذا الشهر',
              ),
              const SizedBox(width: 20),
              _buildStatCard(
                'المنتجات النشطة',
                '567',
                Icons.inventory_2_rounded,
                const Color(0xFF00B894),
                '+8% هذا الأسبوع',
              ),
              const SizedBox(width: 20),
              _buildStatCard(
                'المزادات المكتملة',
                '89',
                Icons.gavel_rounded,
                const Color(0xFFE17055),
                '+15% اليوم',
              ),
              const SizedBox(width: 20),
              _buildStatCard(
                'إجمالي الأرباح',
                '₪ 45,678',
                Icons.attach_money_rounded,
                const Color(0xFF00BCD4),
                '+20% هذا الشهر',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sales Chart
              Expanded(
                flex: 2,
                child: Container(
                  height: 350,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'إحصائيات المبيعات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: 'هذا الأسبوع',
                              underline: const SizedBox(),
                              isDense: true,
                              items: ['اليوم', 'هذا الأسبوع', 'هذا الشهر', 'هذه السنة']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (_) {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _buildSimpleChart(),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Top Categories
              Expanded(
                child: Container(
                  height: 350,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أعلى الأقسام',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildCategoryProgress('إلكترونيات', 0.85, const Color(0xFF6C5CE7)),
                      const SizedBox(height: 16),
                      _buildCategoryProgress('موبايلات', 0.72, const Color(0xFF00B894)),
                      const SizedBox(height: 16),
                      _buildCategoryProgress('أجهزة منزلية', 0.58, const Color(0xFFE17055)),
                      const SizedBox(height: 16),
                      _buildCategoryProgress('كيمينك', 0.45, const Color(0xFF0984E3)),
                      const SizedBox(height: 16),
                      _buildCategoryProgress('أثاث', 0.32, const Color(0xFFFDAA5C)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity & Top Users
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Products
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'أحدث المنتجات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _selectedIndex = 1),
                            child: const Text('عرض الكل'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildRecentProductItem('iPhone 15 Pro Max', 'أحمد محمد', '₪ 4,500', 'نشط'),
                      _buildRecentProductItem('MacBook Pro M3', 'سارة علي', '₪ 6,200', 'نشط'),
                      _buildRecentProductItem('PlayStation 5', 'محمد خالد', '₪ 1,800', 'منتهي'),
                      _buildRecentProductItem('Samsung S24 Ultra', 'فاطمة أحمد', '₪ 3,200', 'نشط'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Top Users
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'أنشط المستخدمين',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _selectedIndex = 2),
                            child: const Text('عرض الكل'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTopUserItem('أحمد محمد', 'ahmed@email.com', 45, 12),
                      _buildTopUserItem('سارة علي', 'sara@email.com', 38, 8),
                      _buildTopUserItem('محمد خالد', 'mohamed@email.com', 32, 15),
                      _buildTopUserItem('فاطمة أحمد', 'fatma@email.com', 28, 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String change) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    change,
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart() {
    final data = [40, 65, 45, 80, 55, 70, 85];
    final days = ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: data[index] * 2.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF00BCD4),
                    const Color(0xFF00BCD4).withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[index],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCategoryProgress(String name, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${(progress * 100).toInt()}%', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentProductItem(String name, String seller, String price, String status) {
    final isActive = status == 'نشط';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(seller, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopUserItem(String name, String email, int bids, int wins) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF00BCD4).withOpacity(0.1),
            child: Text(
              name[0],
              style: const TextStyle(
                color: Color(0xFF00BCD4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$bids مزايدة', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('$wins فوز', style: TextStyle(color: Colors.green[600], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
