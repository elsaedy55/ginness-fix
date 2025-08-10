import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../widgets/dashboard_overview.dart';
import '../widgets/devices_management.dart';
import '../widgets/departments_management.dart';
import '../widgets/employees_management.dart';
import '../widgets/reports_screen.dart';
import '../widgets/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // قائمة الشاشات
  final List<Widget> _screens = [
    const DashboardOverview(),
    const DevicesManagement(),
    const DepartmentsManagement(),
    const EmployeesManagement(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  // قائمة عناوين الشاشات
  final List<String> _screenTitles = [
    'لوحة التحكم',
    'إدارة الأجهزة',
    'إدارة الأقسام',
    'إدارة الموظفين',
    'التقارير',
    'الإعدادات',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Row(
          children: [
            // الشريط الجانبي
            Sidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),

            // المحتوى الرئيسي
            Expanded(
              child: Column(
                children: [
                  // الشريط العلوي
                  TopBar(title: _screenTitles[_selectedIndex]),

                  // محتوى الشاشة
                  Expanded(child: _screens[_selectedIndex]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
