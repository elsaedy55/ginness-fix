import 'package:flutter/material.dart';
import 'dart:math';
import '../services/database_service.dart';
import 'package:ginness/widgets/add_device_wizard.dart';

class DashboardOverview extends StatefulWidget {
  const DashboardOverview({super.key});

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide / 2) - 4;
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.45;

    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;

    double startRadian = -pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startRadian,
        sweep,
        false,
        paint,
      );
      startRadian += sweep;
    }

    final tp = TextPainter(
      text: TextSpan(
        text: total.toInt().toString(),
        style: TextStyle(
          color: Colors.black,
          fontSize: radius * 0.35,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    tp.layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    if (oldDelegate.values.length != values.length) return true;
    for (var i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}

class _DashboardOverviewState extends State<DashboardOverview> {
  int? _totalDevices;
  bool _isLoading = true;
  DateTime? _lastUpdated;
  int? _inProgressDevices;
  int? _completedToday;
  Map<String, int> _statusDistribution = {};
  double? _totalRevenue;
  double? _totalRevenueThisMonth;
  // range filter
  String _selectedRangeLabel = 'هذا الشهر';
  DateTimeRange? _selectedRange;
  List<dynamic> _recentDevices = [];
  List<int> _weeklyActivity = List.filled(7, 0);
  int _weeklyActivityMax = 1;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      // load some overall stats (we still need in-progress count)
      final stats = await DatabaseService.getDeviceStats();
      if (!mounted) return;
      setState(() {
        _inProgressDevices = stats['قيد الإصلاح'] ?? stats['in_progress'] ?? 0;
        _lastUpdated = DateTime.now();
      });

      // overall total revenue (non-range)
      try {
        final total = await DatabaseService.getTotalRevenue();
        if (!mounted) return;
        setState(() {
          _totalRevenue = total;
        });
      } catch (_) {}

      // determine active range (selected or default to this month)
      final now = DateTime.now();
      final activeRange =
          _selectedRange ??
          DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);

      try {
        final rangeRevenue = await DatabaseService.getTotalRevenueForRange(
          activeRange.start,
          activeRange.end,
        );
        final completedCount = await DatabaseService.getCompletedCountForRange(
          activeRange.start,
          activeRange.end,
        );
        final devicesCount = await DatabaseService.getDevicesCountForRange(
          activeRange.start,
          activeRange.end,
        );

        // fetch status distribution for the active range
        final statusDist = await DatabaseService.getStatusDistributionForRange(
          activeRange.start,
          activeRange.end,
        );

        if (!mounted) return;
        setState(() {
          _totalRevenueThisMonth = rangeRevenue;
          _completedToday = completedCount; // shows completed for range
          _totalDevices = devicesCount; // devices added in range
          _statusDistribution = statusDist;
        });
      } catch (_) {}

      // load all devices once (used for recent devices and activity)
      try {
        final all = await DatabaseService.getAllDevices();
        // recent
        if (!mounted) return;
        setState(() {
          _recentDevices = all.take(5).toList();
        });

        // weekly activity: count devices per weekday (Mon..Sun)
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final counts = <int>[];
        for (var i = 0; i < 7; i++) {
          final day = DateTime(
            startOfWeek.year,
            startOfWeek.month,
            startOfWeek.day + i,
          );
          final count =
              all.where((d) {
                final created = d.createdAt.toLocal();
                return created.year == day.year &&
                    created.month == day.month &&
                    created.day == day.day;
              }).length;
          counts.add(count);
        }

        final maxVal =
            counts.isNotEmpty ? counts.reduce((a, b) => a > b ? a : b) : 0;
        if (!mounted) return;
        setState(() {
          _weeklyActivity = counts;
          _weeklyActivityMax = maxVal > 0 ? maxVal : 1;
        });
      } catch (_) {
        setState(() {
          _recentDevices = [];
          _weeklyActivity = List.filled(7, 0);
          _weeklyActivityMax = 1;
        });
      }
    } catch (e) {
      // ignore errors, keep null
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // range selector with refresh
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRangeChip('اليوم'),
                      const SizedBox(width: 8),
                      _buildRangeChip('هذا الأسبوع'),
                      const SizedBox(width: 8),
                      _buildRangeChip('هذا الشهر'),
                      const SizedBox(width: 8),
                      _buildRangeChip('اختيار مخصص'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // manual refresh
              IconButton(
                padding: const EdgeInsets.all(8),
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          if (mounted) {
                            setState(() {
                              _isLoading = true;
                            });
                          }
                          await _loadStats();
                        },
                icon:
                    _isLoading
                        ? Padding(
                          padding: const EdgeInsets.all(6),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(Icons.refresh_rounded),
                        ),
                tooltip: 'تحديث',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // الكروت الإحصائية
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'إجمالي الأجهزة',
                  value:
                      _isLoading ? '...' : (_totalDevices?.toString() ?? '0'),
                  icon: Icons.devices,
                  color: Colors.blue,
                  subtitle:
                      _isLoading
                          ? 'جارٍ التحميل...'
                          : 'آخر تحديث: ${_formatDateTime(_lastUpdated)}',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'قيد الإصلاح',
                  value:
                      _isLoading
                          ? '...'
                          : (_inProgressDevices?.toString() ?? '0'),
                  icon: Icons.build,
                  color: Colors.orange,
                  subtitle:
                      _isLoading
                          ? 'جارٍ التحميل...'
                          : 'من الإجمالي: ${_inProgressDevices ?? 0}',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  context,
                  title:
                      _selectedRangeLabel == 'اختيار مخصص'
                          ? 'مكتملة (نطاق)'
                          : 'مكتملة ${_selectedRangeLabel == 'اليوم' ? 'اليوم' : _selectedRangeLabel}',
                  value:
                      _isLoading ? '...' : (_completedToday?.toString() ?? '0'),
                  icon: Icons.check_circle,
                  color: Colors.green,
                  subtitle:
                      _isLoading ? 'جارٍ التحميل...' : _selectedRangeLabel,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'إجمالي الإيرادات',
                  // Show the revenue for the selected range as the main number
                  value:
                      _isLoading
                          ? '...'
                          : (_totalRevenueThisMonth != null
                              ? _formatCurrency(_totalRevenueThisMonth!)
                              : '-'),
                  icon: Icons.attach_money,
                  color: Colors.purple,
                  // Subtitle: show selected range label or custom dates
                  subtitle:
                      _isLoading
                          ? 'جارٍ التحميل...'
                          : (_selectedRangeLabel == 'اختيار مخصص' &&
                                  _selectedRange != null
                              ? 'من ${_formatDate(_selectedRange!.start)} إلى ${_formatDate(_selectedRange!.end)}'
                              : _selectedRangeLabel),
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

  Widget _buildRangeChip(String label) {
    final isSelected = _selectedRangeLabel == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (sel) async {
        if (!sel) return;
        if (mounted) {
          setState(() {
            _selectedRangeLabel = label;
            _selectedRange = null;
          });
        }

        final now = DateTime.now();
        if (label == 'اليوم') {
          final start = DateTime(now.year, now.month, now.day);
          final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
          if (mounted) {
            setState(
              () => _selectedRange = DateTimeRange(start: start, end: end),
            );
          }
        } else if (label == 'هذا الأسبوع') {
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          if (mounted) {
            setState(
              () =>
                  _selectedRange = DateTimeRange(
                    start: DateTime(
                      startOfWeek.year,
                      startOfWeek.month,
                      startOfWeek.day,
                    ),
                    end: DateTime(
                      now.year,
                      now.month,
                      now.day,
                      23,
                      59,
                      59,
                      999,
                    ),
                  ),
            );
          }
        } else if (label == 'هذا الشهر') {
          if (mounted) {
            setState(
              () =>
                  _selectedRange = DateTimeRange(
                    start: DateTime(now.year, now.month, 1),
                    end: DateTime(
                      now.year,
                      now.month,
                      now.day,
                      23,
                      59,
                      59,
                      999,
                    ),
                  ),
            );
          }
        } else if (label == 'اختيار مخصص') {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(Duration(days: 365)),
          );
          if (picked != null) {
            if (mounted)
              setState(() {
                _selectedRange = picked;
              });
          } else {
            // user canceled, revert selection
            if (mounted)
              setState(() {
                _selectedRangeLabel = 'هذا الشهر';
              });
          }
        }

        // reload stats for new range
        await _loadStats();
      },
    );
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y/$m/$d $hh:$mm';
  }

  // صيغة عرض العملة البسيطة (جنيه مصري)
  String _formatCurrency(double value) {
    // Use simple formatting with thousand separators and 2 decimals
    final intPart = value.floor();
    final frac = ((value - intPart) * 100).round().toString().padLeft(2, '0');
    final intStr = intPart.toString().replaceAllMapped(
      RegExp(r"\B(?=(\d{3})+(?!\d))"),
      (m) => ',',
    );
    return '$intStr.$frac ج.م';
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
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
                if (_isLoading)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      const SizedBox(),
                      const SizedBox(),
                      const SizedBox(),
                    ],
                  )
                else if (_recentDevices.isEmpty)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('لا يوجد أجهزة حديثة'),
                      ),
                      const SizedBox(),
                      const SizedBox(),
                      const SizedBox(),
                    ],
                  )
                else
                  ..._recentDevices.map<TableRow>((d) {
                    final device = d; // Device model map/object
                    final name = device.deviceId ?? '';
                    final client = device.clientName ?? '';
                    final status = device.status ?? '';
                    final date =
                        device.createdAt != null
                            ? _formatDate(device.createdAt)
                            : '-';

                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(name),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(client),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(date),
                        ),
                      ],
                    );
                  }).toList(),
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
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AddDeviceWizard(
                        onDeviceAdded: () async {
                          // refresh dashboard stats and recent devices after adding
                          await _loadStats();
                          // Note: AddDeviceWizard already pops itself after saving.
                          // Avoid calling Navigator.of(context).pop() here because
                          // the builder's `context` may be deactivated when this
                          // callback runs, which causes "deactivated widget's
                          // ancestor" errors. We only refresh stats.
                        },
                      ),
                );
              },
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
    final labels = ['اثن', 'ثلا', 'ربع', 'خمي', 'جمع', 'سبت', 'أحد'];
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
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final val = _weeklyActivity[i];
                  final barHeight =
                      (_weeklyActivityMax > 0)
                          ? (val / _weeklyActivityMax) * 120
                          : 0.0;
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: val.toString(),
                          child: Container(
                            height: barHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(labels[i], style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDistribution(BuildContext context) {
    // Ordered statuses to display
    final ordered = [
      {'label': 'مكتمل', 'color': Colors.green},
      {'label': 'قيد الإصلاح', 'color': Colors.orange},
      {'label': 'في الانتظار', 'color': Colors.blue},
      {'label': 'ملغي', 'color': Colors.red},
    ];

    final counts =
        ordered.map<int>((e) => _statusDistribution[e['label']] ?? 0).toList();
    final total = counts.fold<int>(0, (a, b) => a + b);

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

            SizedBox(
              height: 180,
              child: Row(
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child:
                        total == 0
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pie_chart_outline,
                                    size: 36,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'لا يوجد بيانات',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                            : CustomPaint(
                              painter: _PieChartPainter(
                                values:
                                    counts.map((c) => c.toDouble()).toList(),
                                colors:
                                    ordered
                                        .map<Color>((e) => e['color'] as Color)
                                        .toList(),
                              ),
                            ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(ordered.length, (i) {
                        final label = ordered[i]['label'] as String;
                        final color = ordered[i]['color'] as Color;
                        final cnt = counts[i];
                        final pct = total > 0 ? (cnt / total * 100) : 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
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
                              const SizedBox(width: 8),
                              Text(
                                '$cnt',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${pct.toStringAsFixed(0)}%)',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
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
