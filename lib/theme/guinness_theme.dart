import 'package:flutter/material.dart';

/// ثيم مستوحى من لوجو Guinness Fix
/// ألوان نظيفة مع تدرجات بنفسجية - زرقاء - سماوية
class GuinnessTheme {
  // الألوان الأساسية مستوحاة من اللوجو
  static const Color primaryPurple = Color(0xFF6366F1); // البنفسجي الأساسي
  static const Color secondaryBlue = Color(0xFF3B82F6); // الأزرق المتوسط
  static const Color accentCyan = Color(0xFF06B6D4); // السماوي الفاتح
  static const Color lightPurple = Color(0xFF8B5CF6); // البنفسجي الفاتح

  // ألوان محايدة نظيفة
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFFAFAFA);
  static const Color lightGrey = Color(0xFFF4F4F5);
  static const Color borderGrey = Color(0xFFE4E4E7);
  static const Color textDark = Color(0xFF18181B);
  static const Color textMedium = Color(0xFF52525B);
  static const Color textLight = Color(0xFF71717A);

  // تدرجات لوجو Guinness Fix
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightPurple, primaryPurple, secondaryBlue, accentCyan],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFF), Color(0xFFF1F5FF)],
  );

  /// إنشاء ثيم التطبيق الرئيسي
  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Segoe UI',

      // نظام الألوان
      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        secondary: secondaryBlue,
        tertiary: accentCyan,
        surface: pureWhite,
        background: backgroundGrey,
        onPrimary: pureWhite,
        onSecondary: pureWhite,
        onSurface: textDark,
        onBackground: textDark,
      ),

      // خلفية التطبيق
      scaffoldBackgroundColor: backgroundGrey,

      // ثيم البطاقات
      cardTheme: CardTheme(
        color: pureWhite,
        elevation: 0,
        shadowColor: textDark.withOpacity(0.03),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderGrey, width: 0.5),
        ),
      ),

      // ثيم الأزرار المرفوعة
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: pureWhite,
          elevation: 0,
          shadowColor: primaryPurple.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      // ثيم الأزرار المحيطة
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          side: const BorderSide(color: primaryPurple, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ثيم الأزرار النصية
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // ثيم حقول النص
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: textLight),
        labelStyle: TextStyle(color: textMedium),
      ),

      // ثيم AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: pureWhite,
        foregroundColor: textDark,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ثيم النصوص
      textTheme: const TextTheme(
        // عناوين كبيرة
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
          height: 1.3,
        ),

        // عناوين متوسطة
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textDark,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
          height: 1.4,
        ),

        // عناوين صغيرة
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
          height: 1.5,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textMedium,
          height: 1.5,
        ),

        // نص عادي
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textMedium,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textLight,
          height: 1.5,
        ),

        // تسميات
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textMedium,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textLight,
          height: 1.4,
        ),
      ),

      // ثيم الأيقونات
      iconTheme: const IconThemeData(color: textMedium, size: 24),

      // ثيم Divider
      dividerTheme: const DividerThemeData(
        color: borderGrey,
        thickness: 0.5,
        space: 1,
      ),

      // ثيم ListTile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  /// ألوان حالة مفيدة
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);

  /// تدرجات ألوان الحالة
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  /// الظلال المخصصة
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: textDark.withOpacity(0.03),
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: textDark.withOpacity(0.02),
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: primaryPurple.withOpacity(0.15),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
}
