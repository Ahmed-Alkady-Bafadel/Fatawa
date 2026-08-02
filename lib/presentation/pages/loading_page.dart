import 'dart:async';
import 'package:fatawa/presentation/pages/main_page.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        // LayoutBuilder تضمن التكيف الفوري حتى لو تغير حجم الشاشة وهي مفتوحة (مثل الأجهزة القابلة للطي)
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;
            final isLandscape = maxWidth > maxHeight;

            // حساب حجم الشعار بناءً على البعد الأصغر لتجنب التضخم في الشاشات العريضة والقابلة للطي
            final shortestDimension = maxWidth < maxHeight
                ? maxWidth
                : maxHeight;
            final logoContainerSize = (shortestDimension * 0.35).clamp(
              110.0,
              190.0,
            );
            const double paddingValuev = 8.0;
            final logoSize = logoContainerSize - (paddingValuev * 2);

            return Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: maxHeight - 40),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: isLandscape ? 16.0 : 32.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          // 1. الشعار الدائري
                          Container(
                            width: logoContainerSize,
                            height: logoContainerSize,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.06,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                            ),
                            padding: const EdgeInsets.all(paddingValuev),
                            child: Center(
                              child: Image.asset(
                                'assets/images/logo-dome.png',
                                height: logoSize,
                                width: logoSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          SizedBox(height: isLandscape ? 16 : 24),

                          // 2. النص
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'دائرة الفتاوى الشرعية\nوالبحوث',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),

                          const Spacer(),

                          SizedBox(height: isLandscape ? 16 : 32),

                          // 3. مؤشر التحميل
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGreen,
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'جاري التحميل...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
