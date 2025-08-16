import 'package:flutter/material.dart';

class EmployeesManagement extends StatefulWidget {
  const EmployeesManagement({super.key});

  @override
  State<EmployeesManagement> createState() => _EmployeesManagementState();
}

class _EmployeesManagementState extends State<EmployeesManagement> {
  String _selectedDepartment = 'الكل';

  final List<String> _departmentOptions = [
    'الكل',
    'قسم الهواتف المحمولة',
    'قسم أجهزة الكمبيوتر',
    'قسم الأجهزة اللوحية',
    'قسم الشبكات',
    'قسم الصيانة العامة',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط الأدوات العلوي
          Row(
            children: [
              // مربع البحث
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'البحث في الموظفين...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // فلتر القسم
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDepartment,
                    items:
                        _departmentOptions.map((String department) {
                          return DropdownMenuItem<String>(
                            value: department,
                            child: Text(department),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedDepartment = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // زر إضافة موظف جديد
              ElevatedButton.icon(
                onPressed: () => _showAddEmployeeDialog(context),
                icon: const Icon(Icons.person_add),
                label: const Text('إضافة موظف'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // بطاقات الموظفين
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.8,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final employees = [
                  {
                    'name': 'أحمد الشريف',
                    'position': 'مدير قسم الهواتف',
                    'department': 'قسم الهواتف المحمولة',
                    'phone': '0599123456',
                    'email': 'ahmed@company.com',
                    'status': 'نشط',
                  },
                  {
                    'name': 'فاطمة علي محمد',
                    'position': 'فني صيانة',
                    'department': 'قسم أجهزة الكمبيوتر',
                    'phone': '0598765432',
                    'email': 'fatma@company.com',
                    'status': 'نشط',
                  },
                  {
                    'name': 'محمد إبراهيم حسن',
                    'position': 'فني شبكات',
                    'department': 'قسم الشبكات',
                    'phone': '0597654321',
                    'email': 'mohammed@company.com',
                    'status': 'إجازة',
                  },
                  {
                    'name': 'سارة أحمد علي',
                    'position': 'مساعد إداري',
                    'department': 'قسم الصيانة العامة',
                    'phone': '0596543210',
                    'email': 'sara@company.com',
                    'status': 'نشط',
                  },
                ];

                final employee = employees[index % employees.length];

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // صورة الموظف
                        CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            _getInitials(employee['name']!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // اسم الموظف
                        Text(
                          employee['name']!,
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 4),

                        // المنصب
                        Text(
                          employee['position']!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // القسم
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            employee['department']!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // الحالة
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              employee['status']!,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            employee['status']!,
                            style: TextStyle(
                              color: _getStatusColor(employee['status']!),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const Spacer(),

                        // أزرار الإجراءات
                        Row(
                          children: [
                            Expanded(
                              child: IconButton(
                                onPressed:
                                    () =>
                                        _showEmployeeDetails(context, employee),
                                icon: const Icon(Icons.visibility, size: 18),
                                tooltip: 'عرض التفاصيل',
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                onPressed:
                                    () => _showEditEmployeeDialog(
                                      context,
                                      employee,
                                    ),
                                icon: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.blue[600],
                                ),
                                tooltip: 'تعديل',
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                onPressed:
                                    () => _showDeleteEmployeeDialog(
                                      context,
                                      employee['name']!,
                                    ),
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                tooltip: 'حذف',
                              ),
                            ),
                          ],
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
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name.isNotEmpty ? name[0] : '';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'نشط':
        return Colors.green;
      case 'إجازة':
        return Colors.orange;
      case 'غير نشط':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddEmployeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إضافة موظف جديد'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'الاسم الأول',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'الاسم الأخير',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'رقم الهاتف',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'القسم',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _departmentOptions
                                  .skip(1)
                                  .map(
                                    (dept) => DropdownMenuItem(
                                      value: dept,
                                      child: Text(dept),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'المنصب',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة الموظف بنجاح')),
                  );
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
    );
  }

  void _showEmployeeDetails(
    BuildContext context,
    Map<String, String> employee,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('تفاصيل الموظف'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('الاسم:', employee['name']!),
                  _buildDetailRow('المنصب:', employee['position']!),
                  _buildDetailRow('القسم:', employee['department']!),
                  _buildDetailRow('الهاتف:', employee['phone']!),
                  _buildDetailRow('البريد:', employee['email']!),
                  _buildDetailRow('الحالة:', employee['status']!),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(
    BuildContext context,
    Map<String, String> employee,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تعديل بيانات الموظف'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'اسم الموظف',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: employee['name']),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'المنصب',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: employee['position'],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'الحالة',
                      border: OutlineInputBorder(),
                    ),
                    value: employee['status'],
                    items:
                        ['نشط', 'إجازة', 'غير نشط']
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديث بيانات الموظف بنجاح'),
                    ),
                  );
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
    );
  }

  void _showDeleteEmployeeDialog(BuildContext context, String employeeName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف الموظف'),
            content: Text('هل أنت متأكد من حذف الموظف "$employeeName"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف الموظف بنجاح')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }
}
