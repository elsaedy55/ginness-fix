import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/device_history.dart';
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
  final List<String> _models = [
    'iPhone 13',
    'iPhone 12',
    'Galaxy S23',
    'Galaxy S22',
    'Redmi Note 12',
    'MateBook D15',
    'MacBook Pro',
    'MacBook Air',
    'ThinkPad X1',
    'Inspiron 15',
    'Acer Aspire',
    'Oppo Reno 8',
    'Vivo V27',
    'OnePlus 11',
    'Sony Xperia 5',
    'LG Velvet',
    'Nokia G21',
    'HP Pavilion',
    'Lenovo Legion',
    'Asus ZenBook',
    'أخرى',
  ];
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clientNameController;
  late final TextEditingController _clientPhone1Controller;
  late final TextEditingController _clientPhone2Controller;
  late final TextEditingController _serialNumberController;
  late final TextEditingController _faultDescriptionController;
  late final TextEditingController _sparePartsController;

  late String _selectedGender;
  late String _selectedDeviceCategory;
  late String _selectedBrand;
  late String _selectedModel;
  late String _selectedOS;
  late String _selectedFaultType;
  late String _selectedStatus;

  bool _isLoading = false;
  List<DeviceHistory> _deviceHistory = [];
  bool _showFaultHistory = false;

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
    'سوفتوير',
    'Jetag',
    'هاردوير ايفون',
    'هاردوير اندرويد',
    'باغه / شاشه',
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
    _serialNumberController = TextEditingController(
      text: widget.device.serialNumber,
    );
    _faultDescriptionController = TextEditingController(
      text: widget.device.faultDescription,
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

    _loadDeviceHistory();
  }

  Future<void> _loadDeviceHistory() async {
    try {
      // جلب سجل الأعطال المؤرشفة
      final history = await DatabaseService.getDeviceHistory(
        widget.device.deviceId,
      );

      setState(() {
        _deviceHistory = history;
      });
    } catch (e) {
      debugPrint('خطأ في جلب سجل الأعطال: $e');
    }
  }

  Future<void> _updateDeviceStatus(String newStatus) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // تحديث حالة الجهاز الحالي
      final updatedDevice = widget.device.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      await DatabaseService.updateDevice(updatedDevice);

      setState(() {
        _selectedStatus = newStatus;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث حالة العطل إلى: $newStatus'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onDeviceUpdated();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تحديث حالة العطل: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateHistoryStatus(
    DeviceHistory history,
    String newStatus,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await DatabaseService.updateDeviceHistoryStatus(history.id!, newStatus);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث حالة العطل إلى: $newStatus'),
          backgroundColor: Colors.green,
        ),
      );

      // إعادة تحميل السجل
      _loadDeviceHistory();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تحديث حالة العطل: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhone1Controller.dispose();
    _clientPhone2Controller.dispose();
    _serialNumberController.dispose();
    _faultDescriptionController.dispose();
    _sparePartsController.dispose();
    super.dispose();
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
        serialNumber:
            _serialNumberController.text.trim().isEmpty
                ? null
                : _serialNumberController.text.trim(),
        gender: _selectedGender,
        deviceCategory: _selectedDeviceCategory,
        brand: _selectedBrand,
        model: _selectedModel,
        operatingSystem: _selectedOS,
        faultType: _selectedFaultType,
        faultDescription: _faultDescriptionController.text,
        status: _selectedStatus,
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
                              value:
                                  _genderOptions.contains(_selectedGender)
                                      ? _selectedGender
                                      : null,
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

                      // الرقم التسلسلي
                      TextFormField(
                        controller: _serialNumberController,
                        decoration: const InputDecoration(
                          labelText: 'الرقم التسلسلي (Serial Number)',
                          prefixIcon: Icon(Icons.qr_code),
                          border: OutlineInputBorder(),
                        ),
                        // serial number is optional now
                        validator: null,
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
                              value:
                                  _deviceCategories.contains(
                                        _selectedDeviceCategory,
                                      )
                                      ? _selectedDeviceCategory
                                      : null,
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
                              value:
                                  _brands.contains(_selectedBrand)
                                      ? _selectedBrand
                                      : null,
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
                            child: Autocomplete<String>(
                              optionsBuilder: (
                                TextEditingValue textEditingValue,
                              ) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<String>.empty();
                                }
                                return _models.where((String option) {
                                  return option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  );
                                });
                              },
                              initialValue: TextEditingValue(
                                text: _selectedModel,
                              ),
                              fieldViewBuilder: (
                                context,
                                controller,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'الموديل',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    _selectedModel = value;
                                  },
                                );
                              },
                              onSelected: (String selection) {
                                setState(() {
                                  _selectedModel = selection;
                                });
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
                              value:
                                  _faultTypes.contains(_selectedFaultType)
                                      ? _selectedFaultType
                                      : null,
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
                              value:
                                  _statusOptions.contains(_selectedStatus)
                                      ? _selectedStatus
                                      : null,
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

                      // قسم إدارة الأعطال
                      _buildFaultManagementSection(),

                      const SizedBox(height: 24),

                      // المعلومات المالية
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

  Widget _buildFaultManagementSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.build, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'إدارة الأعطال',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showFaultHistory = !_showFaultHistory;
                    });
                  },
                  child: Text(_showFaultHistory ? 'إخفاء' : 'عرض الكل'),
                ),
              ],
            ),
          ),

          // Current Fault
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildCurrentFaultCard(),
          ),

          // Fault History (if visible)
          if (_showFaultHistory) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الأعطال السابقة:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_deviceHistory.isEmpty)
                    const Text(
                      'لا توجد أعطال سابقة',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Column(
                      children:
                          _deviceHistory
                              .map((history) => _buildHistoryFaultCard(history))
                              .toList(),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentFaultCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(widget.device.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getStatusColor(widget.device.status)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.build_circle,
                color: _getStatusColor(widget.device.status),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'العطل الحالي',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              _buildStatusChip(widget.device.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'نوع العطل: ${widget.device.faultType}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'الوصف: ${widget.device.faultDescription}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),

          // Status Update Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تحديث الحالة:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 4,
                children:
                    ['في الانتظار', 'قيد الإصلاح', 'مكتمل', 'تم التسليم']
                        .where((status) => status != widget.device.status)
                        .map(
                          (status) => _buildStatusUpdateButton(
                            status,
                            () => _updateDeviceStatus(status),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryFaultCard(DeviceHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(history.status).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: _getStatusColor(history.status),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'عطل سابق',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              _buildStatusChip(history.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'نوع العطل: ${history.faultType}',
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            'الوصف: ${history.faultDescription}',
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 8),

          // Status Update Buttons for History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تاريخ الإنشاء: ${_formatDate(history.createdAt)}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              if (history.status != 'تم التسليم')
                Wrap(
                  spacing: 4,
                  children:
                      ['في الانتظار', 'قيد الإصلاح', 'مكتمل', 'تم التسليم']
                          .where((status) => status != history.status)
                          .map(
                            (status) => _buildStatusUpdateButton(
                              status,
                              () => _updateHistoryStatus(history, status),
                              isSmall: true,
                            ),
                          )
                          .toList(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusUpdateButton(
    String status,
    VoidCallback onPressed, {
    bool isSmall = false,
  }) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getStatusColor(status),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 6 : 8,
          vertical: isSmall ? 2 : 4,
        ),
        minimumSize: const Size(0, 0),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: isSmall ? 8 : 10, color: Colors.white),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'في الانتظار':
        return Colors.orange;
      case 'قيد الإصلاح':
        return Colors.blue;
      case 'مكتمل':
        return Colors.green;
      case 'تم التسليم':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
