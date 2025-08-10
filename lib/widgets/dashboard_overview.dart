import 'package:flutter/material.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الكروت الإحصائية
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'إجمالي الأجهزة',
                  value: '247',
                  icon: Icons.devices,
                  color: Colors.blue,
                  subtitle: '+12% من الشهر الماضي',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'قيد الإصلاح',
                  value: '32',
                  icon: Icons.build,
                  color: Colors.orange,
                  subtitle: '13% من الإجمالي',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'مكتملة اليوم',
                  value: '18',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  subtitle: '+5 من الأمس',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'إجمالي الإيرادات',
                  value: '₪12,500',
                  icon: Icons.attach_money,
                  color: Colors.purple,
                  subtitle: 'هذا الشهر',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // الجداول والمخططات
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // جدول الأجهزة الحديثة
              Expanded(flex: 2, child: _buildRecentDevicesTable(context)),

              const SizedBox(width: 20),

              // قائمة المهام السريعة
              Expanded(flex: 1, child: _buildQuickActions(context)),
            ],
          ),

          const SizedBox(height: 24),

          // إحصائيات إضافية
          Row(
            children: [
              Expanded(child: _buildActivityChart(context)),
              const SizedBox(width: 20),
              Expanded(child: _buildStatusDistribution(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDevicesTable(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الأجهزة الحديثة',
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
                        'الجهاز',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'العميل',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'الحالة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'التاريخ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...List.generate(5, (index) {
                  final devices = [
                    {
                      'name': 'iPhone 13',
                      'client': 'محمد أحمد',
                      'status': 'قيد الإصلاح',
                      'date': '2024/12/15',
                    },
                    {
                      'name': 'Samsung Galaxy',
                      'client': 'فاطمة علي',
                      'status': 'مكتمل',
                      'date': '2024/12/14',
                    },
                    {
                      'name': 'MacBook Pro',
                      'client': 'عبد الله محمد',
                      'status': 'في الانتظار',
                      'date': '2024/12/13',
                    },
                    {
                      'name': 'iPad Air',
                      'client': 'سارة إبراهيم',
                      'status': 'قيد الإصلاح',
                      'date': '2024/12/12',
                    },
                    {
                      'name': 'HP Laptop',
                      'client': 'أحمد حسن',
                      'status': 'مكتمل',
                      'date': '2024/12/11',
                    },
                  ];

                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(devices[index]['name']!),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(devices[index]['client']!),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              devices[index]['status']!,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            devices[index]['status']!,
                            style: TextStyle(
                              color: _getStatusColor(devices[index]['status']!),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(devices[index]['date']!),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'قيد الإصلاح':
        return Colors.orange;
      case 'في الانتظار':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات سريعة',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              icon: Icons.add,
              title: 'إضافة جهاز جديد',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.person_add,
              title: 'إضافة موظف',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.business,
              title: 'إضافة قسم',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.analytics,
              title: 'عرض التقارير',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نشاط الأسبوع',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: Center(
                child: Text(
                  'مخطط النشاط الأسبوعي\n(يتطلب مكتبة الرسوم البيانية)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDistribution(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'توزيع الحالات',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildStatusItem('مكتملة', 120, Colors.green),
            const SizedBox(height: 8),
            _buildStatusItem('قيد الإصلاح', 32, Colors.orange),
            const SizedBox(height: 8),
            _buildStatusItem('في الانتظار', 15, Colors.blue),
            const SizedBox(height: 8),
            _buildStatusItem('ملغية', 5, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
