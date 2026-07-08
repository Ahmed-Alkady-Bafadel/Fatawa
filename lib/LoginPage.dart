import 'dart:io' show Platform;
import 'package:fatawa/widgets/custom_text_field.dart';
import 'package:fatawa/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // نستخدم MediaQuery لمعرفة أبعاد الشاشة لجعل التصميم متجاوباً
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8), // لون الخلفية الرمادي الفاتح
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // تخصيص حركة التمرير بناءً على نظام التشغيل كما طلبت
            physics: Platform.isIOS
                ? const BouncingScrollPhysics()
                : const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. صورة الشعار
                Image.asset(
                  'assets/image/logo-dome.png', // تأكد من مسار الصورة في مشروعك
                  height: size.height * 0.12, // يأخذ 12% من ارتفاع الشاشة
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),

                // 2. النصوص الترحيبية
                const Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    // fontFamily: 'MaterialIcons',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'أدخل بيانات الاعتماد للمتابعة',
                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 32),

                // 3. البطاقة البيضاء التي تحتوي على الفورم
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // حقل اسم المستخدم
                      const CustomTextField(
                        label: 'اسم المستخدم',
                        hint: 'اسم المستخدم',
                      ),
                      const SizedBox(height: 20),

                      // حقل كلمة المرور
                      const CustomTextField(
                        label: 'كلمة المرور',
                        hint: 'كلمة المرور',
                        isPassword: true,
                      ),
                      const SizedBox(height: 32),

                      // زر تسجيل الدخول
                      PrimaryButton(
                        text: 'دخول',
                        onPressed: () {
                          // سيتم ربط الـ Cubit والـ API هنا لاحقاً
                        },
                      ),
                      const SizedBox(height: 24),

                      // الفاصل الخطّي (أو)
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: Color(0xFFE0E0E0)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'أو',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: Color(0xFFE0E0E0)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // زر تسجيل الدخول بجوجل
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          // icon: Image.asset(
                          //   'assets/images/google_icon.png', // تأكد من إضافة أيقونة جوجل لمجلد الأصول
                          //   height: 24,
                          // ),
                          icon: Icon(Icons.g_mobiledata, size: 24),
                          label: const Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. نص التسجيل أسفل البطاقة
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // الانتقال لشاشة إنشاء الحساب
                      },
                      child: const Text(
                        'سجل الآن ',
                        style: TextStyle(
                          color: Color(0xFF0F7A41),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text(
                      'ليس لديك حساب؟ ',
                      style: TextStyle(color: Color(0xFF757575)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
