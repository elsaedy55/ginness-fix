import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/payment.dart';
import '../services/database_service.dart';

class AddPaymentDialog extends StatefulWidget {
  final Device device;
  final VoidCallback? onPaymentAdded;

  const AddPaymentDialog({
    super.key,
    required this.device,
    this.onPaymentAdded,
  });

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'دفعة';
  bool _isLoading = false;
  double _totalPaid = 0.0;
  List<Payment> _payments = [];

  final List<String> _paymentTypes = [
    'دفعة',
    'مقدم',
    'تسوية نهائية',
    'استرداد',
  ];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // استخدام الدالة الجديدة للحصول على معلومات مالية شاملة
      final financialInfo = await DatabaseService.getDeviceFinancialInfo(
        widget.device.id!,
      );
      final payments = await DatabaseService.getDevicePayments(
        widget.device.id!,
      );

      setState(() {
        _payments = payments;
        _totalPaid = financialInfo['total_paid'] ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الدفعات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addPayment() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final amount = double.parse(_amountController.text);

      // التحقق من صحة المبلغ
      if (amount <= 0) {
        throw Exception('يجب أن يكون المبلغ أكبر من صفر');
      }

      // التحقق من أن الاسترداد لا يتجاوز المدفوع
      if (_selectedType == 'استرداد' && amount > _totalPaid) {
        throw Exception(
          'لا يمكن استرداد مبلغ أكبر من إجمالي المدفوع (${_totalPaid.toStringAsFixed(2)} ₪)',
        );
      }

      // التحقق من عدم تجاوز إجمالي المبلغ للدفعات العادية
      final newTotal =
          _totalPaid + (_selectedType == 'استرداد' ? -amount : amount);
      if (_selectedType != 'استرداد' && newTotal > widget.device.totalAmount) {
        final willExceed = newTotal - widget.device.totalAmount;
        final confirmed = await _showExceedConfirmation(willExceed);
        if (!confirmed) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // إنشاء الدفعة
      final payment = Payment(
        deviceId: widget.device.id!,
        amount: _selectedType == 'استرداد' ? -amount : amount,
        type: _selectedType,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      // حفظ في قاعدة البيانات
      await DatabaseService.addPayment(payment);

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة الدفعة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // تحديث القائمة
      await _loadPayments();

      // مسح النموذج
      _amountController.clear();
      _notesController.clear();
      setState(() {
        _selectedType = 'دفعة';
        _isLoading = false;
      });

      // استدعاء callback
      if (widget.onPaymentAdded != null) {
        widget.onPaymentAdded!();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إضافة الدفعة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showExceedConfirmation(double exceedAmount) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('تحذير'),
                content: Text(
                  'سيتجاوز إجمالي المدفوع التكلفة المطلوبة بـ ${exceedAmount.toStringAsFixed(2)} ₪.\n'
                  'هل تريد المتابعة؟',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('متابعة'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.device.totalAmount - _totalPaid;
    final progress =
        widget.device.totalAmount > 0
            ? (_totalPaid / widget.device.totalAmount).clamp(0.0, 1.0)
            : 0.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 650, minHeight: 400),
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
                  colors: [Colors.green[600]!, Colors.green[800]!],
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
                  const Icon(Icons.payment, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'إدارة الدفعات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'الجهاز: ${widget.device.deviceId}',
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

            // معلومات مالية سريعة
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'التكلفة الإجمالية',
                          '${widget.device.totalAmount.toStringAsFixed(2)} ₪',
                          Icons.receipt_long,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'إجمالي المدفوع',
                          '${_totalPaid.toStringAsFixed(2)} ₪',
                          Icons.paid,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'المتبقي',
                          '${remaining.toStringAsFixed(2)} ₪',
                          Icons.pending,
                          remaining > 0 ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // شريط التقدم
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'نسبة السداد',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  progress >= 1.0 ? Colors.green : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? Colors.green : Colors.blue,
                        ),
                        minHeight: 8,
                      ),
                      if (progress >= 1.0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[700],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'تم السداد بالكامل',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // نموذج إضافة دفعة
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نموذج الإضافة
                    Expanded(
                      flex: 2,
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'إضافة دفعة جديدة',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // نوع الدفعة
                              DropdownButtonFormField<String>(
                                value: _selectedType,
                                decoration: InputDecoration(
                                  labelText: 'نوع الدفعة',
                                  prefixIcon: const Icon(Icons.category),
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
                                      color: Colors.green[600]!,
                                    ),
                                  ),
                                ),
                                items:
                                    _paymentTypes
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  type == 'استرداد'
                                                      ? Icons.undo
                                                      : Icons.payment,
                                                  size: 16,
                                                  color:
                                                      type == 'استرداد'
                                                          ? Colors.red
                                                          : Colors.green,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(type),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // المبلغ مع أزرار سريعة
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _amountController,
                                    decoration: InputDecoration(
                                      labelText: 'المبلغ',
                                      prefixIcon: const Icon(
                                        Icons.attach_money,
                                      ),
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
                                          color: Colors.green[600]!,
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال المبلغ';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'يرجى إدخال رقم صحيح';
                                      }
                                      if (double.parse(value) <= 0) {
                                        return 'يجب أن يكون المبلغ أكبر من صفر';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  // أزرار التعبئة السريعة
                                  if (remaining > 0) ...[
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        _buildQuickAmountChip(
                                          '${(remaining / 2).toStringAsFixed(0)} ₪',
                                          remaining / 2,
                                        ),
                                        _buildQuickAmountChip(
                                          '${remaining.toStringAsFixed(0)} ₪ (كامل)',
                                          remaining,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 16),

                              // ملاحظات
                              TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: 'ملاحظات (اختياري)',
                                  prefixIcon: const Icon(Icons.note),
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
                                      color: Colors.green[600]!,
                                    ),
                                  ),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 20),

                              // زر الإضافة
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _addPayment,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
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
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : Text(
                                            _selectedType == 'استرداد'
                                                ? 'إضافة استرداد'
                                                : 'إضافة دفعة',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 24),

                    // قائمة الدفعات
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'سجل الدفعات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  _isLoading
                                      ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                      : _payments.isEmpty
                                      ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.payment_outlined,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'لا توجد دفعات بعد',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      : ListView.separated(
                                        padding: const EdgeInsets.all(8),
                                        itemCount: _payments.length,
                                        separatorBuilder:
                                            (context, index) => Divider(
                                              height: 1,
                                              color: Colors.grey[300],
                                            ),
                                        itemBuilder: (context, index) {
                                          final payment = _payments[index];
                                          return _buildPaymentItem(payment);
                                        },
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountChip(String label, double amount) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _amountController.text = amount.toStringAsFixed(2);
      },
      backgroundColor: Colors.blue[50],
      labelStyle: TextStyle(color: Colors.blue[700], fontSize: 12),
    );
  }

  Widget _buildPaymentItem(Payment payment) {
    final isRefund = payment.amount < 0;
    final displayAmount = payment.amount.abs();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isRefund ? Colors.red[50] : Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isRefund ? Icons.undo : Icons.payment,
              color: isRefund ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      payment.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${isRefund ? "-" : "+"}${displayAmount.toStringAsFixed(2)} ₪',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isRefund ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (payment.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    payment.notes,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
