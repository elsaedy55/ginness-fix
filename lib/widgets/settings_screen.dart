import 'package:flutter/material.dart';
import '../services/database_service.dart';

// إدارة إعدادات التطبيق، بما فيها بدء ترقيم الأجهزة (GF-...)

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

  // جهاز ID counter setting
  final TextEditingController _deviceStartController = TextEditingController();
  bool _isLoadingDeviceCounter = true;
  // جهاز ID prefix setting
  final TextEditingController _devicePrefixController = TextEditingController();
  bool _isLoadingDevicePrefix = true;

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
            // إعداد بدء ترقيم الأجهزة
            ListTile(
              title: const Text('بداية ترقيم الأجهزة (GF-)'),
              subtitle: const Text('أدخل آخر رقم مستخدم؛ التالي سيكون +1'),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              trailing: SizedBox(
                width: 360,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _deviceStartController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          hintText: 'مثال: 555',
                          labelText: 'آخر رقم مستخدم',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed:
                            _isLoadingDeviceCounter ? null : _saveDeviceStart,
                        child: const Text('حفظ'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        onPressed:
                            _isLoadingDeviceCounter ? null : _resetDeviceStart,
                        child: const Text('إعادة'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // إعداد بادئة Device ID (محسّن)
            ListTile(
              title: const Text('بادئة رقم الجهاز (مثال: GF-1 أو GF-2)'),
              subtitle: const Text('النص الذي سيُستخدم كبادئة قبل الرقم'),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              trailing: SizedBox(
                width: 360,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _devicePrefixController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          hintText: 'مثال: GF-1',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed:
                            _isLoadingDevicePrefix ? null : _saveDevicePrefix,
                        child: const Text('حفظ'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        onPressed:
                            _isLoadingDevicePrefix ? null : _resetDevicePrefix,
                        child: const Text('إعادة'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // معاينة محسّنة لكيف سيبدو الـ ID
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 12.0, right: 12.0),
              child: Builder(
                builder: (ctx) {
                  final prefix =
                      _devicePrefixController.text.trim().isEmpty
                          ? 'GF'
                          : _devicePrefixController.text.trim();
                  final last =
                      _deviceStartController.text.trim().isEmpty
                          ? '1'
                          : _deviceStartController.text.trim();
                  int lastNum = int.tryParse(last) ?? 1;
                  final nextNum = lastNum + 1;
                  return Card(
                    color: Colors.grey[50],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye,
                            size: 18,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              // ignore: unnecessary_brace_in_string_interps
                              'المستخدم آخر رقم: $prefix-$lastNum    →    التالي: ${prefix}-$nextNum',
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
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

  @override
  void initState() {
    super.initState();
    _loadDeviceStartCounter();
    _loadDevicePrefix();

    // Keep preview live while user types, but use named listeners so we can remove them on dispose
    _deviceStartController.addListener(_settingsPreviewListener);
    _devicePrefixController.addListener(_settingsPreviewListener);
  }

  @override
  void dispose() {
    // remove listeners before disposing controllers to avoid callbacks after dispose
    _deviceStartController.removeListener(_settingsPreviewListener);
    _devicePrefixController.removeListener(_settingsPreviewListener);
    _deviceStartController.dispose();
    _devicePrefixController.dispose();
    super.dispose();
  }

  void _settingsPreviewListener() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadDeviceStartCounter() async {
    if (mounted) {
      setState(() {
        _isLoadingDeviceCounter = true;
      });
    }
    try {
      final counter = await DatabaseService.getDeviceStartCounter();
      _deviceStartController.text = counter.toString();
    } catch (e) {
      // ignore, keep default
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDeviceCounter = false;
        });
      }
    }
  }

  Future<void> _loadDevicePrefix() async {
    if (mounted) {
      setState(() {
        _isLoadingDevicePrefix = true;
      });
    }
    try {
      final prefix = await DatabaseService.getDevicePrefix();
      _devicePrefixController.text = prefix;
    } catch (e) {
      // ignore
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDevicePrefix = false;
        });
      }
    }
  }

  Future<void> _saveDeviceStart() async {
    final text = _deviceStartController.text.trim();
    final val = int.tryParse(text);
    if (val == null || val <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ادخل رقماً صحيحاً أكبر من 0')),
      );
      return;
    }

    try {
      await DatabaseService.setDeviceStartCounter(val);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ بداية ترقيم الأجهزة بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
    }
  }

  Future<void> _resetDeviceStart() async {
    try {
      await DatabaseService.setDeviceStartCounter(1);
      _deviceStartController.text = '1';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إعادة العداد إلى 1')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل إعادة التعيين: $e')));
    }
  }

  Future<void> _saveDevicePrefix() async {
    final text = _devicePrefixController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ادخل بادئة صحيحة مثل GF-1')),
      );
      return;
    }

    try {
      await DatabaseService.setDevicePrefix(text);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ بادئة رقم الجهاز')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
    }
  }

  Future<void> _resetDevicePrefix() async {
    try {
      await DatabaseService.setDevicePrefix('GF-1');
      _devicePrefixController.text = 'GF-1';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إعادة البادئة إلى GF-1')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل إعادة التعيين: $e')));
    }
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
