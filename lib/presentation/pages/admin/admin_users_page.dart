import 'package:flutter/material.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _selectedFilter = 'الكل';
  String _searchQuery = '';
  int _selectedUserIndex = -1;

  final List<Map<String, dynamic>> _users = [
    {
      'id': 'USR-001',
      'name': 'أحمد محمد',
      'email': 'ahmed@email.com',
      'phone': '0501234567',
      'avatar': null,
      'status': 'نشط',
      'role': 'مستخدم',
      'joinDate': '2023-06-15',
      'lastActive': '2024-01-12 14:30',
      'productsListed': [
        {'title': 'iPhone 15 Pro Max', 'status': 'نشط', 'price': 4500},
        {'title': 'AirPods Pro 2', 'status': 'منتهي', 'price': 800},
      ],
      'bidsPlaced': [
        {'title': 'MacBook Pro M3', 'amount': 6200, 'status': 'أعلى مزايد'},
        {'title': 'Samsung TV 65"', 'amount': 2500, 'status': 'تم التخطي'},
      ],
      'auctionsWon': [
        {'title': 'PlayStation 4 Pro', 'price': 1200, 'date': '2023-12-20'},
        {'title': 'Nintendo Switch', 'price': 850, 'date': '2023-11-15'},
      ],
      'auctionsLost': [
        {'title': 'iPad Pro 12.9', 'myBid': 2800, 'winningBid': 3200, 'date': '2023-12-01'},
      ],
      'totalSpent': 2050,
      'totalEarned': 5300,
    },
    {
      'id': 'USR-002',
      'name': 'سارة علي',
      'email': 'sara@email.com',
      'phone': '0509876543',
      'avatar': null,
      'status': 'نشط',
      'role': 'بائع معتمد',
      'joinDate': '2023-04-20',
      'lastActive': '2024-01-12 16:45',
      'productsListed': [
        {'title': 'MacBook Pro M3 Max', 'status': 'نشط', 'price': 6200},
        {'title': 'iPhone 14 Pro', 'status': 'منتهي', 'price': 3500},
        {'title': 'Apple Watch Series 9', 'status': 'نشط', 'price': 1500},
      ],
      'bidsPlaced': [
        {'title': 'Camera Sony A7IV', 'amount': 5500, 'status': 'تم التخطي'},
      ],
      'auctionsWon': [
        {'title': 'Dell Monitor 27"', 'price': 900, 'date': '2023-10-10'},
      ],
      'auctionsLost': [],
      'totalSpent': 900,
      'totalEarned': 11200,
    },
    {
      'id': 'USR-003',
      'name': 'محمد خالد',
      'email': 'mohamed@email.com',
      'phone': '0551112233',
      'avatar': null,
      'status': 'نشط',
      'role': 'مستخدم',
      'joinDate': '2023-08-01',
      'lastActive': '2024-01-11 22:10',
      'productsListed': [
        {'title': 'PlayStation 5', 'status': 'منتهي', 'price': 1800},
      ],
      'bidsPlaced': [
        {'title': 'iPhone 15 Pro Max', 'amount': 4200, 'status': 'تم التخطي'},
        {'title': 'MacBook Air M2', 'amount': 3800, 'status': 'أعلى مزايد'},
      ],
      'auctionsWon': [
        {'title': 'Xbox Series X', 'price': 1600, 'date': '2023-09-25'},
      ],
      'auctionsLost': [
        {'title': 'iPhone 15 Pro Max', 'myBid': 4200, 'winningBid': 4500, 'date': '2024-01-10'},
      ],
      'totalSpent': 1600,
      'totalEarned': 1800,
    },
    {
      'id': 'USR-004',
      'name': 'فاطمة أحمد',
      'email': 'fatma@email.com',
      'phone': '0567891234',
      'avatar': null,
      'status': 'موقوف',
      'role': 'مستخدم',
      'joinDate': '2023-09-10',
      'lastActive': '2024-01-05 10:00',
      'productsListed': [
        {'title': 'Samsung Galaxy S24 Ultra', 'status': 'نشط', 'price': 3200},
      ],
      'bidsPlaced': [
        {'title': 'iPhone 15 Pro Max', 'amount': 4000, 'status': 'تم التخطي'},
      ],
      'auctionsWon': [],
      'auctionsLost': [
        {'title': 'iPhone 15 Pro Max', 'myBid': 4000, 'winningBid': 4500, 'date': '2024-01-10'},
      ],
      'totalSpent': 0,
      'totalEarned': 0,
    },
    {
      'id': 'USR-005',
      'name': 'خالد سعيد',
      'email': 'khaled@email.com',
      'phone': '0523456789',
      'avatar': null,
      'status': 'قيد التحقق',
      'role': 'مستخدم',
      'joinDate': '2024-01-10',
      'lastActive': '2024-01-12 09:15',
      'productsListed': [
        {'title': 'Apple Watch Ultra 2', 'status': 'قيد المراجعة', 'price': 2500},
      ],
      'bidsPlaced': [],
      'auctionsWon': [],
      'auctionsLost': [],
      'totalSpent': 0,
      'totalEarned': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((u) {
      final matchesFilter = _selectedFilter == 'الكل' || u['status'] == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty || 
          u['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['phone'].toString().contains(_searchQuery);
      return matchesFilter && matchesSearch;
    }).toList();

    return Row(
      children: [
        // Users List
        Expanded(
          flex: _selectedUserIndex >= 0 ? 2 : 3,
          child: Container(
            margin: const EdgeInsets.all(24),
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
              children: [
                // Header & Filters
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'قائمة المستخدمين',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 250,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              onChanged: (v) => setState(() => _searchQuery = v),
                              decoration: InputDecoration(
                                hintText: 'بحث بالاسم أو البريد أو الهاتف...',
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                                prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.file_download, size: 18),
                            label: const Text('تصدير'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1a1a2e),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Filter Chips
                      Row(
                        children: [
                          _buildFilterChip('الكل', _users.length),
                          _buildFilterChip('نشط', _users.where((u) => u['status'] == 'نشط').length),
                          _buildFilterChip('موقوف', _users.where((u) => u['status'] == 'موقوف').length),
                          _buildFilterChip('قيد التحقق', _users.where((u) => u['status'] == 'قيد التحقق').length),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: const Color(0xFFF8F9FA),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Text('المستخدم', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('معلومات الاتصال', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('الدور', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('المنتجات', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 100, child: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                
                // Users List
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isSelected = _selectedUserIndex == index;
                      
                      return InkWell(
                        onTap: () => setState(() => _selectedUserIndex = isSelected ? -1 : index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF00BCD4).withOpacity(0.05) : null,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                              right: isSelected 
                                  ? const BorderSide(color: Color(0xFF00BCD4), width: 3)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: const Color(0xFF00BCD4).withOpacity(0.1),
                                      child: Text(
                                        user['name'][0],
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
                                          Text(
                                            user['name'],
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            'منذ ${user['joinDate']}',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user['email'], style: const TextStyle(fontSize: 13)),
                                    Text(user['phone'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: _buildRoleBadge(user['role']),
                              ),
                              Expanded(
                                child: Text('${(user['productsListed'] as List).length}'),
                              ),
                              Expanded(
                                child: _buildStatusBadge(user['status']),
                              ),
                              SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => setState(() => _selectedUserIndex = index),
                                      icon: const Icon(Icons.visibility, size: 18),
                                      tooltip: 'عرض',
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 18),
                                      onSelected: (value) {},
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                                        const PopupMenuItem(value: 'suspend', child: Text('إيقاف')),
                                        const PopupMenuItem(value: 'delete', child: Text('حذف')),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // User Details Panel
        if (_selectedUserIndex >= 0)
          Expanded(
            flex: 2,
            child: _buildUserDetails(filteredUsers[_selectedUserIndex]),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedFilter = label),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF00BCD4).withOpacity(0.1),
        checkmarkColor: const Color(0xFF00BCD4),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF00BCD4) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? const Color(0xFF00BCD4) : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'نشط':
        color = Colors.green;
        break;
      case 'موقوف':
        color = Colors.red;
        break;
      case 'قيد التحقق':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final isVerified = role == 'بائع معتمد';
    return Row(
      children: [
        if (isVerified)
          const Icon(Icons.verified, color: Color(0xFF00BCD4), size: 16),
        if (isVerified) const SizedBox(width: 4),
        Text(
          role,
          style: TextStyle(
            color: isVerified ? const Color(0xFF00BCD4) : Colors.grey[700],
            fontWeight: isVerified ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetails(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 24, 24, 24),
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
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1a1a2e),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF00BCD4),
                  child: Text(
                    user['name'][0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user['role'] == 'بائع معتمد') ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.verified, color: Color(0xFF00BCD4), size: 18),
                          ],
                        ],
                      ),
                      Text(
                        user['email'],
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _selectedUserIndex = -1),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  Container(
                    color: Colors.grey[50],
                    child: const TabBar(
                      labelColor: Color(0xFF00BCD4),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Color(0xFF00BCD4),
                      tabs: [
                        Tab(text: 'نظرة عامة'),
                        Tab(text: 'المنتجات'),
                        Tab(text: 'المزايدات'),
                        Tab(text: 'الفوز/الخسارة'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildOverviewTab(user),
                        _buildProductsTab(user),
                        _buildBidsTab(user),
                        _buildResultsTab(user),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              _buildMiniStatCard('إجمالي الإنفاق', '₪ ${user['totalSpent']}', Icons.shopping_cart, Colors.orange),
              const SizedBox(width: 12),
              _buildMiniStatCard('إجمالي الأرباح', '₪ ${user['totalEarned']}', Icons.attach_money, Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStatCard('المنتجات', '${(user['productsListed'] as List).length}', Icons.inventory, Colors.blue),
              const SizedBox(width: 12),
              _buildMiniStatCard('المزايدات', '${(user['bidsPlaced'] as List).length}', Icons.gavel, Colors.purple),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // User Info
          const Text('معلومات المستخدم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildInfoTile(Icons.badge, 'رقم المستخدم', user['id']),
          _buildInfoTile(Icons.phone, 'رقم الهاتف', user['phone']),
          _buildInfoTile(Icons.email, 'البريد الإلكتروني', user['email']),
          _buildInfoTile(Icons.calendar_today, 'تاريخ الانضمام', user['joinDate']),
          _buildInfoTile(Icons.access_time, 'آخر نشاط', user['lastActive']),
          
          const SizedBox(height: 24),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.message),
                  label: const Text('مراسلة'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF00BCD4)),
                    foregroundColor: const Color(0xFF00BCD4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(user['status'] == 'موقوف' ? Icons.check : Icons.block),
                  label: Text(user['status'] == 'موقوف' ? 'تفعيل' : 'إيقاف'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user['status'] == 'موقوف' ? Colors.green : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(Map<String, dynamic> user) {
    final products = user['productsListed'] as List;
    
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('لا توجد منتجات', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('₪ ${product['price']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              _buildStatusBadge(product['status']),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBidsTab(Map<String, dynamic> user) {
    final bids = user['bidsPlaced'] as List;
    
    if (bids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('لا توجد مزايدات', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bids.length,
      itemBuilder: (context, index) {
        final bid = bids[index];
        final isHighest = bid['status'] == 'أعلى مزايد';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHighest ? Colors.green.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighest ? Colors.green.withOpacity(0.3) : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.gavel,
                color: isHighest ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bid['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('₪ ${bid['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isHighest ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bid['status'],
                  style: TextStyle(
                    color: isHighest ? Colors.green : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsTab(Map<String, dynamic> user) {
    final won = user['auctionsWon'] as List;
    final lost = user['auctionsLost'] as List;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Won Section
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text('المزادات الرابحة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${won.length}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (won.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text('لا توجد مزادات رابحة', style: TextStyle(color: Colors.grey[600]))),
            )
          else
            ...won.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(item['date'], style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      ],
                    ),
                  ),
                  Text('₪ ${item['price']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          
          const SizedBox(height: 24),
          
          // Lost Section
          Row(
            children: [
              const Icon(Icons.close, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text('المزادات الخاسرة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${lost.length}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (lost.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text('لا توجد مزادات خاسرة', style: TextStyle(color: Colors.grey[600]))),
            )
          else
            ...lost.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('مزايدتك: ₪ ${item['myBid']} | الفائز: ₪ ${item['winningBid']}', 
                          style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(item['date'], style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[500], size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
