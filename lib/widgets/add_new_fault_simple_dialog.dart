import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/payment.dart';
import '../services/database_service.dart';

class AddNewFaultSimpleDialog extends StatefulWidget {
  final Device existingDevice;
  final VoidCallback? onFaultAdded;

  const AddNewFaultSimpleDialog({
    super.key,
    required this.existingDevice,
    this.onFaultAdded,
  });

  @override
  State<AddNewFaultSimpleDialog> createState() =>
      _AddNewFaultSimpleDialogState();
}

class _AddNewFaultSimpleDialogState extends State<AddNewFaultSimpleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _problemController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _advanceAmountController = TextEditingController();
  final _sparePartsController = TextEditingController();

  String _selectedFaultType = '';
  bool _isLoading = false;

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

  @override
  void dispose() {
    _problemController.dispose();
    _totalAmountController.dispose();
    _advanceAmountController.dispose();
    _sparePartsController.dispose();
    super.dispose();
  }

  double get _calculatedRemaining {
    final newFaultCost = double.tryParse(_totalAmountController.text) ?? 0;
    final newAdvance = double.tryParse(_advanceAmountController.text) ?? 0;

    // التكلفة الإجمالية الجديدة = التكلفة السابقة + تكلفة العطل الجديد
    final totalNewAmount = widget.existingDevice.totalAmount + newFaultCost;

    // المتبقي = التكلفة الإجمالية الجديدة - (المدفوع سابقاً من existingDevice.advanceAmount) - المقدم الجديد
    final remaining =
        totalNewAmount - widget.existingDevice.advanceAmount - newAdvance;
    return remaining.clamp(0.0, double.infinity);
  }

  void _saveFault() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        // أولاً، أرشفة العطل الحالي
        await DatabaseService.archiveDevice(
          widget.existingDevice,
          notes:
              'تم أرشفة العطل السابق قبل إضافة عطل جديد - ${DateTime.now().toString().substring(0, 19)}',
        );

        // حساب التكاليف الجديدة (إضافة للتكلفة الإجمالية الحالية)
        final newFaultAmount =
            double.tryParse(_totalAmountController.text) ?? 0.0;
        final newAdvanceAmount =
            double.tryParse(_advanceAmountController.text) ?? 0.0;

        // جلب إجمالي المدفوع حتى الآن من جميع الدفعات السابقة
        final currentTotalPaid = await DatabaseService.getDeviceTotalPaid(
          widget.existingDevice.id!,
        );

        // حساب التكلفة الإجمالية الجديدة (التكلفة السابقة + التكلفة الجديدة)
        final totalAmountNew =
            widget.existingDevice.totalAmount + newFaultAmount;

        // حساب المبلغ المتبقي الجديد (التكلفة الإجمالية الجديدة - إجمالي المدفوع - المقدم الجديد)
        final remainingAmountNew = (totalAmountNew -
                currentTotalPaid -
                newAdvanceAmount)
            .clamp(0.0, double.infinity);

        final updatedDevice = widget.existingDevice.copyWith(
          faultType: _selectedFaultType,
          faultDescription: _problemController.text.trim(),
          status: 'في الانتظار',
          totalAmount: totalAmountNew, // التكلفة التراكمية
          remainingAmount: remainingAmountNew, // المتبقي الجديد
          spareParts: _sparePartsController.text.trim(),
          updatedAt: DateTime.now(),
        );

        // تحديث الجهاز في قاعدة البيانات
        await DatabaseService.updateDevice(updatedDevice);

        // إضافة دفعة المقدم للعطل الجديد إذا كان أكبر من 0
        if (newAdvanceAmount > 0) {
          final advancePayment = Payment(
            deviceId: widget.existingDevice.id!,
            amount: newAdvanceAmount,
            type: 'مقدم',
            notes: 'دفعة المقدم للعطل الجديد - $_selectedFaultType',
            createdAt: DateTime.now(),
          );

          await DatabaseService.addPayment(advancePayment);
        }

        // إظهار رسالة نجاح
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إضافة العطل الجديد بنجاح!\nالجهاز: ${widget.existingDevice.deviceId}\nالتكلفة الإجمالية الجديدة: ${totalAmountNew.toStringAsFixed(2)} جنيه\nالمتبقي: ${remainingAmountNew.toStringAsFixed(2)} جنيه',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );

          Navigator.of(context).pop();

          // استدعاء callback لتحديث القائمة
          if (widget.onFaultAdded != null) {
            widget.onFaultAdded!();
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في إضافة العطل: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 650,
        constraints: const BoxConstraints(maxHeight: 700),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[600]!, Colors.orange[800]!],
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
                  const Icon(Icons.add_circle, color: Colors.white, size: 28),
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
                          'للجهاز: ${widget.existingDevice.deviceId} - ${widget.existingDevice.clientName}',
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

            // معلومات مرجعية سريعة
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'معلومات الجهاز المرجعية',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.existingDevice.brand} ${widget.existingDevice.model}',
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'النوع: ${widget.existingDevice.deviceCategory}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'العطل السابق: ${widget.existingDevice.faultType} - ${widget.existingDevice.faultDescription}',
                  ),
                  const SizedBox(height: 8),
                  // المعلومات المالية الحالية
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('تكلفة الأعطال السابقة:'),
                            Text(
                              '${widget.existingDevice.totalAmount.toStringAsFixed(2)} جنيه',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('إجمالي المدفوع سابقاً:'),
                            Text(
                              '${widget.existingDevice.advanceAmount.toStringAsFixed(2)} جنيه',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('المتبقي قبل العطل الجديد:'),
                            Text(
                              '${widget.existingDevice.remainingAmount.toStringAsFixed(2)} جنيه',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // نوع العطل الجديد
                        DropdownButtonFormField<String>(
                          value:
                              _selectedFaultType.isEmpty
                                  ? null
                                  : _selectedFaultType,
                          decoration: InputDecoration(
                            labelText: 'نوع العطل الجديد *',
                            prefixIcon: const Icon(Icons.build_circle),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.orange[600]!,
                              ),
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
                                  value == null
                                      ? 'يرجى اختيار نوع العطل'
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        // وصف العطل الجديد
                        TextFormField(
                          controller: _problemController,
                          decoration: InputDecoration(
                            labelText: 'وصف العطل الجديد *',
                            prefixIcon: const Icon(Icons.description),
                            hintText: 'اكتب وصف مفصل للعطل الجديد...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.orange[600]!,
                              ),
                            ),
                          ),
                          maxLines: 3,
                          validator:
                              (value) =>
                                  value!.trim().isEmpty
                                      ? 'يرجى إدخال وصف العطل'
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        // التكلفة والدفعات
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _totalAmountController,
                                decoration: InputDecoration(
                                  labelText: 'تكلفة الإصلاح',
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
                                      color: Colors.orange[600]!,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged:
                                    (_) => setState(
                                      () {},
                                    ), // لتحديث المبلغ المتبقي
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  final amount = double.tryParse(value);
                                  if (amount == null || amount < 0) {
                                    return 'يرجى إدخال مبلغ صحيح';
                                  }
                                  return null;
                                },
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
                                      color: Colors.orange[600]!,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged:
                                    (_) => setState(
                                      () {},
                                    ), // لتحديث المبلغ المتبقي
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  final advance = double.tryParse(value) ?? 0;
                                  final total =
                                      double.tryParse(
                                        _totalAmountController.text,
                                      ) ??
                                      0;
                                  if (advance < 0) {
                                    return 'يرجى إدخال مبلغ صحيح';
                                  }
                                  if (total > 0 && advance > total) {
                                    return 'المقدم أكبر من التكلفة الإجمالية';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // عرض المبلغ المتبقي
                        if (_totalAmountController.text.isNotEmpty ||
                            _advanceAmountController.text.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calculate,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('التكلفة الإجمالية الجديدة: '),
                                    Text(
                                      '${(widget.existingDevice.totalAmount + (double.tryParse(_totalAmountController.text) ?? 0)).toStringAsFixed(2)} ₪',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.money_off,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('المبلغ المتبقي الجديد: '),
                                    Text(
                                      '${_calculatedRemaining.toStringAsFixed(2)} ₪',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // قطع الغيار
                        TextFormField(
                          controller: _sparePartsController,
                          decoration: InputDecoration(
                            labelText: 'قطع الغيار المطلوبة',
                            prefixIcon: const Icon(Icons.settings),
                            hintText: 'اكتب قطع الغيار المطلوبة...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.orange[600]!,
                              ),
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
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
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
                      onPressed: _isLoading ? null : _saveFault,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'حفظ العطل الجديد',
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
