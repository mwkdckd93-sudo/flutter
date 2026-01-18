import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  final bool isPrivacy;
  
  const TermsPage({super.key, this.isPrivacy = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isPrivacy ? 'سياسة الخصوصية' : 'شروط الاستخدام'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    isPrivacy ? Icons.privacy_tip_rounded : Icons.description_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPrivacy ? 'سياسة الخصوصية' : 'شروط الاستخدام',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'آخر تحديث: يناير 2026',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            if (isPrivacy) ...[
              _buildSection(
                theme,
                'المعلومات التي نجمعها',
                '''نقوم بجمع المعلومات التالية عند استخدامك لتطبيق مزاد:

• معلومات الحساب: الاسم الكامل، رقم الهاتف، البريد الإلكتروني
• معلومات العنوان: المدينة، المنطقة، تفاصيل العنوان
• معلومات المعاملات: سجل المزايدات، المشتريات، المبيعات
• معلومات الجهاز: نوع الجهاز، نظام التشغيل، معرف الجهاز''',
              ),
              _buildSection(
                theme,
                'كيف نستخدم معلوماتك',
                '''نستخدم المعلومات التي نجمعها للأغراض التالية:

• توفير وتحسين خدماتنا
• معالجة المعاملات والمزايدات
• التواصل معك بخصوص حسابك والمزادات
• إرسال إشعارات مهمة عن المزادات
• منع الاحتيال وضمان أمان المنصة
• الامتثال للمتطلبات القانونية''',
              ),
              _buildSection(
                theme,
                'مشاركة المعلومات',
                '''لا نبيع معلوماتك الشخصية. قد نشارك المعلومات مع:

• البائعين والمشترين لإتمام المعاملات
• مزودي خدمات الدفع والشحن
• السلطات القانونية عند الطلب الرسمي''',
              ),
              _buildSection(
                theme,
                'حماية المعلومات',
                '''نتخذ إجراءات أمنية لحماية معلوماتك:

• تشفير البيانات أثناء النقل والتخزين
• مراقبة مستمرة للأنشطة المشبوهة
• تحديث دوري لأنظمة الأمان
• تقييد الوصول للبيانات الحساسة''',
              ),
              _buildSection(
                theme,
                'حقوقك',
                '''لديك الحق في:

• الوصول إلى بياناتك الشخصية
• تصحيح المعلومات غير الدقيقة
• حذف حسابك وبياناتك
• الاعتراض على معالجة بياناتك
• سحب موافقتك في أي وقت''',
              ),
            ] else ...[
              _buildSection(
                theme,
                'القبول بالشروط',
                '''باستخدامك لتطبيق "مزاد"، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء من هذه الشروط، يرجى عدم استخدام التطبيق.''',
              ),
              _buildSection(
                theme,
                'الأهلية',
                '''يجب أن تكون:
• بعمر 18 سنة أو أكثر
• مقيماً في العراق أو لديك عنوان عراقي صالح
• قادراً على الدخول في عقود ملزمة قانونياً

لا يُسمح للقاصرين باستخدام المنصة دون إشراف ولي الأمر.''',
              ),
              _buildSection(
                theme,
                'المزايدات والشراء',
                '''عند تقديم مزايدة:
• تعتبر المزايدة عقداً ملزماً للشراء بالسعر المحدد
• لا يمكن سحب المزايدة بعد تقديمها
• الفائز بالمزاد ملزم بإتمام عملية الشراء خلال 48 ساعة
• عدم إتمام الشراء قد يؤدي إلى تعليق الحساب

التمديد التلقائي: إذا تم تقديم مزايدة في آخر 5 دقائق، يتم تمديد المزاد تلقائياً.''',
              ),
              _buildSection(
                theme,
                'البيع والنشر',
                '''عند نشر منتج للمزاد:
• يجب أن تكون مالكاً قانونياً للمنتج
• يجب أن تكون الصور والوصف دقيقة وصادقة
• يحظر بيع المنتجات غير القانونية أو المسروقة
• تحتفظ المنصة بحق رفض أو إزالة أي منتج

عمولة البيع: تحتسب عمولة 5% على البائع عند إتمام البيع بنجاح.''',
              ),
              _buildSection(
                theme,
                'المنتجات المحظورة',
                '''يحظر نشر أو بيع:
• الأسلحة والذخائر
• المواد المخدرة أو المحظورة
• المنتجات المقلدة أو المزورة
• المنتجات المسروقة
• المواد الإباحية
• أي منتج مخالف للقانون العراقي''',
              ),
              _buildSection(
                theme,
                'الدفع والتسليم',
                '''• يتم الدفع عند الاستلام أو عبر المحفظة الإلكترونية
• يتحمل المشتري رسوم الشحن ما لم يُذكر خلاف ذلك
• يجب على البائع شحن المنتج خلال 3 أيام عمل
• يحق للمشتري فحص المنتج عند الاستلام''',
              ),
              _buildSection(
                theme,
                'إنهاء الحساب',
                '''يحق لنا تعليق أو إنهاء حسابك في حالة:
• انتهاك شروط الاستخدام
• تقديم معلومات كاذبة
• سلوك احتيالي أو مشبوه
• عدم إتمام المعاملات بشكل متكرر
• أي سلوك يضر بالمستخدمين الآخرين أو المنصة''',
              ),
              _buildSection(
                theme,
                'حدود المسؤولية',
                '''• نحن وسيط بين البائع والمشتري ولسنا طرفاً في عملية البيع
• لا نضمن جودة أو أصالة المنتجات المعروضة
• لا نتحمل مسؤولية الخلافات بين البائع والمشتري
• نبذل قصارى جهدنا لحل النزاعات بشكل عادل''',
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Contact
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.help_outline, size: 32, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'هل لديك أسئلة؟',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تواصل معنا عبر البريد الإلكتروني',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'support@mazad.iq',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
