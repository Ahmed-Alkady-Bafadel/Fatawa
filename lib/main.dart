import 'package:fatawa/core/network/dio_helper.dart';
import 'package:fatawa/data/datasources/fatwa_local_data_source.dart';
import 'package:fatawa/data/datasources/fatwa_remote_data_source.dart';
import 'package:fatawa/data/models/fatwa_model.dart';
import 'package:fatawa/data/repositories/fatwa_repository.dart';
import 'package:fatawa/core/theme/app_colors.dart'; // مسار الثوابت
import 'package:fatawa/presentation/cubit/fatwa_cubit.dart';
import 'package:fatawa/presentation/cubit/fatwa_loading_cubit.dart';
import 'package:fatawa/presentation/cubit/theme_cubit.dart';
import 'package:fatawa/presentation/pages/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Hive.initFlutter();
  Hive.registerAdapter(FatwaModelAdapter());
  await Hive.openBox<FatwaModel>('fatwas_box');

  DioHelper.init();

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
      providers: [RepositoryProvider<FatwaRepository>.value(value: repository)],
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
              builder: (context, child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                );
              },

              // ==========================================
              // 1. إعدادات الوضع الفاتح (Light Theme)
              // ==========================================
              theme: ThemeData(
                useMaterial3: true,
                fontFamily: 'IBMPlexSansArabic',
                scaffoldBackgroundColor: AppColors.backgroundLight,
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primaryGreen,
                  surface: AppColors.surfaceLight,
                  error: AppColors.error,
                  onSurface: AppColors.textPrimaryLight,
                  onSurfaceVariant: AppColors.textSecondaryLight,
                  outlineVariant: AppColors.borderLight,
                  surfaceContainerHighest: AppColors.inputFillLight,
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: AppColors.backgroundLight,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
                  titleTextStyle: TextStyle(
                    color: AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                ),
                cardTheme: CardThemeData(
                  color: AppColors.surfaceLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
                  bodyMedium: TextStyle(color: AppColors.textSecondaryLight),
                  labelLarge: TextStyle(color: AppColors.textHintLight),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: AppColors.inputFillLight,
                  hintStyle: const TextStyle(color: AppColors.textHintLight),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 2,
                    ),
                  ),
                ),
              ),

              // ==========================================
              // 2. إعدادات الوضع الداكن (Dark Theme)
              // ==========================================
              darkTheme: ThemeData(
                useMaterial3: true,
                fontFamily: 'IBMPlexSansArabic',
                scaffoldBackgroundColor: AppColors.backgroundDark,
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primaryGreen,
                  surface: AppColors.surfaceDark,
                  error: AppColors.error,
                  onSurface: AppColors.textPrimaryDark,
                  onSurfaceVariant: AppColors.textSecondaryDark,
                  outlineVariant: AppColors.borderDark,
                  surfaceContainerHighest: AppColors.inputFillDark,
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: AppColors.backgroundDark,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
                  titleTextStyle: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                ),
                cardTheme: CardThemeData(
                  color: AppColors.surfaceDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: AppColors.borderDark,
                      width: 1,
                    ),
                  ),
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
                  bodyMedium: TextStyle(color: AppColors.textSecondaryDark),
                  labelLarge: TextStyle(color: AppColors.textHintDark),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: AppColors.inputFillDark,
                  hintStyle: const TextStyle(color: AppColors.textHintDark),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 2,
                    ),
                  ),
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
