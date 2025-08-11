import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/payment.dart';
import '../services/database_service.dart';
import 'add_payment_dialog.dart';

class DeviceDetailsDialog extends StatefulWidget {
  final Device device;
  final Function() onDeviceUpdated;

  const DeviceDetailsDialog({
    super.key,
    required this.device,
    required this.onDeviceUpdated,
  });

  @override
  State<DeviceDetailsDialog> createState() => _DeviceDetailsDialogState();
}

class _DeviceDetailsDialogState extends State<DeviceDetailsDialog> {
  List<Payment> _payments = [];
  bool _isLoading = true;
  double _totalPaid = 0.0;
  double _remainingAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.device.id != null) {
        final payments = await DatabaseService.getDevicePayments(
          widget.device.id!,
        );
        final totalPaid = await DatabaseService.getDeviceTotalPaid(
          widget.device.id!,
        );

        setState(() {
          _payments = payments;
          _totalPaid = totalPaid;
          _remainingAmount = widget.device.totalAmount - totalPaid;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل البيانات: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddPaymentDialog(
            device: widget.device,
            onPaymentAdded: () {
              _loadData();
              widget.onDeviceUpdated();
            },
          ),
    );
  }

  Future<void> _deletePayment(Payment payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text(
              'هل أنت متأكد من حذف الدفعة بقيمة ${payment.amount.toStringAsFixed(2)} جنيه؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true && payment.id != null) {
      try {
        await DatabaseService.deletePayment(payment.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الدفعة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
        widget.onDeviceUpdated();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف الدفعة: ${e.toString()}'),
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
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // رأس النافذة
            Row(
              children: [
                const Icon(Icons.info_outline, size: 24, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'تفاصيل الجهاز - ${widget.device.deviceId}',
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

            // محتوى التفاصيل
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // معلومات الجهاز
                            _buildInfoSection('معلومات الجهاز', [
                              _buildInfoRow(
                                'رقم الجهاز:',
                                widget.device.deviceId,
                              ),
                              _buildInfoRow(
                                'نوع الجهاز:',
                                widget.device.deviceCategory,
                              ),
                              _buildInfoRow('الماركة:', widget.device.brand),
                              _buildInfoRow('الموديل:', widget.device.model),
                              _buildInfoRow(
                                'نظام التشغيل:',
                                widget.device.operatingSystem,
                              ),
                              _buildInfoRow('الحالة:', widget.device.status),
                            ]),

                            const SizedBox(height: 24),

                            // معلومات العميل
                            _buildInfoSection('معلومات العميل', [
                              _buildInfoRow('الاسم:', widget.device.clientName),
                              _buildInfoRow('الجنس:', widget.device.gender),
                              _buildInfoRow(
                                'الهاتف الأول:',
                                widget.device.clientPhone1,
                              ),
                              if (widget.device.clientPhone2.isNotEmpty)
                                _buildInfoRow(
                                  'الهاتف الثاني:',
                                  widget.device.clientPhone2,
                                ),
                            ]),

                            const SizedBox(height: 24),

                            // معلومات العطل
                            _buildInfoSection('معلومات العطل', [
                              _buildInfoRow(
                                'نوع العطل:',
                                widget.device.faultType,
                              ),
                              _buildInfoRow(
                                'وصف العطل:',
                                widget.device.faultDescription,
                              ),
                              if (widget.device.spareParts.isNotEmpty)
                                _buildInfoRow(
                                  'قطع الغيار:',
                                  widget.device.spareParts,
                                ),
                            ]),

                            const SizedBox(height: 24),

                            // المعلومات المالية
                            _buildFinancialSection(),

                            const SizedBox(height: 24),

                            // سجل الدفعات
                            _buildPaymentsSection(),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildFinancialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'المعلومات المالية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _remainingAmount > 0 ? _showAddPaymentDialog : null,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('إضافة دفعة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            children: [
              _buildFinancialRow(
                'إجمالي التكلفة:',
                '${widget.device.totalAmount.toStringAsFixed(2)} جنيه',
                Colors.black,
              ),
              _buildFinancialRow(
                'إجمالي المدفوع:',
                '${_totalPaid.toStringAsFixed(2)} جنيه',
                Colors.green,
              ),
              _buildFinancialRow(
                'المبلغ المتبقي:',
                '${_remainingAmount.toStringAsFixed(2)} جنيه',
                _remainingAmount > 0 ? Colors.red : Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سجل الدفعات (${_payments.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 8),
        if (_payments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Center(
              child: Text(
                'لا توجد دفعات مسجلة',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _payments.length,
              separatorBuilder:
                  (context, index) =>
                      Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final payment = _payments[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        payment.type == 'مقدم'
                            ? Colors.blue[100]
                            : Colors.green[100],
                    child: Icon(
                      Icons.payment,
                      color:
                          payment.type == 'مقدم' ? Colors.blue : Colors.green,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${payment.amount.toStringAsFixed(2)} جنيه',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('نوع الدفعة: ${payment.type}'),
                      Text(
                        'التاريخ: ${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year} - ${payment.createdAt.hour.toString().padLeft(2, '0')}:${payment.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (payment.notes.isNotEmpty)
                        Text(
                          'ملاحظات: ${payment.notes}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _deletePayment(payment),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    tooltip: 'حذف الدفعة',
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
