import 'package:flutter/material.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'cat-1',
      'name': 'إلكترونيات',
      'icon': Icons.devices,
      'color': const Color(0xFF6C5CE7),
      'productsCount': 156,
      'activeAuctions': 45,
      'status': 'نشط',
    },
    {
      'id': 'cat-2',
      'name': 'موبايلات',
      'icon': Icons.phone_android,
      'color': const Color(0xFF00B894),
      'productsCount': 234,
      'activeAuctions': 78,
      'status': 'نشط',
    },
    {
      'id': 'cat-3',
      'name': 'أجهزة منزلية',
      'icon': Icons.home,
      'color': const Color(0xFFE17055),
      'productsCount': 89,
      'activeAuctions': 23,
      'status': 'نشط',
    },
    {
      'id': 'cat-4',
      'name': 'كيمينك',
      'icon': Icons.sports_esports,
      'color': const Color(0xFF0984E3),
      'productsCount': 67,
      'activeAuctions': 19,
      'status': 'نشط',
    },
    {
      'id': 'cat-5',
      'name': 'أثاث',
      'icon': Icons.chair,
      'color': const Color(0xFFFDAA5C),
      'productsCount': 45,
      'activeAuctions': 12,
      'status': 'نشط',
    },
    {
      'id': 'cat-6',
      'name': 'ساعات',
      'icon': Icons.watch,
      'color': const Color(0xFFE84393),
      'productsCount': 34,
      'activeAuctions': 8,
      'status': 'نشط',
    },
    {
      'id': 'cat-7',
      'name': 'كاميرات',
      'icon': Icons.camera_alt,
      'color': const Color(0xFF00CEC9),
      'productsCount': 28,
      'activeAuctions': 11,
      'status': 'معطل',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إدارة الأقسام',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddCategoryDialog(),
                icon: const Icon(Icons.add),
                label: const Text('إضافة قسم جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Stats Row
          Row(
            children: [
              _buildStatCard('إجمالي الأقسام', '${_categories.length}', Icons.category, const Color(0xFF6C5CE7)),
              const SizedBox(width: 16),
              _buildStatCard('الأقسام النشطة', '${_categories.where((c) => c['status'] == 'نشط').length}', Icons.check_circle, Colors.green),
              const SizedBox(width: 16),
              _buildStatCard('إجمالي المنتجات', '${_categories.fold(0, (sum, c) => sum + (c['productsCount'] as int))}', Icons.inventory_2, const Color(0xFFE17055)),
              const SizedBox(width: 16),
              _buildStatCard('المزادات النشطة', '${_categories.fold(0, (sum, c) => sum + (c['activeAuctions'] as int))}', Icons.gavel, const Color(0xFF00BCD4)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Categories Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.3,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a2e),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final isActive = category['status'] == 'نشط';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  category['icon'] as IconData,
                  color: category['color'] as Color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      category['id'],
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditCategoryDialog(category);
                  } else if (value == 'toggle') {
                    setState(() {
                      category['status'] = isActive ? 'معطل' : 'نشط';
                    });
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(category);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(
                    children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('تعديل')],
                  )),
                  PopupMenuItem(value: 'toggle', child: Row(
                    children: [
                      Icon(isActive ? Icons.visibility_off : Icons.visibility, size: 18),
                      const SizedBox(width: 8),
                      Text(isActive ? 'تعطيل' : 'تفعيل'),
                    ],
                  )),
                  const PopupMenuItem(value: 'delete', child: Row(
                    children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('حذف', style: TextStyle(color: Colors.red))],
                  )),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildCategoryMetric(
                  'المنتجات',
                  '${category['productsCount']}',
                  Icons.inventory_2,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryMetric(
                  'مزادات نشطة',
                  '${category['activeAuctions']}',
                  Icons.gavel,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  color: isActive ? Colors.green : Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  category['status'],
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    Color selectedColor = const Color(0xFF6C5CE7);
    IconData selectedIcon = Icons.category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة قسم جديد'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم القسم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('اختر لون القسم:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  const Color(0xFF6C5CE7),
                  const Color(0xFF00B894),
                  const Color(0xFFE17055),
                  const Color(0xFF0984E3),
                  const Color(0xFFFDAA5C),
                  const Color(0xFFE84393),
                  const Color(0xFF00CEC9),
                ].map((color) => GestureDetector(
                  onTap: () {
                    selectedColor = color;
                    (context as Element).markNeedsBuild();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selectedColor == color
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _categories.add({
                    'id': 'cat-${_categories.length + 1}',
                    'name': nameController.text,
                    'icon': selectedIcon,
                    'color': selectedColor,
                    'productsCount': 0,
                    'activeAuctions': 0,
                    'status': 'نشط',
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
            ),
            child: const Text('إضافة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category) {
    final nameController = TextEditingController(text: category['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل القسم'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'اسم القسم',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  category['name'] = nameController.text;
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
            ),
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف قسم "${category['name']}"؟\n\nسيتم حذف جميع المنتجات المرتبطة بهذا القسم.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _categories.removeWhere((c) => c['id'] == category['id']);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
