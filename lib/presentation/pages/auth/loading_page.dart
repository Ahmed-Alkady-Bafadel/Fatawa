import 'dart:async';
import 'package:fatawa/presentation/pages/auth/Login_page.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();

    // 💡 المحرك السحري: مؤقت زمني لمدة ثانية واحدة (1 Second) ثم الانتقال فوراً
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 💡 نستخدم MediaQuery هنا "فقط" لتحديد حجم قطر الشعار ليناسب الشاشات
    final screenWidth = MediaQuery.of(context).size.width;
    final logoContainerSize =
        screenWidth * 0.40; // الشعار يأخذ 40% من عرض الشاشة
    const double paddingValuev = 0.8;
    final logoSize = logoContainerSize - (paddingValuev * 2);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 1. القسم الأوسط: الشعار والنص (مضمون التوسط الأفقي والعمودي 100%)
            Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // يأخذ أقل مساحة عمودية ليتم سنترته بدقة
                children: [
                  // الخلفية الدائرية للشعار (الحجم ديناميكي، الحشوة والظل ثابتان للأداء)
                  Container(
                    width: logoContainerSize,
                    height: logoContainerSize,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    padding: const EdgeInsets.all(paddingValuev), // حشوة ثابتة وكفوءة
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo-dome.png',
                        height: logoSize,
                        width: logoSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // مسافة ثابتة بـ const لأعلى أداء
                  // نص العنوان
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'دائرة الفتاوى الشرعية\nوالبحوث',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22, // حجم خط ثابت ومثالي للقراءة
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: AppColors
                            .primaryGreen, // ثابت كالهوية أو ترفق بـ Theme
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. القسم السفلي: دائرة التحميل والنص (مثبتة في الأسفل تماماً على بعد ثابت)
            Positioned(
              bottom: 40, // مسافة ثابتة ومريحة من أسفل الشاشة
              left: 0,
              right: 0,
              child: Column(
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
                      color: isDark
                          ? Colors.grey[400]
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
