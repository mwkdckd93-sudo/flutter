import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('مركز المساعدة'),
        backgroundColor: const Color(0xFF1a1a2e),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.support_agent, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'كيف يمكننا مساعدتك؟',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'نحن هنا للإجابة على استفساراتك',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Options
          _buildSectionTitle('تواصل معنا'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildContactTile(
                  icon: Icons.phone,
                  iconColor: Colors.green,
                  title: 'اتصل بنا',
                  subtitle: '07800000000',
                  onTap: () => _launchUrl('tel:+9647800000000'),
                ),
                const Divider(height: 1),
                _buildContactTile(
                  icon: Icons.chat,
                  iconColor: Colors.green,
                  title: 'واتساب',
                  subtitle: 'تحدث معنا عبر واتساب',
                  onTap: () => _launchUrl('https://wa.me/9647800000000'),
                ),
                const Divider(height: 1),
                _buildContactTile(
                  icon: Icons.email,
                  iconColor: Colors.blue,
                  title: 'البريد الإلكتروني',
                  subtitle: 'support@mazad.iq',
                  onTap: () => _launchUrl('mailto:support@mazad.iq'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // FAQ
          _buildSectionTitle('الأسئلة الشائعة'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildFAQTile(
                  context: context,
                  question: 'كيف أبدأ المزايدة؟',
                  answer: 'لبدء المزايدة، قم بإنشاء حساب أو تسجيل الدخول، ثم اختر المزاد الذي تريد المشاركة فيه واضغط على زر "زايد الآن".',
                ),
                const Divider(height: 1),
                _buildFAQTile(
                  context: context,
                  question: 'كيف أضيف مزاد جديد؟',
                  answer: 'اضغط على زر "+" في الشريط السفلي، ثم أدخل تفاصيل المنتج والصور وحدد السعر الابتدائي ومدة المزاد.',
                ),
                const Divider(height: 1),
                _buildFAQTile(
                  context: context,
                  question: 'ما هي رسوم التطبيق؟',
                  answer: 'التطبيق مجاني للاستخدام. يتم خصم عمولة صغيرة فقط عند إتمام عملية البيع بنجاح.',
                ),
                const Divider(height: 1),
                _buildFAQTile(
                  context: context,
                  question: 'كيف أستلم المنتج بعد الفوز؟',
                  answer: 'بعد الفوز بالمزاد، سيتم توفير معلومات البائع للتواصل وترتيب عملية التسليم والدفع.',
                ),
                const Divider(height: 1),
                _buildFAQTile(
                  context: context,
                  question: 'ماذا يحدث إذا لم أدفع بعد الفوز؟',
                  answer: 'يجب إتمام الدفع خلال 48 ساعة من الفوز. عدم الدفع قد يؤدي لتعليق الحساب.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Social Media
          _buildSectionTitle('تابعنا'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(
                  icon: Icons.facebook,
                  color: const Color(0xFF1877F2),
                  onTap: () => _launchUrl('https://facebook.com/mazad'),
                ),
                _buildSocialButton(
                  icon: Icons.camera_alt,
                  color: const Color(0xFFE4405F),
                  onTap: () => _launchUrl('https://instagram.com/mazad'),
                ),
                _buildSocialButton(
                  icon: Icons.telegram,
                  color: const Color(0xFF0088CC),
                  onTap: () => _launchUrl('https://t.me/mazad'),
                ),
                _buildSocialButton(
                  icon: Icons.tiktok,
                  color: Colors.black,
                  onTap: () => _launchUrl('https://tiktok.com/@mazad'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
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
          color: Color(0xFF1a1a2e),
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildFAQTile({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          answer,
          style: TextStyle(color: Colors.grey[600], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
