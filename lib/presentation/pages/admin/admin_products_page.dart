import 'package:flutter/material.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  String _selectedFilter = 'الكل';
  String _searchQuery = '';
  int _selectedProductIndex = -1;

  final List<Map<String, dynamic>> _products = [
    {
      'id': 'PRD-001',
      'title': 'iPhone 15 Pro Max 256GB',
      'description': 'هاتف آيفون 15 برو ماكس بحالة ممتازة، لون تيتانيوم',
      'seller': {'name': 'أحمد محمد', 'phone': '0501234567', 'email': 'ahmed@email.com'},
      'category': 'موبايلات',
      'startPrice': 3500,
      'currentPrice': 4500,
      'status': 'نشط',
      'condition': 'جديد',
      'startDate': '2024-01-01',
      'endDate': '2024-01-15',
      'views': 234,
      'bidders': [
        {'name': 'سارة علي', 'amount': 4500, 'time': '2024-01-10 14:30'},
        {'name': 'محمد خالد', 'amount': 4200, 'time': '2024-01-10 12:15'},
        {'name': 'فاطمة أحمد', 'amount': 4000, 'time': '2024-01-09 18:45'},
        {'name': 'خالد سعيد', 'amount': 3800, 'time': '2024-01-08 10:20'},
      ],
      'images': ['image1.jpg', 'image2.jpg', 'image3.jpg'],
    },
    {
      'id': 'PRD-002',
      'title': 'MacBook Pro M3 Max',
      'description': 'لابتوب ماك بوك برو بمعالج M3 Max، رام 32GB',
      'seller': {'name': 'سارة علي', 'phone': '0509876543', 'email': 'sara@email.com'},
      'category': 'إلكترونيات',
      'startPrice': 5000,
      'currentPrice': 6200,
      'status': 'نشط',
      'condition': 'مستعمل',
      'startDate': '2024-01-02',
      'endDate': '2024-01-16',
      'views': 189,
      'bidders': [
        {'name': 'أحمد محمد', 'amount': 6200, 'time': '2024-01-11 09:00'},
        {'name': 'علي حسن', 'amount': 5800, 'time': '2024-01-10 22:30'},
      ],
      'images': ['image1.jpg', 'image2.jpg'],
    },
    {
      'id': 'PRD-003',
      'title': 'PlayStation 5 + 2 Controllers',
      'description': 'بلايستيشن 5 مع يدين تحكم وألعاب',
      'seller': {'name': 'محمد خالد', 'phone': '0551112233', 'email': 'mohamed@email.com'},
      'category': 'كيمينك',
      'startPrice': 1200,
      'currentPrice': 1800,
      'status': 'منتهي',
      'condition': 'مستعمل',
      'startDate': '2023-12-20',
      'endDate': '2024-01-05',
      'views': 456,
      'bidders': [
        {'name': 'عمر سعيد', 'amount': 1800, 'time': '2024-01-05 23:55'},
        {'name': 'يوسف أحمد', 'amount': 1650, 'time': '2024-01-05 20:10'},
        {'name': 'ناصر علي', 'amount': 1500, 'time': '2024-01-04 15:00'},
      ],
      'winner': 'عمر سعيد',
      'images': ['image1.jpg'],
    },
    {
      'id': 'PRD-004',
      'title': 'Samsung Galaxy S24 Ultra',
      'description': 'سامسونج S24 الترا جديد بالكرتون',
      'seller': {'name': 'فاطمة أحمد', 'phone': '0567891234', 'email': 'fatma@email.com'},
      'category': 'موبايلات',
      'startPrice': 2800,
      'currentPrice': 3200,
      'status': 'نشط',
      'condition': 'جديد',
      'startDate': '2024-01-05',
      'endDate': '2024-01-20',
      'views': 167,
      'bidders': [
        {'name': 'هند محمد', 'amount': 3200, 'time': '2024-01-12 11:30'},
        {'name': 'سلمى علي', 'amount': 3000, 'time': '2024-01-11 16:45'},
      ],
      'images': ['image1.jpg', 'image2.jpg'],
    },
    {
      'id': 'PRD-005',
      'title': 'Apple Watch Ultra 2',
      'description': 'ساعة أبل ووتش الترا 2 بالضمان',
      'seller': {'name': 'خالد سعيد', 'phone': '0523456789', 'email': 'khaled@email.com'},
      'category': 'ساعات',
      'startPrice': 2500,
      'currentPrice': 2500,
      'status': 'قيد المراجعة',
      'condition': 'جديد',
      'startDate': '2024-01-12',
      'endDate': '2024-01-27',
      'views': 45,
      'bidders': [],
      'images': ['image1.jpg'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((p) {
      final matchesFilter = _selectedFilter == 'الكل' || p['status'] == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty || 
          p['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['seller']['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Row(
      children: [
        // Products List
        Expanded(
          flex: _selectedProductIndex >= 0 ? 2 : 3,
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
                            'قائمة المنتجات',
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
                                hintText: 'بحث...',
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                                prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('إضافة منتج'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00BCD4),
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
                          _buildFilterChip('الكل', _products.length),
                          _buildFilterChip('نشط', _products.where((p) => p['status'] == 'نشط').length),
                          _buildFilterChip('منتهي', _products.where((p) => p['status'] == 'منتهي').length),
                          _buildFilterChip('قيد المراجعة', _products.where((p) => p['status'] == 'قيد المراجعة').length),
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
                      Expanded(flex: 3, child: Text('المنتج', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('البائع', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('السعر الحالي', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('المزايدات', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 100, child: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                
                // Products List
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final isSelected = _selectedProductIndex == index;
                      
                      return InkWell(
                        onTap: () => setState(() => _selectedProductIndex = isSelected ? -1 : index),
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
                                flex: 3,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
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
                                          Text(
                                            product['title'],
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            product['category'],
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(product['seller']['name']),
                              ),
                              Expanded(
                                child: Text(
                                  '₪ ${product['currentPrice']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text('${(product['bidders'] as List).length}'),
                              ),
                              Expanded(
                                child: _buildStatusBadge(product['status']),
                              ),
                              SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => setState(() => _selectedProductIndex = index),
                                      icon: const Icon(Icons.visibility, size: 18),
                                      tooltip: 'عرض',
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.edit, size: 18),
                                      tooltip: 'تعديل',
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                      tooltip: 'حذف',
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
        
        // Product Details Panel
        if (_selectedProductIndex >= 0)
          Expanded(
            flex: 2,
            child: _buildProductDetails(filteredProducts[_selectedProductIndex]),
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
      case 'منتهي':
        color = Colors.grey;
        break;
      case 'قيد المراجعة':
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

  Widget _buildProductDetails(Map<String, dynamic> product) {
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
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'تفاصيل المنتج',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _selectedProductIndex = -1),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Placeholder
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            '${(product['images'] as List).length} صور',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title & ID
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product['id'],
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    product['description'],
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Info Cards
                  Row(
                    children: [
                      _buildInfoCard('السعر الابتدائي', '₪ ${product['startPrice']}', Icons.money_off),
                      const SizedBox(width: 12),
                      _buildInfoCard('السعر الحالي', '₪ ${product['currentPrice']}', Icons.attach_money),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      _buildInfoCard('المشاهدات', '${product['views']}', Icons.visibility),
                      const SizedBox(width: 12),
                      _buildInfoCard('الحالة', product['condition'], Icons.new_releases),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Seller Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person, color: Color(0xFF00BCD4), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'معلومات البائع',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('الاسم', product['seller']['name']),
                        _buildInfoRow('الهاتف', product['seller']['phone']),
                        _buildInfoRow('البريد', product['seller']['email']),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Bidders List
                  Row(
                    children: [
                      const Icon(Icons.gavel, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'قائمة المزايدين',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(product['bidders'] as List).length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  if ((product['bidders'] as List).isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'لا توجد مزايدات حتى الآن',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ...((product['bidders'] as List).asMap().entries.map((entry) {
                      final index = entry.key;
                      final bidder = entry.value;
                      final isWinner = index == 0 && product['status'] == 'منتهي';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isWinner ? Colors.green.withOpacity(0.05) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: isWinner 
                              ? Border.all(color: Colors.green.withOpacity(0.3))
                              : null,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isWinner 
                                  ? Colors.green.withOpacity(0.1)
                                  : const Color(0xFF1a1a2e).withOpacity(0.1),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isWinner ? Colors.green : const Color(0xFF1a1a2e),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        bidder['name'],
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      if (isWinner) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'الفائز',
                                            style: TextStyle(color: Colors.white, fontSize: 10),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    bidder['time'],
                                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₪ ${bidder['amount']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isWinner ? Colors.green : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                          label: const Text('تعديل'),
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
                          icon: const Icon(Icons.delete),
                          label: const Text('حذف'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
