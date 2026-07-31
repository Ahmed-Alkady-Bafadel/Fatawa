import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatawa/presentation/cubit/theme_cubit.dart';

class EmptyFatwaState extends StatelessWidget {
  const EmptyFatwaState({super.key}); // const هنا يمنع إعادة البناء نهائياً

  @override
  Widget build(BuildContext context) {
    // حساب الثيم داخلياً
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = (themeMode == ThemeMode.dark) ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    // حساب الأبعاد داخلياً
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final double emptyIconSize = (shortestSide * 0.20).clamp(60.0, 90.0);

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
                size: emptyIconSize,
                color: isDark ? Colors.grey[700] : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد فتاوى معلقة حالياًً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (shortestSide * 0.045).clamp(15.0, 19.0),
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
