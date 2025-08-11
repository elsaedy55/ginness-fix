import 'package:flutter/material.dart';
import '../models/device_history.dart';
import '../models/device.dart';
import '../services/database_service.dart';

class DeviceHistoryDialog extends StatefulWidget {
  final String deviceId;

  const DeviceHistoryDialog({super.key, required this.deviceId});

  @override
  State<DeviceHistoryDialog> createState() => _DeviceHistoryDialogState();
}

class _DeviceHistoryDialogState extends State<DeviceHistoryDialog> {
  List<DeviceHistory> _history = [];
  Device? _currentDevice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // جلب السجل المؤرشف
      final history = await DatabaseService.getDeviceHistory(widget.deviceId);

      // جلب الجهاز الحالي إن وجد
      final allDevices = await DatabaseService.getAllDevices();
      final currentDevice =
          allDevices.where((d) => d.deviceId == widget.deviceId).firstOrNull;

      setState(() {
        _history = history;
        _currentDevice = currentDevice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل السجل: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // رأس النافذة
            Row(
              children: [
                const Icon(Icons.history, size: 24, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'سجل الجهاز - ${widget.deviceId}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const Divider(),

            // محتوى السجل
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _history.isEmpty && _currentDevice == null
                      ? _buildEmptyState()
                      : _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا يوجد سجل لهذا الجهاز',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'سيظهر السجل هنا عند إضافة الجهاز مرة أخرى أو إكمال الإصلاحات',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final totalItems = (_currentDevice != null ? 1 : 0) + _history.length;

    return ListView.builder(
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // إذا كان هناك جهاز حالي، اعرضه أولاً
        if (_currentDevice != null && index == 0) {
          return _buildCurrentDeviceCard(_currentDevice!);
        }

        // اعرض السجل المؤرشف
        final historyIndex = _currentDevice != null ? index - 1 : index;
        final entry = _history[historyIndex];
        return _buildHistoryCard(
          entry,
          historyIndex + (_currentDevice != null ? 2 : 1),
        );
      },
    );
  }

  Widget _buildCurrentDeviceCard(Device device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[300]!, width: 2),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.settings, color: Colors.white, size: 20),
        ),
        title: Row(
          children: [
            Text(
              device.faultType,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'حالي',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getStatusIcon(device.status),
                  size: 16,
                  color: _getStatusColor(device.status),
                ),
                const SizedBox(width: 4),
                Text(
                  device.status,
                  style: TextStyle(
                    color: _getStatusColor(device.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'دخل: ${_formatDate(device.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('وصف العطل:', device.faultDescription),
                if (device.spareParts.isNotEmpty)
                  _buildDetailRow('قطع الغيار:', device.spareParts),
                _buildDetailRow('العميل:', device.clientName),
                _buildDetailRow('الهاتف:', device.clientPhone1),
                if (device.clientPhone2.isNotEmpty)
                  _buildDetailRow('هاتف إضافي:', device.clientPhone2),
                _buildDetailRow(
                  'الماركة:',
                  '${device.brand} - ${device.model}',
                ),
                _buildDetailRow('نظام التشغيل:', device.operatingSystem),

                const Divider(height: 24),

                // المعلومات المالية
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildFinancialRow(
                        'إجمالي التكلفة:',
                        '${device.totalAmount.toStringAsFixed(2)} جنيه',
                      ),
                      _buildFinancialRow(
                        'المقدم:',
                        '${device.advanceAmount.toStringAsFixed(2)} جنيه',
                      ),
                      _buildFinancialRow(
                        'المتبقي:',
                        '${device.remainingAmount.toStringAsFixed(2)} جنيه',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // أزرار تحديث الحالة
                const Text(
                  'تحديث الحالة:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (device.status != 'قيد الإصلاح')
                      ElevatedButton.icon(
                        onPressed:
                            () => _updateCurrentDeviceStatus('قيد الإصلاح'),
                        icon: const Icon(Icons.build, size: 16),
                        label: const Text('قيد الإصلاح'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                    if (device.status != 'مكتمل')
                      ElevatedButton.icon(
                        onPressed: () => _updateCurrentDeviceStatus('مكتمل'),
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('مكتمل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                    if (device.status != 'في الانتظار')
                      ElevatedButton.icon(
                        onPressed:
                            () => _updateCurrentDeviceStatus('في الانتظار'),
                        icon: const Icon(Icons.hourglass_empty, size: 16),
                        label: const Text('في الانتظار'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(DeviceHistory entry, int index) {
    final isCompleted = entry.status == 'مكتمل';
    final cardColor = isCompleted ? Colors.green[50] : Colors.orange[50];
    final borderColor = isCompleted ? Colors.green[200] : Colors.orange[200];
    final statusColor = isCompleted ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor!, width: 1),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          entry.faultType,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.pending,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  entry.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'دخل: ${_formatDate(entry.entryDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (entry.completionDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'اكتمل: ${_formatDate(entry.completionDate!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('وصف العطل:', entry.faultDescription),
                if (entry.spareParts.isNotEmpty)
                  _buildDetailRow('قطع الغيار:', entry.spareParts),
                _buildDetailRow('العميل:', entry.clientName),
                _buildDetailRow('الهاتف:', entry.clientPhone1),
                if (entry.clientPhone2.isNotEmpty)
                  _buildDetailRow('هاتف إضافي:', entry.clientPhone2),
                _buildDetailRow('الماركة:', '${entry.brand} - ${entry.model}'),
                _buildDetailRow('نظام التشغيل:', entry.operatingSystem),

                const Divider(height: 24),

                // المعلومات المالية
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildFinancialRow(
                        'إجمالي التكلفة:',
                        '${entry.totalAmount.toStringAsFixed(2)} جنيه',
                      ),
                      _buildFinancialRow(
                        'المقدم:',
                        '${entry.advanceAmount.toStringAsFixed(2)} جنيه',
                      ),
                      _buildFinancialRow(
                        'المتبقي:',
                        '${entry.remainingAmount.toStringAsFixed(2)} جنيه',
                      ),
                    ],
                  ),
                ),

                if (entry.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow('ملاحظات:', entry.notes),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'مكتمل':
        return Icons.check_circle;
      case 'قيد الإصلاح':
        return Icons.build_circle;
      case 'ملغي':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'قيد الإصلاح':
        return Colors.blue;
      case 'ملغي':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // دالة تحديث حالة الجهاز الحالي
  Future<void> _updateCurrentDeviceStatus(String newStatus) async {
    if (_currentDevice == null) return;

    try {
      await DatabaseService.updateDeviceStatus(_currentDevice!.id!, newStatus);

      // إعادة تحميل البيانات
      await _loadHistory();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث حالة الجهاز إلى: $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديث الحالة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
