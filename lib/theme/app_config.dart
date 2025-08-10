import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'guinness_theme.dart';

/// إعدادات التطبيق العامة مع دعم RTL والخطوط العربية
class AppConfig {
  /// إعداد الـ locale للعربية
  static const Locale arabicLocale = Locale('ar', 'SA');

  /// قائمة الـ locales المدعومة
  static const List<Locale> supportedLocales = [
    arabicLocale,
    Locale('en', 'US'),
  ];

  /// اتجاه النص (RTL للعربية)
  static TextDirection getTextDirection() {
    return TextDirection.rtl;
  }

  /// إعداد MaterialApp كاملة مع كل الإعدادات
  static MaterialApp createApp({
    required Widget home,
    String title = 'Guinness Fix Dashboard',
  }) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,

      // إعداد الثيم
      theme: GuinnessTheme.getTheme(),

      // إعداد اللغة والاتجاه
      locale: arabicLocale,
      supportedLocales: supportedLocales,

      // إضافة localization delegates
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // إعداد الـ RTL
      builder: (context, child) {
        return Directionality(textDirection: getTextDirection(), child: child!);
      },

      home: home,
    );
  }
}

/// مساعدين للألوان والتدرجات
class GuinnessColors {
  /// الحصول على لون حسب الحالة
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'متاح':
      case 'active':
      case 'نشط':
        return GuinnessTheme.successGreen;
      case 'معطل':
      case 'inactive':
      case 'غير نشط':
        return GuinnessTheme.errorRed;
      case 'صيانة':
      case 'maintenance':
        return GuinnessTheme.warningOrange;
      default:
        return GuinnessTheme.textMedium;
    }
  }

  /// الحصول على تدرج حسب الأولوية
  static LinearGradient getPriorityGradient(String priority) {
    switch (priority.toLowerCase()) {
      case 'عالية':
      case 'high':
        return GuinnessTheme.errorGradient;
      case 'متوسطة':
      case 'medium':
        return GuinnessTheme.warningGradient;
      case 'منخفضة':
      case 'low':
        return GuinnessTheme.successGradient;
      default:
        return GuinnessTheme.primaryGradient;
    }
  }
}

/// مساعدين للنصوص
class GuinnessTextStyles {
  /// نمط النص للعناوين الرئيسية
  static const TextStyle pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: GuinnessTheme.textDark,
    height: 1.2,
  );

  /// نمط النص للعناوين الثانوية
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: GuinnessTheme.textDark,
    height: 1.3,
  );

  /// نمط النص للبطاقات
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: GuinnessTheme.textDark,
    height: 1.4,
  );

  /// نمط النص للقيم والأرقام
  static const TextStyle numberValue = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: GuinnessTheme.primaryPurple,
    height: 1.2,
  );

  /// نمط النص للتسميات
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: GuinnessTheme.textMedium,
    height: 1.4,
  );

  /// نمط النص للحالة
  static TextStyle status(Color color) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
  );
}

/// مساعدين للحواف والمسافات
class GuinnessSpacing {
  // مسافات أساسية
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // حواف أساسية
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  // مسافات للبطاقات
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardMargin = EdgeInsets.all(sm);

  // مسافات للحقول
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  static const EdgeInsets fieldMargin = EdgeInsets.only(bottom: md);
}
