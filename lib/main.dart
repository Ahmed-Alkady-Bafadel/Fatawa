import 'package:fatawa/models/fatwa_model.dart';
import 'package:fatawa/presentation/pages/auth/Login_page.dart';
import 'package:fatawa/core/theme/app_colors.dart';
import 'package:fatawa/presentation/pages/auth/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FatwaModelAdapter());
  await Hive.openBox<FatwaModel>('fatwas_box');
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
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      // 2. تطبيق الثوابت والوضع الفاتح
      theme: ThemeData(
        fontFamily: 'IBMPlexSansArabic',
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
      ),
      // مجهز للوضع الليلي مستقبلاً
      darkTheme: ThemeData(
        fontFamily: 'IBMPlexSansArabic',
        scaffoldBackgroundColor: AppColors.backgroundDark,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.light, // يمكنك تغييره لاحقاً إلى ThemeMode.system
      home: const LoadingPage(),
    );
  }
}
