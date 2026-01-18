import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'notifications_settings_page.dart';
import 'personal_info_page.dart';
import 'help_center_page.dart';
import 'about_app_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: const Text(
          'الإعدادات',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // قسم الحساب
          _buildSectionTitle('الحساب'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.person_outline,
              iconColor: Colors.blue,
              title: 'المعلومات الشخصية',
              subtitle: 'الاسم، البريد الإلكتروني، رقم الهاتف',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
              ),
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              iconColor: Colors.orange,
              title: 'الأمان وكلمة المرور',
              subtitle: 'تغيير كلمة المرور، المصادقة الثنائية',
              onTap: () {
                // TODO: صفحة الأمان
              },
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.location_on_outlined,
              iconColor: Colors.green,
              title: 'العناوين',
              subtitle: 'إدارة عناوين الشحن والاستلام',
              onTap: () {
                // TODO: صفحة العناوين
              },
            ),
          ]),

          const SizedBox(height: 24),

          // قسم التفضيلات
          _buildSectionTitle('التفضيلات'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              iconColor: Colors.purple,
              title: 'الإشعارات',
              subtitle: 'تخصيص إشعارات التطبيق',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsSettingsPage()),
              ),
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.language,
              iconColor: Colors.indigo,
              title: 'اللغة',
              subtitle: 'العربية',
              onTap: () {
                // TODO: تغيير اللغة
              },
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.dark_mode_outlined,
              iconColor: Colors.blueGrey,
              title: 'المظهر',
              subtitle: 'فاتح',
              trailing: Switch(
                value: false,
                onChanged: (v) {
                  // TODO: تغيير المظهر
                },
              ),
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 24),

          // قسم الخصوصية
          _buildSectionTitle('الخصوصية'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.visibility_outlined,
              iconColor: Colors.teal,
              title: 'خصوصية الحساب',
              subtitle: 'من يستطيع رؤية معلوماتك',
              onTap: () {
                // TODO: إعدادات الخصوصية
              },
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.block_outlined,
              iconColor: Colors.red,
              title: 'الحسابات المحظورة',
              subtitle: 'إدارة قائمة الحظر',
              onTap: () {
                // TODO: الحسابات المحظورة
              },
            ),
          ]),

          const SizedBox(height: 24),

          // قسم المساعدة
          _buildSectionTitle('الدعم والمساعدة'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.help_outline,
              iconColor: Colors.amber,
              title: 'مركز المساعدة',
              subtitle: 'الأسئلة الشائعة والدعم',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpCenterPage()),
              ),
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.info_outline,
              iconColor: Colors.cyan,
              title: 'حول التطبيق',
              subtitle: 'الإصدار والشروط',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutAppPage()),
              ),
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.feedback_outlined,
              iconColor: Colors.pink,
              title: 'تقييم التطبيق',
              subtitle: 'ساعدنا بتقييمك',
              onTap: () {
                // TODO: فتح متجر التطبيقات
              },
            ),
          ]),

          const SizedBox(height: 32),

          // زر تسجيل الخروج
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context, authProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // زر حذف الحساب
          TextButton(
            onPressed: () => _showDeleteAccountDialog(context),
            child: Text(
              'حذف الحساب',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف الحساب'),
          ],
        ),
        content: const Text(
          'هذا الإجراء لا يمكن التراجع عنه. سيتم حذف جميع بياناتك ومزاداتك بشكل نهائي.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: تنفيذ حذف الحساب
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف الحساب'),
          ),
        ],
      ),
    );
  }
}
