import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ginness/widgets/add_device_wizard.dart';
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
  // pagination
  static const int _pageSize = 30;
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // debounce for search
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _resetAndLoad();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // تحميل الأجهزة من قاعدة البيانات
  // Reset pagination and load first page
  Future<void> _resetAndLoad() async {
    _offset = 0;
    _hasMore = true;
    _devices = [];
    _filteredDevices = [];
    await _loadNextPage(replace: true);
  }

  // Load next page from server
  Future<void> _loadNextPage({bool replace = false}) async {
    if (!_hasMore && !replace) return;

    if (replace) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final results = await DatabaseService.getDevicesPaged(
        limit: _pageSize,
        offset: _offset,
        searchTerm:
            _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
        status: _selectedStatus,
        deviceCategory: _selectedDeviceType,
        faultType: _selectedFaultType,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );

      setState(() {
        if (replace) {
          _devices = results;
        } else {
          _devices.addAll(results);
        }

        _filteredDevices = List.from(_devices);
        _offset += results.length;
        _hasMore = results.length >= _pageSize;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل الأجهزة: ${e.toString()}';
      });
    } finally {
      if (replace) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  // تطبيق الفلاتر
  void _applyFilters() {
    // Client-side filtering is still applied to the currently loaded page(s)
    List<Device> filtered =
        _devices.where((device) {
          // فلتر البحث النصي
          final searchTerm = _searchController.text.toLowerCase();
          if (searchTerm.isNotEmpty) {
            final serial = (device.serialNumber ?? '').toLowerCase();
            if (!device.deviceId.toLowerCase().contains(searchTerm) &&
                !serial.contains(searchTerm) &&
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

          // فلتر التاريخ: قارن تواريخ فقط (بالتوقيت المحلي) لتجنب مشاكل الـ timezone
          if (_selectedDateRange != null) {
            // Use date-only comparison to avoid timezone edge cases
            final deviceDateLocal = device.createdAt.toLocal();
            final deviceDateOnly = DateTime(
              deviceDateLocal.year,
              deviceDateLocal.month,
              deviceDateLocal.day,
            );

            final startDateOnly = DateTime(
              _selectedDateRange!.start.year,
              _selectedDateRange!.start.month,
              _selectedDateRange!.start.day,
            );

            final endDateOnly = DateTime(
              _selectedDateRange!.end.year,
              _selectedDateRange!.end.month,
              _selectedDateRange!.end.day,
            );

            if (deviceDateOnly.isBefore(startDateOnly) ||
                deviceDateOnly.isAfter(endDateOnly)) {
              return false;
            }
          }

          return true;
        }).toList();

    setState(() {
      _filteredDevices = filtered;
    });
  }

  // Triggered by search input with debounce to avoid frequent DB calls
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      // Reset and fetch from server using search term
      await _resetAndLoad();
    });
  }

  // إضافة عطل جديد للجهاز (نفس الجهاز بعطل جديد)
  void _addNewFault(Device device) {
    showDialog(
      context: context,
      builder:
          (context) => AddNewFaultSimpleDialog(
            existingDevice: device,
            onFaultAdded: _resetAndLoad,
          ),
    );
  }

  // تعديل الجهاز
  void _editDevice(Device device) {
    showDialog(
      context: context,
      builder:
          (context) =>
              EditDeviceDialog(device: device, onDeviceUpdated: _resetAndLoad),
    );
  }

  // إضافة دفعة للجهاز
  void _addPayment(Device device) {
    showDialog(
      context: context,
      builder:
          (context) =>
              AddPaymentDialog(device: device, onPaymentAdded: _resetAndLoad),
    );
  }

  // عرض تفاصيل الجهاز
  void _showDeviceDetails(Device device) {
    showDialog(
      context: context,
      builder:
          (context) => DeviceDetailsDialog(
            device: device,
            onDeviceUpdated: _resetAndLoad,
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
        await _resetAndLoad();
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
    'سوفتوير',
    'Jetag',
    'هاردوير ايفون',
    'هاردوير اندرويد',
    'باغه / شاشه',
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
      _applyFilters();
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
            end: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
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
            end: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
          );
          break;
        case 'هذا الشهر':
          _selectedDateRange = DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            // DateTime handles month overflow; day 0 gives last day of previous month
            end: DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999),
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

  final TextStyle headerStyle = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Color(0xFF616161), // grey[700]
  );

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
                            onChanged: (value) {
                              // Apply filters as the user types
                              _applyFilters();
                            },
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
                                          // Clear search and reapply filters
                                          _searchController.clear();
                                          _applyFilters();
                                          setState(() {});
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
                      // زر إضافة الجهاز
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
                                      onDeviceAdded: _resetAndLoad,
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
                            onTap: _isLoading ? null : _resetAndLoad,
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
                  // الفلاتر الجديدة
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: Text('الحالة: $_selectedStatus'),
                          selected: _selectedStatus != 'الكل',
                          avatar: Icon(
                            Icons.task_alt_rounded,
                            size: 18,
                            color: Colors.blue,
                          ),
                          onSelected: (_) async {
                            final result = await showDialog<String>(
                              context: context,
                              builder:
                                  (context) => SimpleDialog(
                                    title: Text('اختر الحالة'),
                                    children:
                                        _statusOptions
                                            .map(
                                              (opt) => SimpleDialogOption(
                                                child: Text(opt),
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      opt,
                                                    ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                            );
                            if (result != null) {
                              setState(() {
                                _selectedStatus = result;
                                _applyFilters();
                              });
                            }
                          },
                          selectedColor: Colors.blue[100],
                        ),
                        FilterChip(
                          label: Text('نوع العطل: $_selectedFaultType'),
                          selected: _selectedFaultType != 'الكل',
                          avatar: Icon(
                            Icons.build_rounded,
                            size: 18,
                            color: Colors.orange,
                          ),
                          onSelected: (_) async {
                            final result = await showDialog<String>(
                              context: context,
                              builder:
                                  (context) => SimpleDialog(
                                    title: Text('اختر نوع العطل'),
                                    children:
                                        _faultTypeOptions
                                            .map(
                                              (opt) => SimpleDialogOption(
                                                child: Text(opt),
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      opt,
                                                    ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                            );
                            if (result != null) {
                              setState(() {
                                _selectedFaultType = result;
                                _applyFilters();
                              });
                            }
                          },
                          selectedColor: Colors.orange[100],
                        ),
                        FilterChip(
                          label: Text('نوع الجهاز: $_selectedDeviceType'),
                          selected: _selectedDeviceType != 'الكل',
                          avatar: Icon(
                            Icons.devices_rounded,
                            size: 18,
                            color: Colors.green,
                          ),
                          onSelected: (_) async {
                            final result = await showDialog<String>(
                              context: context,
                              builder:
                                  (context) => SimpleDialog(
                                    title: Text('اختر نوع الجهاز'),
                                    children:
                                        _deviceTypeOptions
                                            .map(
                                              (opt) => SimpleDialogOption(
                                                child: Text(opt),
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      opt,
                                                    ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                            );
                            if (result != null) {
                              setState(() {
                                _selectedDeviceType = result;
                                _applyFilters();
                              });
                            }
                          },
                          selectedColor: Colors.green[100],
                        ),
                        FilterChip(
                          label: Text('التاريخ: $_selectedDateFilter'),
                          selected: _selectedDateFilter != 'كل التواريخ',
                          avatar: Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: Colors.purple,
                          ),
                          onSelected: (_) async {
                            final result = await showDialog<String>(
                              context: context,
                              builder:
                                  (context) => SimpleDialog(
                                    title: Text('اختر التاريخ'),
                                    children:
                                        _dateFilterOptions
                                            .map(
                                              (opt) => SimpleDialogOption(
                                                child: Text(opt),
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      opt,
                                                    ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                            );
                            if (result != null) {
                              setState(() {
                                _onDateFilterChanged(result);
                                _applyFilters();
                              });
                            }
                          },
                          selectedColor: Colors.purple[100],
                        ),
                        if (_hasActiveFilters)
                          ActionChip(
                            label: Text(
                              'مسح الكل',
                              style: TextStyle(color: Colors.red),
                            ),
                            avatar: Icon(
                              Icons.clear_all_rounded,
                              color: Colors.red,
                            ),
                            backgroundColor: Colors.red[50],
                            onPressed: _clearAllFilters,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // معلومات النتائج مع زر التحديث
          const SizedBox(height: 16),
          // جدول عرض الأجهزة الجديد
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    )
                    : _filteredDevices.isEmpty
                    ? Center(
                      child: Text(
                        'لا توجد أجهزة',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: DataTable(
                              columnSpacing: 24,
                              headingRowHeight: 48,
                              dataRowHeight: 56,
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('الماركة')),
                                DataColumn(label: Text('الموديل')),
                                DataColumn(label: Text('العميل')),
                                DataColumn(label: Text('الحالة')),
                                DataColumn(label: Text('المبلغ')),
                                DataColumn(label: Text('إجراءات')),
                              ],
                              rows:
                                  _filteredDevices.map((device) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(device.deviceId)),
                                        DataCell(Text(device.brand)),
                                        DataCell(Text(device.model)),
                                        DataCell(Text(device.clientName)),
                                        DataCell(Text(device.status)),
                                        DataCell(
                                          Text('${device.totalAmount} ج.م'),
                                        ),
                                        DataCell(
                                          Row(
                                            children: _buildActionButtons(
                                              device,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // دالة لتحديد لون الحالة
  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'قيد الإصلاح':
        return Colors.orange;
      case 'في الانتظار':
        return Colors.blue;
      case 'ملغي':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
