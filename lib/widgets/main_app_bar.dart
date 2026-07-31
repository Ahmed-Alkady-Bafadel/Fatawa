import 'package:fatawa/presentation/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatawa/presentation/cubit/theme_cubit.dart';
import '../../core/theme/app_colors.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key}); // أصبح Const حقيقي الآن!

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = (themeMode == ThemeMode.dark) ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final double logoHeight = (shortestSide * 0.09).clamp(32.0, 44.0);
    final double actionIconSize = (shortestSide * 0.055).clamp(20.0, 26.0);

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9FDF9),
      elevation: 0,
      title: Image.asset(
        'assets/images/logo-calligraphy.png',
        height: logoHeight,
        fit: BoxFit.contain,
      ),
      actions: [
        _buildThemeMenu(context, actionIconSize, shortestSide),
        IconButton(
          icon: Icon(
            Icons.exit_to_app,
            color: Colors.redAccent,
            size: actionIconSize,
          ),
          onPressed: () async {
            // استدعاء الدالة العامة مباشرة
            if (await showAppExitDialog(context, isDark)) {
              SystemNavigator.pop();
            }
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildThemeMenu(BuildContext context, double actionIconSize, double shortestSide) {
    final currentMode = context.watch<ThemeCubit>().state;

    return PopupMenuButton<ThemeMode>(
      onSelected: (ThemeMode selectedMode) {
        context.read<ThemeCubit>().changeTheme(selectedMode);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getThemeIcon(currentMode),
              color: AppColors.primaryGreen,
              size: actionIconSize,
            ),
            const SizedBox(width: 4),
            Text(
              _getThemeText(currentMode),
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: (shortestSide * 0.035).clamp(13.0, 16.0),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.primaryGreen,
              size: actionIconSize,
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
        PopupMenuItem<ThemeMode>(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(_getThemeIcon(ThemeMode.light), size: actionIconSize * 0.9),
              const SizedBox(width: 12),
              Text(_getThemeText(ThemeMode.light)),
            ],
          ),
        ),
        PopupMenuItem<ThemeMode>(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(_getThemeIcon(ThemeMode.dark), size: actionIconSize * 0.9),
              const SizedBox(width: 12),
              Text(_getThemeText(ThemeMode.dark)),
            ],
          ),
        ),
        PopupMenuItem<ThemeMode>(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(_getThemeIcon(ThemeMode.system), size: actionIconSize * 0.9),
              const SizedBox(width: 12),
              Text(_getThemeText(ThemeMode.system)),
            ],
          ),
        ),
      ],
    );
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
    return Icons.brightness_auto;
  }
}
