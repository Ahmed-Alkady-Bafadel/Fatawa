import 'package:fatawa/core/network/dio_helper.dart';
import 'package:fatawa/data/datasources/fatwa_local_data_source.dart';
import 'package:fatawa/data/datasources/fatwa_remote_data_source.dart';
import 'package:fatawa/data/models/fatwa_model.dart';
import 'package:fatawa/data/repositories/fatwa_repository.dart';
import 'package:fatawa/core/theme/app_colors.dart';
import 'package:fatawa/presentation/cubit/fatwa_cubit.dart';
import 'package:fatawa/presentation/cubit/fatwa_loading_cubit.dart';
import 'package:fatawa/presentation/cubit/theme_cubit.dart';
import 'package:fatawa/presentation/pages/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  // التأكد من تهيئة بيئة فلاتر قبل تشغيل أي شيء غير متزامن (async)
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة قواعد البيانات المحلية (Hive)
  await Hive.initFlutter();
  Hive.registerAdapter(FatwaModelAdapter());
  await Hive.openBox<FatwaModel>('fatwas_box');
  
  // تهيئة الاتصال بالشبكة
  DioHelper.init();

  // 💡 إنشاء طبقات البيانات (Data Layers) مرة واحدة فقط في بداية التطبيق
  final localDataSource = FatwaLocalDataSource();
  final remoteDataSource = FatwaRemoteDataSource(dio: DioHelper.dio);
  final repository = FatwaRepository(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final FatwaRepository repository;
  
  const MyApp({super.key, required this.repository});
  
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // 💡 التعديل الأهم: استخدمنا النسخة الممررة من main بدلاً من إنشاء نسخة جديدة
        RepositoryProvider<FatwaRepository>.value(
          value: repository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<FatwaLoadingCubit>(
            create: (context) => FatwaLoadingCubit(repository: repository),
          ),
          BlocProvider<FatwaCubit>(
            create: (context) =>
                FatwaCubit(repository: repository)..loadFatwas(),
          ),
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'الفتاوى',
              themeMode: themeMode,
              // 1. تفعيل اتجاه اليمين لليسار (RTL) افتراضياً في كل التطبيق
              builder: (context, child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                );
              },
              // 2. تطبيق الثوابت والوضع الفاتح
              theme: ThemeData(
                textTheme: const TextTheme(
                  titleLarge: TextStyle(color: AppColors.textPrimary),
                  titleMedium: TextStyle(color: AppColors.textSecondary),
                  titleSmall: TextStyle(color: AppColors.textHint),
                ),
                fontFamily: 'IBMPlexSansArabic',
                scaffoldBackgroundColor: AppColors.backgroundLight,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primaryGreen,
                ),
              ),
              // 3. مجهز للوضع الليلي مستقبلاً
              darkTheme: ThemeData(
                fontFamily: 'IBMPlexSansArabic',
                scaffoldBackgroundColor: AppColors.backgroundDark,
                cardColor: AppColors.cardColorDark,
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primaryGreen,
                  secondary: AppColors.primaryGreen,
                  surface: AppColors.cardColorDark,
                ),
                iconTheme: const IconThemeData(color: Colors.white70),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.white),
                  bodyMedium: TextStyle(color: Colors.white70),
                ),
              ),
              home: const LoadingPage(),
            );
          },
        ),
      ),
    );
  }
}
