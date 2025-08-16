import 'package:flutter/material.dart';

class DepartmentsManagement extends StatefulWidget {
  const DepartmentsManagement({super.key});

  @override
  State<DepartmentsManagement> createState() => _DepartmentsManagementState();
}

class _DepartmentsManagementState extends State<DepartmentsManagement> {
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
                      hintText: 'البحث في الأقسام...',
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
              ElevatedButton.icon(
                onPressed: () => _showAddDepartmentDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('إضافة قسم'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // بطاقات الأقسام
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final departments = [
                  {
                    'name': 'قسم الهواتف المحمولة',
                    'manager': 'احمد الشريف',
                    'employees': '8',
                    'devices': '45',
                    'color': Colors.blue,
                  },
                  {
                    'name': 'قسم أجهزة الكمبيوتر',
                    'manager': 'محمد علي',
                    'employees': '6',
                    'devices': '32',
                    'color': Colors.green,
                  },
                  {
                    'name': 'قسم الأجهزة اللوحية',
                    'manager': 'فاطمة أحمد',
                    'employees': '4',
                    'devices': '18',
                    'color': Colors.orange,
                  },
                  {
                    'name': 'قسم الشبكات',
                    'manager': 'عبد الله حسن',
                    'employees': '5',
                    'devices': '25',
                    'color': Colors.purple,
                  },
                  {
                    'name': 'قسم الصيانة العامة',
                    'manager': 'سارة محمود',
                    'employees': '7',
                    'devices': '38',
                    'color': Colors.red,
                  },
                  {
                    'name': 'قسم قطع الغيار',
                    'manager': 'إبراهيم علي',
                    'employees': '3',
                    'devices': '0',
                    'color': Colors.teal,
                  },
                ];

                final department = departments[index];

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (department['color'] as Color)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.business,
                                color: department['color'] as Color,
                                size: 20,
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditDepartmentDialog(
                                    context,
                                    department,
                                  );
                                } else if (value == 'delete') {
                                  _showDeleteDepartmentDialog(
                                    context,
                                    department['name'] as String,
                                  );
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('تعديل'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('حذف'),
                                    ),
                                  ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          department['name'] as String,
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'المدير: ${department['manager']}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  department['employees'] as String,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'موظف',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  department['devices'] as String,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'جهاز',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
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

  void _showAddDepartmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إضافة قسم جديد'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'اسم القسم',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'اسم المدير',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'الوصف',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                    const SnackBar(content: Text('تم إضافة القسم بنجاح')),
                  );
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
    );
  }

  void _showEditDepartmentDialog(
    BuildContext context,
    Map<String, dynamic> department,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تعديل القسم'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'اسم القسم',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: department['name'] as String,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'اسم المدير',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: department['manager'] as String,
                    ),
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
                    const SnackBar(content: Text('تم تحديث القسم بنجاح')),
                  );
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDepartmentDialog(
    BuildContext context,
    String departmentName,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف القسم'),
            content: Text('هل أنت متأكد من حذف قسم "$departmentName"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف القسم بنجاح')),
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
