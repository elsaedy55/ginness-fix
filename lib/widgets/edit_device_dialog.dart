import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/database_service.dart';

class EditDeviceDialog extends StatefulWidget {
  final Device device;
  final Function() onDeviceUpdated;

  const EditDeviceDialog({
    super.key,
    required this.device,
    required this.onDeviceUpdated,
  });

  @override
  State<EditDeviceDialog> createState() => _EditDeviceDialogState();
}

class _EditDeviceDialogState extends State<EditDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clientNameController;
  late final TextEditingController _clientPhone1Controller;
  late final TextEditingController _clientPhone2Controller;
  late final TextEditingController _faultDescriptionController;
  late final TextEditingController _totalAmountController;
  late final TextEditingController _advanceAmountController;
  late final TextEditingController _remainingAmountController;
  late final TextEditingController _sparePartsController;

  late String _selectedGender;
  late String _selectedDeviceCategory;
  late String _selectedBrand;
  late String _selectedModel;
  late String _selectedOS;
  late String _selectedFaultType;
  late String _selectedStatus;

  bool _isLoading = false;

  // قوائم البيانات
  final List<String> _genderOptions = ['ذكر', 'أنثى'];
  final List<String> _deviceCategories = [
    'هاتف ذكي',
    'لاب توب',
    'تابلت',
    'ساعة ذكية',
    'أخرى',
  ];
  final List<String> _statusOptions = [
    'في الانتظار',
    'قيد الإصلاح',
    'مكتمل',
    'ملغي',
  ];
  final List<String> _faultTypes = [
    'شاشة',
    'بطارية',
    'هاردوير',
    'سوفت وير',
    'مياه',
    'صوت',
    'شبكة',
    'كاميرا',
    'أخرى',
  ];
  final List<String> _brands = [
    'Samsung',
    'Apple',
    'Huawei',
    'Xiaomi',
    'Oppo',
    'Vivo',
    'OnePlus',
    'Sony',
    'LG',
    'Nokia',
    'HP',
    'Dell',
    'Lenovo',
    'Asus',
    'Acer',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _clientNameController = TextEditingController(
      text: widget.device.clientName,
    );
    _clientPhone1Controller = TextEditingController(
      text: widget.device.clientPhone1,
    );
    _clientPhone2Controller = TextEditingController(
      text: widget.device.clientPhone2,
    );
    _faultDescriptionController = TextEditingController(
      text: widget.device.faultDescription,
    );
    _totalAmountController = TextEditingController(
      text: widget.device.totalAmount.toString(),
    );
    _advanceAmountController = TextEditingController(
      text: widget.device.advanceAmount.toString(),
    );
    _remainingAmountController = TextEditingController(
      text: widget.device.remainingAmount.toString(),
    );
    _sparePartsController = TextEditingController(
      text: widget.device.spareParts,
    );

    _selectedGender = widget.device.gender;
    _selectedDeviceCategory = widget.device.deviceCategory;
    _selectedBrand = widget.device.brand;
    _selectedModel = widget.device.model;
    _selectedOS = widget.device.operatingSystem;
    _selectedFaultType = widget.device.faultType;
    _selectedStatus = widget.device.status;
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhone1Controller.dispose();
    _clientPhone2Controller.dispose();
    _faultDescriptionController.dispose();
    _totalAmountController.dispose();
    _advanceAmountController.dispose();
    _remainingAmountController.dispose();
    _sparePartsController.dispose();
    super.dispose();
  }

  void _calculateRemainingAmount() {
    final total = double.tryParse(_totalAmountController.text) ?? 0.0;
    final advance = double.tryParse(_advanceAmountController.text) ?? 0.0;
    final remaining = total - advance;
    _remainingAmountController.text = remaining.toStringAsFixed(2);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedDevice = widget.device.copyWith(
        clientName: _clientNameController.text,
        clientPhone1: _clientPhone1Controller.text,
        clientPhone2: _clientPhone2Controller.text,
        gender: _selectedGender,
        deviceCategory: _selectedDeviceCategory,
        brand: _selectedBrand,
        model: _selectedModel,
        operatingSystem: _selectedOS,
        faultType: _selectedFaultType,
        faultDescription: _faultDescriptionController.text,
        status: _selectedStatus,
        totalAmount: double.tryParse(_totalAmountController.text) ?? 0.0,
        advanceAmount: double.tryParse(_advanceAmountController.text) ?? 0.0,
        remainingAmount:
            double.tryParse(_remainingAmountController.text) ?? 0.0,
        spareParts: _sparePartsController.text,
        updatedAt: DateTime.now(),
      );

      await DatabaseService.updateDevice(updatedDevice);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الجهاز بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onDeviceUpdated();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديث الجهاز: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
                const Icon(Icons.edit, size: 24),
                const SizedBox(width: 8),
                Text(
                  'تعديل الجهاز - ${widget.device.deviceId}',
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

            // محتوى النموذج
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // معلومات العميل
                      const Text(
                        'معلومات العميل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _clientNameController,
                              decoration: const InputDecoration(
                                labelText: 'اسم العميل',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال اسم العميل';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'الجنس',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  _genderOptions.map((gender) {
                                    return DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _clientPhone1Controller,
                              decoration: const InputDecoration(
                                labelText: 'رقم الهاتف الأول',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال رقم الهاتف';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _clientPhone2Controller,
                              decoration: const InputDecoration(
                                labelText: 'رقم الهاتف الثاني (اختياري)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // معلومات الجهاز
                      const Text(
                        'معلومات الجهاز',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedDeviceCategory,
                              decoration: const InputDecoration(
                                labelText: 'نوع الجهاز',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  _deviceCategories.map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDeviceCategory = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedBrand,
                              decoration: const InputDecoration(
                                labelText: 'الماركة',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  _brands.map((brand) {
                                    return DropdownMenuItem(
                                      value: brand,
                                      child: Text(brand),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBrand = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _selectedModel,
                              decoration: const InputDecoration(
                                labelText: 'الموديل',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                _selectedModel = value;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: _selectedOS,
                              decoration: const InputDecoration(
                                labelText: 'نظام التشغيل',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                _selectedOS = value;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // معلومات العطل
                      const Text(
                        'معلومات العطل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedFaultType,
                              decoration: const InputDecoration(
                                labelText: 'نوع العطل',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  _faultTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedFaultType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'حالة الجهاز',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  _statusOptions.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _faultDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'وصف العطل',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال وصف العطل';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // المعلومات المالية
                      const Text(
                        'المعلومات المالية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _totalAmountController,
                              decoration: const InputDecoration(
                                labelText: 'إجمالي التكلفة',
                                border: OutlineInputBorder(),
                                suffixText: 'جنيه',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _calculateRemainingAmount(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _advanceAmountController,
                              decoration: const InputDecoration(
                                labelText: 'المبلغ المُقدم',
                                border: OutlineInputBorder(),
                                suffixText: 'جنيه',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _calculateRemainingAmount(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _remainingAmountController,
                              decoration: const InputDecoration(
                                labelText: 'المبلغ المتبقي',
                                border: OutlineInputBorder(),
                                suffixText: 'جنيه',
                              ),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _sparePartsController,
                        decoration: const InputDecoration(
                          labelText: 'قطع الغيار المطلوبة (اختياري)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // أزرار الحفظ والإلغاء
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('حفظ التعديلات'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
