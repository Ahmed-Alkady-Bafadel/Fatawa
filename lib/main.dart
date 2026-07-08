import 'package:fatawa/presentation/pages/auth/LoginPage.dart';
import 'package:fatawa/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'الفتاوى',
      // 1. تفعيل اتجاه اليمين لليسار (RTL) افتراضياً في كل التطبيق
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      // 2. تطبيق الثوابت والوضع الفاتح
      theme: ThemeData(
        fontFamily: 'IBMPlexSansArabic',
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
      ),
      // مجهز للوضع الليلي مستقبلاً
      darkTheme: ThemeData(
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: AppColors.backgroundDark,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.light, // يمكنك تغييره لاحقاً إلى ThemeMode.system
      home: const LoginPage(),
    );

  }
}
