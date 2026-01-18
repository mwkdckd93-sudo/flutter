import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _bidNotifications = true;
  bool _outbidNotifications = true;
  bool _auctionEndNotifications = true;
  bool _newAuctionsNotifications = true;
  bool _chatNotifications = true;
  bool _promotionalNotifications = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: const Color(0xFF1a1a2e),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Notifications Status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإشعارات مفعّلة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ستتلقى إشعارات حول مزاداتك',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Auction Notifications
          _buildSectionTitle('إشعارات المزادات'),
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
                _buildNotificationTile(
                  title: 'مزايدات جديدة',
                  subtitle: 'عند وجود مزايدة جديدة على مزاداتك',
                  value: _bidNotifications,
                  onChanged: (v) => setState(() => _bidNotifications = v),
                ),
                const Divider(height: 1),
                _buildNotificationTile(
                  title: 'تم تجاوز مزايدتك',
                  subtitle: 'عندما يتجاوز شخص آخر مزايدتك',
                  value: _outbidNotifications,
                  onChanged: (v) => setState(() => _outbidNotifications = v),
                ),
                const Divider(height: 1),
                _buildNotificationTile(
                  title: 'انتهاء المزاد',
                  subtitle: 'عند انتهاء المزادات التي شاركت فيها',
                  value: _auctionEndNotifications,
                  onChanged: (v) => setState(() => _auctionEndNotifications = v),
                ),
                const Divider(height: 1),
                _buildNotificationTile(
                  title: 'مزادات جديدة',
                  subtitle: 'إشعار بالمزادات الجديدة في تصنيفاتك المفضلة',
                  value: _newAuctionsNotifications,
                  onChanged: (v) => setState(() => _newAuctionsNotifications = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Other Notifications
          _buildSectionTitle('إشعارات أخرى'),
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
                _buildNotificationTile(
                  title: 'الرسائل',
                  subtitle: 'إشعارات المحادثات والرسائل الجديدة',
                  value: _chatNotifications,
                  onChanged: (v) => setState(() => _chatNotifications = v),
                ),
                const Divider(height: 1),
                _buildNotificationTile(
                  title: 'العروض والتخفيضات',
                  subtitle: 'إشعارات حول العروض الترويجية',
                  value: _promotionalNotifications,
                  onChanged: (v) => setState(() => _promotionalNotifications = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a1a2e),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'حفظ الإعدادات',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF1E88E5),
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Save to API when endpoint is available
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ إعدادات الإشعارات'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
