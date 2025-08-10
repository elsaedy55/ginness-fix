import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_config.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppConfig.createApp(
      title: 'Guinness Fix - لوحة التحكم',
      home: const DashboardScreen(),
    );
  }
}
