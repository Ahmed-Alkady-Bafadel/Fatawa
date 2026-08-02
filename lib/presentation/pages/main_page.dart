import 'package:fatawa/presentation/cubit/fatwa_cubit.dart';
import 'package:fatawa/presentation/cubit/fatwa_state.dart';
import 'package:fatawa/presentation/cubit/theme_cubit.dart';
import 'package:fatawa/widgets/empty_fatwa_state.dart';
import 'package:fatawa/widgets/fatwa_card.dart';
import 'package:fatawa/widgets/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
// لا تنسَ استيراد الملفات الجديدة هنا (MainAppBar و EmptyFatwaState)

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark =
        (themeMode == ThemeMode.dark) ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        // استدعاء الدالة العامة هنا أيضاً
        if (await showAppExitDialog(context, isDark)) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF9FDF9),
        // هنا السحر! AppBar أصبح const بالكامل ولن يُبنى إلا إذا تغير الثيم
        appBar: const MainAppBar(),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: () async =>
                  await context.read<FatwaCubit>().loadFatwas(),
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
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return GridView.builder(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 400,
                                  mainAxisExtent: 110,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: state.fatwas.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: FatwaCardWidget(
                                    fatwa: state.fatwas[index],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
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
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                              height: 1,
                              thickness: 1,
                            ),
                            itemBuilder: (context, index) =>
                                FatwaCardWidget(fatwa: state.fatwas[index]),
                          );
                        }
                      },
                    );
                  }

                  // استدعاء المكون الجديد بـ const لمنع أي Rebuild غير ضروري!
                  return const EmptyFatwaState();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> showAppExitDialog(BuildContext context, bool isDark) async {
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
