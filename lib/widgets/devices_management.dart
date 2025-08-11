import 'package:flutter/material.dart';
import 'add_device_wizard.dart';
import 'edit_device_dialog.dart';
import 'add_payment_dialog.dart';
import 'device_details_dialog.dart';
import 'device_history_dialog.dart';
import 'add_new_fault_simple_dialog.dart';
import '../models/device.dart';
import '../services/database_service.dart';

class DevicesManagement extends StatefulWidget {
  const DevicesManagement({super.key});

  @override
  State<DevicesManagement> createState() => _DevicesManagementState();
}

class _DevicesManagementState extends State<DevicesManagement> {
  String _selectedStatus = 'الكل';
  String _selectedFaultType = 'الكل';
  String _selectedDeviceType = 'الكل';
  String _selectedDateFilter = 'كل التواريخ';
  DateTimeRange? _selectedDateRange;
  final TextEditingController _searchController = TextEditingController();

  // قائمة الأجهزة من قاعدة البيانات
  List<Device> _devices = [];
  List<Device> _filteredDevices = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  // تحميل الأجهزة من قاعدة البيانات
  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final devices = await DatabaseService.getAllDevices();
      setState(() {
        _devices = devices;
        _filteredDevices = devices;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'خطأ في تحميل الأجهزة: ${e.toString()}';
      });
    }
  }

  // تطبيق الفلاتر
  void _applyFilters() {
    List<Device> filtered =
        _devices.where((device) {
          // فلتر البحث النصي
          final searchTerm = _searchController.text.toLowerCase();
          if (searchTerm.isNotEmpty) {
            if (!device.deviceId.toLowerCase().contains(searchTerm) &&
                !device.serialNumber.toLowerCase().contains(searchTerm) &&
                !device.clientName.toLowerCase().contains(searchTerm) &&
                !device.faultDescription.toLowerCase().contains(searchTerm) &&
                !device.faultType.toLowerCase().contains(searchTerm)) {
              return false;
            }
          }

          // فلتر الحالة
          if (_selectedStatus != 'الكل' && device.status != _selectedStatus) {
            return false;
          }

          // فلتر نوع العطل
          if (_selectedFaultType != 'الكل' &&
              device.faultType != _selectedFaultType) {
            return false;
          }

          // فلتر نوع الجهاز
          if (_selectedDeviceType != 'الكل' &&
              device.deviceCategory != _selectedDeviceType) {
            return false;
          }

          return true;
        }).toList();

    setState(() {
      _filteredDevices = filtered;
    });
  }

  // إضافة عطل جديد للجهاز (نفس الجهاز بعطل جديد)
  void _addNewFault(Device device) {
    showDialog(
      context: context,
      builder:
          (context) => AddNewFaultSimpleDialog(
            existingDevice: device,
            onFaultAdded: _loadDevices,
          ),
    );
  }

  // تعديل الجهاز
  void _editDevice(Device device) {
    showDialog(
      context: context,
      builder:
          (context) =>
              EditDeviceDialog(device: device, onDeviceUpdated: _loadDevices),
    );
  }

  // إضافة دفعة للجهاز
  void _addPayment(Device device) {
    showDialog(
      context: context,
      builder:
          (context) =>
              AddPaymentDialog(device: device, onPaymentAdded: _loadDevices),
    );
  }

  // عرض تفاصيل الجهاز
  void _showDeviceDetails(Device device) {
    showDialog(
      context: context,
      builder:
          (context) => DeviceDetailsDialog(
            device: device,
            onDeviceUpdated: _loadDevices,
          ),
    );
  }

  // عرض سجل الجهاز
  void _showDeviceHistory(Device device) {
    showDialog(
      context: context,
      builder: (context) => DeviceHistoryDialog(deviceId: device.deviceId),
    );
  }

  // حذف جهاز
  void _deleteDevice(Device device) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد من حذف الجهاز ${device.deviceId}؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _performDeleteDevice(device);
                },
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // تنفيذ حذف الجهاز
  Future<void> _performDeleteDevice(Device device) async {
    try {
      if (device.id != null) {
        // أرشفة الجهاز في السجل قبل الحذف
        await DatabaseService.archiveDevice(
          device,
          notes: 'تم حذف الجهاز من النظام',
        );

        // حذف الجهاز من الجدول الحالي
        await DatabaseService.deleteDevice(device.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حذف الجهاز ${device.deviceId} بنجاح وإضافته للسجل',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadDevices();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حذف الجهاز: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // بناء أزرار الإجراءات للجهاز
  List<Widget> _buildActionButtons(Device device) {
    return [
      // زر عرض السجل
      IconButton(
        onPressed: () => _showDeviceHistory(device),
        icon: const Icon(Icons.history, color: Colors.purple, size: 16),
        tooltip: 'سجل الجهاز',
        padding: const EdgeInsets.all(2),
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      ),
      // زر عرض التفاصيل
      IconButton(
        onPressed: () => _showDeviceDetails(device),
        icon: const Icon(Icons.info, color: Colors.orange, size: 16),
        tooltip: 'عرض التفاصيل',
        padding: const EdgeInsets.all(2),
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      ),
      // زر إضافة عطل جديد
      IconButton(
        onPressed: () => _addNewFault(device),
        icon: const Icon(Icons.add_circle, color: Colors.indigo, size: 16),
        tooltip: 'إضافة عطل جديد',
        padding: const EdgeInsets.all(2),
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      ),
      // زر إضافة دفعة
      IconButton(
        onPressed: () => _addPayment(device),
        icon: const Icon(Icons.payment, color: Colors.green, size: 16),
        tooltip: 'إضافة دفعة',
        padding: const EdgeInsets.all(2),
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      ),
      // زر التعديل
      IconButton(
        onPressed: () => _editDevice(device),
        icon: const Icon(Icons.edit, color: Colors.blue, size: 16),
        tooltip: 'تعديل',
        padding: const EdgeInsets.all(2),
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      ),
      // زر الحذف
      IconButton(
        onPressed: () => _deleteDevice(device),
        icon: const Icon(Icons.delete, color: Colors.red, size: 16),
        tooltip: 'حذف',
        padding: const EdgeInsets.all(2),
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      ),
    ];
  }

  final List<String> _dateFilterOptions = [
    'كل التواريخ',
    'اليوم',
    'هذا الأسبوع',
    'هذا الشهر',
    'اختيار مخصص',
  ];

  final List<String> _statusOptions = [
    'الكل',
    'قيد الإصلاح',
    'مكتمل',
    'في الانتظار',
    'ملغي',
  ];

  final List<String> _faultTypeOptions = [
    'الكل',
    'سوفت وير',
    'هاردوير',
    'شاشة',
    'بطارية',
    'مياه',
    'شبكة',
    'صوت',
    'كاميرا',
    'أخرى',
  ];

  final List<String> _deviceTypeOptions = [
    'الكل',
    'iPhone/iOS',
    'Android',
    'Windows',
    'Mac',
    'تابلت',
    'لاب توب',
  ];

  // التحقق من وجود فلاتر نشطة
  bool get _hasActiveFilters {
    return _selectedStatus != 'الكل' ||
        _selectedFaultType != 'الكل' ||
        _selectedDeviceType != 'الكل' ||
        _selectedDateFilter != 'كل التواريخ' ||
        _searchController.text.isNotEmpty;
  }

  // مسح جميع الفلاتر
  void _clearAllFilters() {
    setState(() {
      _selectedStatus = 'الكل';
      _selectedFaultType = 'الكل';
      _selectedDeviceType = 'الكل';
      _selectedDateFilter = 'كل التواريخ';
      _selectedDateRange = null;
      _searchController.clear();
    });
  }

  // التعامل مع تغيير فلتر التاريخ
  void _onDateFilterChanged(String value) {
    setState(() {
      _selectedDateFilter = value;

      final now = DateTime.now();
      switch (value) {
        case 'اليوم':
          _selectedDateRange = DateTimeRange(
            start: DateTime(now.year, now.month, now.day),
            end: DateTime(now.year, now.month, now.day, 23, 59, 59),
          );
          break;
        case 'هذا الأسبوع':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          _selectedDateRange = DateTimeRange(
            start: DateTime(
              startOfWeek.year,
              startOfWeek.month,
              startOfWeek.day,
            ),
            end: DateTime(now.year, now.month, now.day, 23, 59, 59),
          );
          break;
        case 'هذا الشهر':
          _selectedDateRange = DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
          );
          break;
        case 'اختيار مخصص':
          _selectDateRange();
          break;
        case 'كل التواريخ':
        default:
          _selectedDateRange = null;
          break;
      }
    });
  }

  // اختيار نطاق التاريخ
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _selectedDateFilter = 'اختيار مخصص';
      });
    }
  }

  // بناء فلتر بسيط
  Widget _buildSimpleFilter({
    required String label,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    final isActive = value != 'الكل';

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(
            Icons.expand_more,
            color: isActive ? Colors.white : Colors.grey[600],
            size: 20,
          ),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[800],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          elevation: 8,
          menuMaxHeight: 250,
          items:
              options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color:
                              option == value
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          option,
                          style: TextStyle(
                            color:
                                option == value
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[800],
                            fontWeight:
                                option == value
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive ? Colors.white : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          selectedItemBuilder: (BuildContext context) {
            return options.map<Widget>((String item) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isActive ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  // بناء فلتر التاريخ
  Widget _buildDateFilter() {
    final isActive = _selectedDateFilter != 'كل التواريخ';

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDateFilter,
          icon: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.expand_more,
              color: isActive ? Colors.white : Colors.grey[600],
              size: 16,
            ),
          ),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[800],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 12,
          menuMaxHeight: 300,
          items:
              _dateFilterOptions.map((String option) {
                final isSelected = option == _selectedDateFilter;
                return DropdownMenuItem<String>(
                  value: option,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1)
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _getDateFilterIcon(option),
                            size: 14,
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          option,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[700],
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _onDateFilterChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  // الحصول على أيقونة فلتر التاريخ
  IconData _getDateFilterIcon(String option) {
    switch (option) {
      case 'اليوم':
        return Icons.today_rounded;
      case 'هذا الأسبوع':
        return Icons.view_week_rounded;
      case 'هذا الشهر':
        return Icons.calendar_month_rounded;
      case 'اختيار مخصص':
        return Icons.date_range_rounded;
      case 'كل التواريخ':
      default:
        return Icons.calendar_today_rounded;
    }
  }

  // بناء زر مسح الفلاتر
  Widget _buildClearButton() {
    return InkWell(
      onTap: _clearAllFilters,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[400]!, Colors.red[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.red[300]!, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.clear_all_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'مسح الكل',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط البحث والفلاتر العصري البسيط
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // البحث وزر الإضافة
                  Row(
                    children: [
                      // مربع البحث
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'ابحث عن جهاز، عميل، أو نوع العطل...',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                              ),
                              suffixIcon:
                                  _searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                          });
                                        },
                                      )
                                      : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // زر إضافة الجهاز العصري والهادئ
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AddDeviceWizard(
                                      onDeviceAdded: _loadDevices,
                                    ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: Theme.of(context).primaryColor,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'إضافة جهاز',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // زر تحديث البيانات
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _isLoading ? null : _loadDevices,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.blue[600]!,
                                              ),
                                        ),
                                      )
                                      : Icon(
                                        Icons.refresh_rounded,
                                        color: Colors.blue[600],
                                        size: 20,
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // الفلاتر العصرية
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          _buildSimpleFilter(
                            label: 'الحالة',
                            value: _selectedStatus,
                            options: _statusOptions,
                            onChanged:
                                (value) =>
                                    setState(() => _selectedStatus = value),
                            icon: Icons.task_alt_rounded,
                          ),

                          const SizedBox(width: 16),

                          _buildSimpleFilter(
                            label: 'نوع العطل',
                            value: _selectedFaultType,
                            options: _faultTypeOptions,
                            onChanged:
                                (value) =>
                                    setState(() => _selectedFaultType = value),
                            icon: Icons.build_rounded,
                          ),

                          const SizedBox(width: 16),

                          _buildSimpleFilter(
                            label: 'نوع الجهاز',
                            value: _selectedDeviceType,
                            options: _deviceTypeOptions,
                            onChanged:
                                (value) =>
                                    setState(() => _selectedDeviceType = value),
                            icon: Icons.devices_rounded,
                          ),

                          const SizedBox(width: 16),

                          _buildDateFilter(),

                          const SizedBox(width: 16),

                          if (_hasActiveFilters) _buildClearButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // جدول الأجهزة
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // رأس الجدول المحسن
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[600]!, Colors.blue[700]!],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'رقم الجهاز',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'العميل',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'نوع العطل',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'الحالة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'حالة السداد',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'التكلفة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'الإجراءات',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // محتوى الجدول مع مؤشر التحميل
                    Expanded(
                      child:
                          _isLoading
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue[600]!,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'جاري تحميل الأجهزة...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : _errorMessage.isNotEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _errorMessage,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _loadDevices,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('إعادة المحاولة'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[600],
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : _filteredDevices.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.devices_other,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'لا توجد أجهزة',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'قم بإضافة أول جهاز للبدء',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: _filteredDevices.length,
                                itemBuilder: (context, index) {
                                  final device = _filteredDevices[index];

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[100]!,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // رقم الجهاز
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.blue[200]!,
                                                ),
                                              ),
                                              child: Text(
                                                device.deviceId,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[800],
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          // معلومات العميل
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  device.clientName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.phone,
                                                      size: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      device.clientPhone1,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          // نوع العطل
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    device.faultType,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.orange[800],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  device
                                                              .faultDescription
                                                              .length >
                                                          30
                                                      ? '${device.faultDescription.substring(0, 30)}...'
                                                      : device.faultDescription,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          // حالة الجهاز
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    device.status == 'مكتمل'
                                                        ? Colors.green[100]
                                                        : device.status ==
                                                            'قيد الإصلاح'
                                                        ? Colors.orange[100]
                                                        : device.status ==
                                                            'في الانتظار'
                                                        ? Colors.blue[100]
                                                        : Colors.red[100],
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color:
                                                      device.status == 'مكتمل'
                                                          ? Colors.green[300]!
                                                          : device.status ==
                                                              'قيد الإصلاح'
                                                          ? Colors.orange[300]!
                                                          : device.status ==
                                                              'في الانتظار'
                                                          ? Colors.blue[300]!
                                                          : Colors.red[300]!,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    device.status == 'مكتمل'
                                                        ? Icons.check_circle
                                                        : device.status ==
                                                            'قيد الإصلاح'
                                                        ? Icons.build_circle
                                                        : device.status ==
                                                            'في الانتظار'
                                                        ? Icons.hourglass_empty
                                                        : Icons.cancel,
                                                    size: 14,
                                                    color:
                                                        device.status == 'مكتمل'
                                                            ? Colors.green[700]
                                                            : device.status ==
                                                                'قيد الإصلاح'
                                                            ? Colors.orange[700]
                                                            : device.status ==
                                                                'في الانتظار'
                                                            ? Colors.blue[700]
                                                            : Colors.red[700],
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      device.status,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            device.status ==
                                                                    'مكتمل'
                                                                ? Colors
                                                                    .green[700]
                                                                : device.status ==
                                                                    'قيد الإصلاح'
                                                                ? Colors
                                                                    .orange[700]
                                                                : device.status ==
                                                                    'في الانتظار'
                                                                ? Colors
                                                                    .blue[700]
                                                                : Colors
                                                                    .red[700],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // حالة الدفع
                                          Expanded(
                                            flex: 2,
                                            child: FutureBuilder<double>(
                                              future:
                                                  device.id != null
                                                      ? DatabaseService.getDeviceTotalPaid(
                                                        device.id!,
                                                      )
                                                      : Future.value(0.0),
                                              builder: (context, snapshot) {
                                                final totalPaid =
                                                    snapshot.data ?? 0.0;
                                                final remaining =
                                                    device.totalAmount -
                                                    totalPaid;
                                                final isFullyPaid =
                                                    remaining <= 0;

                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isFullyPaid
                                                            ? Colors.green[50]
                                                            : Colors.red[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          isFullyPaid
                                                              ? Colors
                                                                  .green[200]!
                                                              : Colors
                                                                  .red[200]!,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        isFullyPaid
                                                            ? Icons
                                                                .check_circle_outline
                                                            : Icons
                                                                .warning_amber_rounded,
                                                        size: 16,
                                                        color:
                                                            isFullyPaid
                                                                ? Colors
                                                                    .green[700]
                                                                : Colors
                                                                    .red[700],
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        isFullyPaid
                                                            ? 'مسدد بالكامل'
                                                            : 'متبقي دفع',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              isFullyPaid
                                                                  ? Colors
                                                                      .green[700]
                                                                  : Colors
                                                                      .red[700],
                                                        ),
                                                      ),
                                                      if (!isFullyPaid)
                                                        Text(
                                                          '${remaining.toStringAsFixed(2)} ₪',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.red[600],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          // المبلغ الكلي
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${device.totalAmount} ₪',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          // أزرار الأفعال
                                          Expanded(
                                            flex: 1,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: _buildActionButtons(
                                                  device,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
