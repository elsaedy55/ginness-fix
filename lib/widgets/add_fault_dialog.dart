import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/payment.dart';
import '../services/database_service.dart';

class AddFaultDialog extends StatefulWidget {
  final Device existingDevice;
  final VoidCallback? onFaultAdded;

  const AddFaultDialog({
    super.key,
    required this.existingDevice,
    this.onFaultAdded,
  });

  @override
  State<AddFaultDialog> createState() => _AddFaultDialogState();
}

class _AddFaultDialogState extends State<AddFaultDialog> {
  final _formKey = GlobalKey<FormState>();
  final _problemController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _advanceAmountController = TextEditingController();
  final _remainingAmountController = TextEditingController();
  final _sparePartsController = TextEditingController();

  String _selectedFaultType = '';
  String _selectedStatus = 'في الانتظار';

  final List<String> _faultTypes = [
    'هاردوير',
    'سوفت وير',
    'شاشة',
    'بطارية',
    'شحن',
    'صوت',
    'كاميرا',
    'مكبرات صوت',
    'مايكروفون',
    'واي فاي',
    'بلوتوث',
    'بيانات',
    'قفل/حماية',
    'أخرى',
  ];

  final List<String> _statusOptions = [
    'في الانتظار',
    'قيد الإصلاح',
    'مكتمل',
    'ملغي',
  ];

  @override
  void initState() {
    super.initState();
    _advanceAmountController.addListener(_updateRemainingAmount);
    _totalAmountController.addListener(_updateRemainingAmount);
  }

  @override
  void dispose() {
    _problemController.dispose();
    _totalAmountController.dispose();
    _advanceAmountController.dispose();
    _remainingAmountController.dispose();
    _sparePartsController.dispose();
    super.dispose();
  }

  void _updateRemainingAmount() {
    final total = double.tryParse(_totalAmountController.text) ?? 0;
    final advance = double.tryParse(_advanceAmountController.text) ?? 0;
    final remaining = total - advance;

    setState(() {
      _remainingAmountController.text = remaining.toStringAsFixed(2);
    });
  }

  void _saveFault() async {
    if (_formKey.currentState!.validate()) {
      try {
        // أولاً، نقل الجهاز الحالي إلى السجل قبل إضافة العطل الجديد
        await DatabaseService.archiveDevice(
          widget.existingDevice,
          notes:
              'تم أرشفة هذا العطل قبل إضافة عطل جديد - ${DateTime.now().toIso8601String()}',
        );

        // ثم تحديث الجهاز الموجود بالعطل الجديد
        final updatedDevice = widget.existingDevice.copyWith(
          faultType: _selectedFaultType,
          faultDescription: _problemController.text.trim(),
          status: _selectedStatus,
          totalAmount: double.tryParse(_totalAmountController.text) ?? 0.0,
          advanceAmount: double.tryParse(_advanceAmountController.text) ?? 0.0,
          remainingAmount:
              double.tryParse(_remainingAmountController.text) ?? 0.0,
          spareParts: _sparePartsController.text.trim(),
          updatedAt: DateTime.now(),
        );

        // تحديث الجهاز في قاعدة البيانات
        await DatabaseService.updateDevice(updatedDevice);

        // إضافة دفعة المقدم الجديدة إذا كانت أكبر من 0
        if (updatedDevice.advanceAmount > 0) {
          final advancePayment = Payment(
            deviceId: widget.existingDevice.id!,
            amount: updatedDevice.advanceAmount,
            type: 'مقدم',
            notes: 'دفعة المقدم للعطل الجديد - ${updatedDevice.faultType}',
            createdAt: DateTime.now(),
          );

          await DatabaseService.addPayment(advancePayment);
        }

        // إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إضافة العطل الجديد بنجاح للجهاز ${widget.existingDevice.deviceId}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.of(context).pop();

        // استدعاء callback لتحديث القائمة
        if (widget.onFaultAdded != null) {
          widget.onFaultAdded!();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إضافة العطل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 650,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.build, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'إضافة عطل جديد',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'للجهاز: ${widget.existingDevice.deviceId}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // معلومات الجهاز والعميل (للمراجعة)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات الجهاز',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'العميل: ${widget.existingDevice.clientName}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'الهاتف: ${widget.existingDevice.clientPhone1}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'الجهاز: ${widget.existingDevice.brand} ${widget.existingDevice.model}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'النوع: ${widget.existingDevice.deviceCategory}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // نوع العطل
                      DropdownButtonFormField<String>(
                        value:
                            _selectedFaultType.isEmpty
                                ? null
                                : _selectedFaultType,
                        decoration: InputDecoration(
                          labelText: 'نوع العطل *',
                          prefixIcon: const Icon(Icons.build),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                        items:
                            _faultTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFaultType = value!;
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'يرجى اختيار نوع العطل' : null,
                      ),
                      const SizedBox(height: 16),

                      // وصف العطل
                      TextFormField(
                        controller: _problemController,
                        decoration: InputDecoration(
                          labelText: 'وصف العطل *',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                        maxLines: 3,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'يرجى إدخال وصف العطل' : null,
                      ),
                      const SizedBox(height: 16),

                      // حالة الجهاز
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'حالة الجهاز',
                          prefixIcon: const Icon(Icons.info),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                        items:
                            _statusOptions
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // التكلفة المالية
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _totalAmountController,
                              decoration: InputDecoration(
                                labelText: 'التكلفة الإجمالية',
                                prefixIcon: const Icon(Icons.attach_money),
                                suffixText: '₪',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.blue[600]!,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _advanceAmountController,
                              decoration: InputDecoration(
                                labelText: 'المقدم المدفوع',
                                prefixIcon: const Icon(Icons.payment),
                                suffixText: '₪',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.blue[600]!,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // المتبقي (محسوب تلقائياً)
                      TextFormField(
                        controller: _remainingAmountController,
                        decoration: InputDecoration(
                          labelText: 'المبلغ المتبقي',
                          prefixIcon: const Icon(Icons.calculate),
                          suffixText: '₪',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                        readOnly: true,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // قطع الغيار
                      TextFormField(
                        controller: _sparePartsController,
                        decoration: InputDecoration(
                          labelText: 'قطع الغيار المطلوبة',
                          prefixIcon: const Icon(Icons.settings),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // الأزرار
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveFault,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'إضافة العطل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
