import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableNotifications = true;
  bool _enableEmailAlerts = false;
  bool _enableBackup = true;
  String _selectedTheme = 'فاتح';
  String _selectedLanguage = 'العربية';

  final List<String> _themeOptions = ['فاتح', 'داكن', 'تلقائي'];
  final List<String> _languageOptions = ['العربية', 'English'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الإعدادات العامة
          _buildSettingsSection('الإعدادات العامة', [
            _buildSettingsTile(
              'الوضع المظلم/الفاتح',
              'تحديد مظهر التطبيق',
              trailing: DropdownButton<String>(
                value: _selectedTheme,
                items:
                    _themeOptions
                        .map(
                          (theme) => DropdownMenuItem(
                            value: theme,
                            child: Text(theme),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTheme = value;
                    });
                  }
                },
              ),
            ),
            _buildSettingsTile(
              'اللغة',
              'تحديد لغة التطبيق',
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                items:
                    _languageOptions
                        .map(
                          (lang) =>
                              DropdownMenuItem(value: lang, child: Text(lang)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                  }
                },
              ),
            ),
          ]),

          const SizedBox(height: 32),

          // إعدادات الإشعارات
          _buildSettingsSection('الإشعارات', [
            _buildSettingsTile(
              'تفعيل الإشعارات',
              'استقبال إشعارات النظام',
              trailing: Switch(
                value: _enableNotifications,
                onChanged: (value) {
                  setState(() {
                    _enableNotifications = value;
                  });
                },
              ),
            ),
            _buildSettingsTile(
              'تنبيهات البريد الإلكتروني',
              'إرسال التنبيهات عبر البريد الإلكتروني',
              trailing: Switch(
                value: _enableEmailAlerts,
                onChanged: (value) {
                  setState(() {
                    _enableEmailAlerts = value;
                  });
                },
              ),
            ),
          ]),

          const SizedBox(height: 32),

          // إعدادات النسخ الاحتياطي
          _buildSettingsSection('النسخ الاحتياطي والأمان', [
            _buildSettingsTile(
              'النسخ الاحتياطي التلقائي',
              'إنشاء نسخة احتياطية يومياً',
              trailing: Switch(
                value: _enableBackup,
                onChanged: (value) {
                  setState(() {
                    _enableBackup = value;
                  });
                },
              ),
            ),
            _buildSettingsTile(
              'إنشاء نسخة احتياطية الآن',
              'إنشاء نسخة احتياطية فورية',
              trailing: ElevatedButton(
                onPressed: () => _showBackupDialog(context),
                child: const Text('نسخ احتياطي'),
              ),
            ),
            _buildSettingsTile(
              'استعادة النسخة الاحتياطية',
              'استعادة البيانات من نسخة احتياطية',
              trailing: OutlinedButton(
                onPressed: () => _showRestoreDialog(context),
                child: const Text('استعادة'),
              ),
            ),
          ]),

          const SizedBox(height: 32),

          // إعدادات النظام
          _buildSettingsSection('إعدادات النظام', [
            _buildSettingsTile(
              'تحديث النظام',
              'البحث عن تحديثات جديدة',
              trailing: ElevatedButton(
                onPressed: () => _checkForUpdates(context),
                child: const Text('فحص التحديثات'),
              ),
            ),
            _buildSettingsTile(
              'تصدير البيانات',
              'تصدير جميع البيانات',
              trailing: OutlinedButton(
                onPressed: () => _showExportDataDialog(context),
                child: const Text('تصدير'),
              ),
            ),
            _buildSettingsTile(
              'مسح البيانات',
              'حذف جميع البيانات (لا يمكن التراجع)',
              trailing: ElevatedButton(
                onPressed: () => _showClearDataDialog(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('مسح البيانات'),
              ),
            ),
          ]),

          const SizedBox(height: 32),

          // معلومات التطبيق
          _buildSettingsSection('معلومات التطبيق', [
            _buildInfoTile('إصدار التطبيق', '1.0.0'),
            _buildInfoTile('تاريخ آخر تحديث', '2024/12/15'),
            _buildInfoTile('المطور', 'فريق التطوير'),
            _buildInfoTile('الترخيص', 'رخصة خاصة'),
            _buildSettingsTile(
              'حول التطبيق',
              'معلومات إضافية حول التطبيق',
              trailing: TextButton(
                onPressed: () => _showAboutDialog(context),
                child: const Text('عرض'),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, {Widget? trailing}) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إنشاء نسخة احتياطية'),
            content: const Text(
              'هل تريد إنشاء نسخة احتياطية من جميع البيانات الآن؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إنشاء النسخة الاحتياطية بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('إنشاء'),
              ),
            ],
          ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('استعادة النسخة الاحتياطية'),
            content: const Text(
              'تحذير: ستؤدي هذه العملية إلى استبدال جميع البيانات الحالية. هل تريد المتابعة؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم استعادة النسخة الاحتياطية بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('استعادة'),
              ),
            ],
          ),
    );
  }

  void _checkForUpdates(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('لا توجد تحديثات متاحة. أنت تستخدم أحدث إصدار'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تصدير البيانات'),
            content: const Text('اختر تنسيق تصدير البيانات:'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تصدير البيانات كـ JSON')),
                  );
                },
                child: const Text('JSON'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تصدير البيانات كـ Excel')),
                  );
                },
                child: const Text('Excel'),
              ),
            ],
          ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تحذير!'),
            content: const Text(
              'ستؤدي هذه العملية إلى حذف جميع البيانات نهائياً ولا يمكن التراجع عنها. هل أنت متأكد؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم مسح جميع البيانات'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('مسح البيانات'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حول التطبيق'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لوحة تحكم إدارة الأجهزة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('الإصدار: 1.0.0'),
                Text('تاريخ الإصدار: ديسمبر 2024'),
                Text('المطور: فريق التطوير'),
                SizedBox(height: 12),
                Text(
                  'نظام شامل لإدارة الأجهزة والموظفين والأقسام مع إمكانيات متقدمة للتقارير والإحصائيات.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
    );
  }
}
