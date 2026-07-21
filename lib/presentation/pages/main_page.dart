import 'package:fatawa/data/models/fatwa_model.dart';
import 'package:fatawa/presentation/cubit/fatwa_cubit.dart';
import 'package:fatawa/presentation/cubit/fatwa_state.dart';
import 'package:fatawa/presentation/cubit/theme_cubit.dart';
import 'package:fatawa/widgets/fatwa_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_colors.dart';

class MainPage extends StatelessWidget {
   MainPage({super.key});


        
    
  
  @override
  Widget build(BuildContext context) {
    // نستخدم الـ ThemeMode الحالي لتحديد الألوان
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark =
        (themeMode == ThemeMode.dark) ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        if (await _showExitDialog(context, isDark)) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF9FDF9),
        appBar: _buildAppBar(context, isDark),
        body: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () async => await context.read<FatwaCubit>().loadFatwas(),
          child: BlocBuilder<FatwaCubit, FatwaState>(
            builder: (context, state) {
              if (state is FatwaLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                );
              }
              if (state is FatwaLoaded && state.fatwas.isNotEmpty) {
                return ListView.separated(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  itemCount: state.fatwas.length,
             
                  separatorBuilder: (context, index) => Divider(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    height: 1,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) =>
                      FatwaCardWidget(fatwa: state.fatwas[index]),
                );
              }
              return _buildEmptyState(isDark);
            },
          ),
        ),
      ),
    );
  }

  // --- دوال البناء المنفصلة (لضمان الأداء) ---

  AppBar _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF9FDF9),
      elevation: 0,
      title: Image.asset(
        'assets/images/logo-calligraphy.png',
        height: 40,
        fit: BoxFit.contain,
      ),


      actions: [
        
         // زر تبديل الثيم (القائمة المنبثقة)
        Builder(
          builder: (context) {
            // جلب حالة الثيم الحالية من الـ Cubit بناءً على طريقتك
            final currentMode = context.watch<ThemeCubit>().state;

            return PopupMenuButton<ThemeMode>(
              // عند اختيار المستخدم لأحد العناصر
              onSelected: (ThemeMode selectedMode) {
                // ملاحظة: ستحتاج لاستدعاء دالة لتحديد الثيم بدلاً من toggleTheme
                // تأكد من وجود دالة مثل changeTheme أو setTheme في الـ Cubit
                context.read<ThemeCubit>().toggleTheme(selectedMode);
              },
              // تصميم الزر الذي يظهر في شريط التطبيق
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getThemeIcon(currentMode), color: AppColors.primaryGreen),
                    const SizedBox(width: 6),
                    Text(
                      _getThemeText(currentMode),
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
                  ],
                ),
              ),
              // بناء عناصر القائمة الثلاثة
              itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
                PopupMenuItem<ThemeMode>(
                  value: ThemeMode.light,
                  child: Row(
                    children: [
                      Icon(_getThemeIcon(ThemeMode.light), size: 20),
                      const SizedBox(width: 12),
                      Text(_getThemeText(ThemeMode.light)),
                    ],
                  ),
                ),
                PopupMenuItem<ThemeMode>(
                  value: ThemeMode.dark,
                  child: Row(
                    children: [
                      Icon(_getThemeIcon(ThemeMode.dark), size: 20),
                      const SizedBox(width: 12),
                      Text(_getThemeText(ThemeMode.dark)),
                    ],
                  ),
                ),
                PopupMenuItem<ThemeMode>(
                  value: ThemeMode.system,
                  child: Row(
                    children: [
                      Icon(_getThemeIcon(ThemeMode.system), size: 20),
                      const SizedBox(width: 12),
                      Text(_getThemeText(ThemeMode.system)),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
        // زر الخروج
        IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
          onPressed: () async {
            if (await _showExitDialog(context, isDark)) {
              SystemNavigator.pop();
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.done_all_rounded,
                size: 80,
                color: isDark ? Colors.grey[700] : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد فتاوى معلقة حالياً\nجزاك الله خيراً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- دوال مساعدة ---

  Future<bool> _showExitDialog(BuildContext context, bool isDark) async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('الخروج من التطبيق'),
          ],
        ),
        content: const Text('هل أنت متأكد أنك تريد الخروج من التطبيق نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'نعم، متأكد',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'وضع النظام';
    }
  }

  IconData _getThemeIcon(ThemeMode mode) {
    if (mode == ThemeMode.light) return Icons.light_mode;
    if (mode == ThemeMode.dark) return Icons.dark_mode;
    return Icons.brightness_auto; // وضع النظام
  }
}
