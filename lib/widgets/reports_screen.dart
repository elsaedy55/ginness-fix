import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'هذا الشهر';
  String _selectedReportType = 'تقرير الأجهزة';

  final List<String> _periodOptions = [
    'اليوم',
    'هذا الأسبوع',
    'هذا الشهر',
    'الشهر الماضي',
    'آخر 3 أشهر',
    'هذا العام',
  ];

  final List<String> _reportTypeOptions = [
    'تقرير الأجهزة',
    'تقرير الموظفين',
    'تقرير الإيرادات',
    'تقرير الأقسام',
    'تقرير الأداء',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط الأدوات العلوي
          Row(
            children: [
              // نوع التقرير
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedReportType,
                    items:
                        _reportTypeOptions.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedReportType = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // فترة التقرير
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    items:
                        _periodOptions.map((String period) {
                          return DropdownMenuItem<String>(
                            value: period,
                            child: Text(period),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPeriod = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // زر تحديث
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تحديث التقرير')),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
              ),

              const Spacer(),

              // زر تصدير
              ElevatedButton.icon(
                onPressed: () => _showExportDialog(context),
                icon: const Icon(Icons.download),
                label: const Text('تصدير'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // محتوى التقارير
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الجزء الأيسر - الإحصائيات السريعة
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildQuickStatsCard(),
                      const SizedBox(height: 20),
                      _buildTopPerformersCard(),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // الجزء الأيمن - الرسوم البيانية والجداول
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildMainChart(),
                      const SizedBox(height: 20),
                      _buildDetailedTable(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإحصائيات السريعة',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildStatItem('إجمالي الأجهزة', '247', Icons.devices, Colors.blue),
            _buildStatItem('مكتملة', '186', Icons.check_circle, Colors.green),
            _buildStatItem('قيد الإصلاح', '32', Icons.build, Colors.orange),
            _buildStatItem('ملغية', '8', Icons.cancel, Colors.red),
            const Divider(),
            _buildStatItem(
              'إجمالي الإيرادات',
              '₪45,320',
              Icons.attach_money,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أفضل الموظفين',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildPerformerItem('أحمد محمد', '28 جهاز', 1),
            _buildPerformerItem('فاطمة علي', '24 جهاز', 2),
            _buildPerformerItem('محمد إبراهيم', '19 جهاز', 3),
            _buildPerformerItem('سارة أحمد', '16 جهاز', 4),
            _buildPerformerItem('عبد الله حسن', '14 جهاز', 5),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformerItem(String name, String devices, int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  devices,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.blue[400]!;
    }
  }

  Widget _buildMainChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الأداء الشهري',
                  style: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(fontSize: 18),
                ),
                Text(
                  _selectedPeriod,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'رسم بياني لأداء $_selectedReportType',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    Text(
                      '(يتطلب مكتبة الرسوم البيانية)',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التفاصيل التحليلية',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Table(
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'المعيار',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'العدد',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'النسبة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'التغيير',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                _buildTableRow(
                  'أجهزة مكتملة',
                  '186',
                  '75.3%',
                  '+12%',
                  Colors.green,
                ),
                _buildTableRow(
                  'قيد الإصلاح',
                  '32',
                  '13.0%',
                  '-5%',
                  Colors.orange,
                ),
                _buildTableRow('في الانتظار', '21', '8.5%', '+3%', Colors.blue),
                _buildTableRow('ملغية', '8', '3.2%', '-2%', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    String metric,
    String count,
    String percentage,
    String change,
    Color color,
  ) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(metric)),
        Padding(padding: const EdgeInsets.all(12), child: Text(count)),
        Padding(padding: const EdgeInsets.all(12), child: Text(percentage)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تصدير التقرير'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text('تصدير كـ PDF'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تصدير التقرير كـ PDF')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart, color: Colors.green),
                  title: const Text('تصدير كـ Excel'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تصدير التقرير كـ Excel'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image, color: Colors.blue),
                  title: const Text('تصدير كـ صورة'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تصدير التقرير كصورة')),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }
}
