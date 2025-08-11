import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/database_service.dart';

class DevicesList extends StatefulWidget {
  const DevicesList({super.key});

  @override
  State<DevicesList> createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {
  List<Device> devices = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final devicesList = await DatabaseService.getAllDevices();
      setState(() {
        devices = devicesList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في جلب البيانات: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDevices,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (devices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد أجهزة مسجلة',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // شريط أدوات
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'عدد الأجهزة: ${devices.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadDevices,
                icon: const Icon(Icons.refresh),
                tooltip: 'تحديث',
              ),
            ],
          ),
        ),

        // قائمة الأجهزة
        Expanded(
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return _buildDeviceCard(device);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(Device device) {
    Color statusColor;
    switch (device.status) {
      case 'قيد الإصلاح':
        statusColor = Colors.orange;
        break;
      case 'مكتمل':
        statusColor = Colors.green;
        break;
      case 'ملغي':
        statusColor = Colors.red;
        break;
      case 'في الانتظار':
      default:
        statusColor = Colors.blue;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'رقم الجهاز: ${device.deviceId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    device.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // معلومات العميل
            _buildInfoRow('العميل:', device.clientName),
            _buildInfoRow('الهاتف:', device.clientPhone1),

            const SizedBox(height: 8),

            // معلومات الجهاز
            _buildInfoRow('النوع:', device.deviceCategory),
            _buildInfoRow('الماركة:', device.brand),
            _buildInfoRow('الموديل:', device.model),
            _buildInfoRow('نوع العطل:', device.faultType),

            const SizedBox(height: 8),

            // المبالغ
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'الإجمالي:',
                    '${device.totalAmount.toStringAsFixed(2)} جنيه',
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    'المُقدم:',
                    '${device.advanceAmount.toStringAsFixed(2)} جنيه',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // التاريخ
            Text(
              'تاريخ الإضافة: ${_formatDate(device.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
