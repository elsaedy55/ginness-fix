import 'package:flutter/material.dart';
import '../theme/guinness_theme.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: GuinnessTheme.pureWhite,
        boxShadow: [
          BoxShadow(
            color: GuinnessTheme.textDark.withOpacity(0.03),
            offset: const Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: GuinnessTheme.textDark.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // شعار Guinness Fix مع التدرج الجديد
          Container(
            height: 120,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: GuinnessTheme.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: GuinnessTheme.pureWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: GuinnessTheme.pureWhite.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: GuinnessTheme.pureWhite,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Guinness Fix',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: GuinnessTheme.pureWhite,
                        ),
                      ),
                      Text(
                        'إدارة الأجهزة الذكية',
                        style: TextStyle(
                          fontSize: 12,
                          color: GuinnessTheme.pureWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ), // قائمة عناصر الشريط الجانبي العصرية
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildSidebarItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    title: 'لوحة التحكم',
                    index: 0,
                  ),
                  const SizedBox(height: 8),
                  _buildSidebarItem(
                    context,
                    icon: Icons.devices_rounded,
                    title: 'إدارة الأجهزة',
                    index: 1,
                  ),
                  const SizedBox(height: 8),
                  _buildSidebarItem(
                    context,
                    icon: Icons.business_rounded,
                    title: 'إدارة الأقسام',
                    index: 2,
                  ),
                  const SizedBox(height: 8),
                  _buildSidebarItem(
                    context,
                    icon: Icons.people_rounded,
                    title: 'إدارة الموظفين',
                    index: 3,
                  ),
                  const SizedBox(height: 8),
                  _buildSidebarItem(
                    context,
                    icon: Icons.analytics_rounded,
                    title: 'التقارير',
                    index: 4,
                  ),
                  const SizedBox(height: 8),
                  _buildSidebarItem(
                    context,
                    icon: Icons.settings_rounded,
                    title: 'الإعدادات',
                    index: 5,
                  ),
                ],
              ),
            ),
          ),

          // معلومات المستخدم مع الثيم الجديد
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: GuinnessTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: GuinnessTheme.pureWhite,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أحمد محمد',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: GuinnessTheme.textDark,
                        ),
                      ),
                      Text(
                        'مدير النظام',
                        style: TextStyle(
                          fontSize: 12,
                          color: GuinnessTheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return Container(
      decoration: BoxDecoration(
        gradient:
            isSelected
                ? LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    GuinnessTheme.primaryPurple.withOpacity(0.15),
                    GuinnessTheme.secondaryBlue.withOpacity(0.1),
                  ],
                )
                : null,
        borderRadius: BorderRadius.circular(16),
        border:
            isSelected
                ? Border.all(
                  color: GuinnessTheme.primaryPurple.withOpacity(0.3),
                  width: 1,
                )
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onItemSelected(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? GuinnessTheme.primaryPurple.withOpacity(0.2)
                            : GuinnessTheme.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color:
                        isSelected
                            ? GuinnessTheme.primaryPurple
                            : GuinnessTheme.textMedium,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color:
                          isSelected
                              ? GuinnessTheme.primaryPurple
                              : GuinnessTheme.textMedium,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          GuinnessTheme.primaryPurple,
                          GuinnessTheme.secondaryBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
