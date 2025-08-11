import 'package:flutter/material.dart';
import 'add_device_wizard.dart';

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

  // قائمة الأجهزة (مبسطة)
  final List<Map<String, String>> _allDevices = [
    {
      'id': 'GF-1-0001',
      'name': 'iPhone 13 Pro',
      'deviceType': 'iPhone/iOS',
      'client': 'محمد أحمد السعدي',
      'phone': '0599123456',
      'faultType': 'هاردوير',
      'problem': 'شاشة مكسورة',
      'status': 'قيد الإصلاح',
      'cost': '250',
      'date': '2024/12/15',
    },
    {
      'id': 'GF-1-0002',
      'name': 'Samsung Galaxy S21',
      'deviceType': 'Android',
      'client': 'فاطمة علي محمد',
      'phone': '0598765432',
      'faultType': 'بطارية',
      'problem': 'بطارية لا تشحن',
      'status': 'مكتمل',
      'cost': '180',
      'date': '2024/12/14',
    },
    {
      'id': 'GF-1-0003',
      'name': 'MacBook Pro M1',
      'deviceType': 'Mac',
      'client': 'عبد الله إبراهيم',
      'phone': '0597654321',
      'faultType': 'سوفت وير',
      'problem': 'لا يعمل',
      'status': 'في الانتظار',
      'cost': '400',
      'date': '2024/12/13',
    },
  ];

  // التحقق من وجود فلاتر نشطة
  bool get _hasActiveFilters {
    return _selectedStatus != 'الكل' ||
        _selectedFaultType != 'الكل' ||
        _selectedDeviceType != 'الكل' ||
        _selectedDateFilter != 'كل التواريخ' ||
        _searchController.text.isNotEmpty;
  }

  // فلترة الأجهزة
  List<Map<String, String>> get _filteredDevices {
    return _allDevices.where((device) {
      // فلترة البحث
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        if (!device['id']!.toLowerCase().contains(searchTerm) &&
            !device['client']!.toLowerCase().contains(searchTerm) &&
            !device['problem']!.toLowerCase().contains(searchTerm) &&
            !device['faultType']!.toLowerCase().contains(searchTerm)) {
          return false;
        }
      }

      // فلترة الحالة
      if (_selectedStatus != 'الكل' && device['status'] != _selectedStatus) {
        return false;
      }

      // فلترة نوع العطل
      if (_selectedFaultType != 'الكل' &&
          device['faultType'] != _selectedFaultType) {
        return false;
      }

      // فلترة نوع الجهاز
      if (_selectedDeviceType != 'الكل' &&
          device['deviceType'] != _selectedDeviceType) {
        return false;
      }

      // فلترة التاريخ
      if (_selectedDateRange != null) {
        try {
          final deviceDate = DateTime.parse(
            device['date']!.replaceAll('/', '-'),
          );
          if (deviceDate.isBefore(_selectedDateRange!.start) ||
              deviceDate.isAfter(_selectedDateRange!.end)) {
            return false;
          }
        } catch (e) {
          return false;
        }
      }

      return true;
    }).toList();
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
                                builder: (context) => const AddDeviceWizard(),
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

          // معلومات النتائج
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'عرض ${_filteredDevices.length} من أصل ${_allDevices.length} جهاز',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // جدول الأجهزة
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // رأس الجدول
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'رقم الجهاز',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'العميل',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'نوع العطل',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'الحالة',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'التكلفة',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // محتوى الجدول
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredDevices.length,
                      itemBuilder: (context, index) {
                        final device = _filteredDevices[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  device['id']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device['client']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      device['phone']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(device['faultType']!),
                                    Text(
                                      device['problem']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        device['status'] == 'مكتمل'
                                            ? Colors.green[100]
                                            : device['status'] == 'قيد الإصلاح'
                                            ? Colors.orange[100]
                                            : device['status'] == 'في الانتظار'
                                            ? Colors.blue[100]
                                            : Colors.red[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    device['status']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          device['status'] == 'مكتمل'
                                              ? Colors.green[700]
                                              : device['status'] ==
                                                  'قيد الإصلاح'
                                              ? Colors.orange[700]
                                              : device['status'] ==
                                                  'في الانتظار'
                                              ? Colors.blue[700]
                                              : Colors.red[700],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${device['cost']} ₪',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder:
                                      (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('تحرير'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('حذف'),
                                        ),
                                      ],
                                  onSelected: (value) {
                                    // TODO: تنفيذ الإجراءات
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
