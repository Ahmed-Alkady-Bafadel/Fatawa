
import 'dart:io' show Platform;
import 'package:fatawa/widgets/custom_text_field.dart';
import 'package:fatawa/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordObscured = true; // للتحكم في إخفاء/إظهار كلمة المرور
  bool _isTermsAccepted = false;   // للتحكم في حالة مربع الموافقة

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: Platform.isIOS
                ? const BouncingScrollPhysics()
                : const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                // يمكن إزالة الظل أو إبقاؤه حسب تفضيلك، هنا أبقيناه خفيفاً كالشاشة الأولى
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. أيقونة الإضافة العلوية الخضراء
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1, // أيقونة مشابهة جداً للتصميم
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. النصوص الترحيبية
                  const Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'أدخل بياناتك للتسجيل',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. حقول الإدخال (مع تفعيل اللون الرمادي الفاتح)
                  CustomTextField(
                    label: 'الاسم الكامل',
                    hint: 'أدخل اسمك الكامل',
                    filled: true,
                    fillColor: AppColors.inputFillLight,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'البريد الإلكتروني',
                    hint: 'أدخل بريدك الإلكتروني',
                    keyboardType: TextInputType.emailAddress,
                    filled: true,
                    fillColor: AppColors.inputFillLight,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'اسم المستخدم',
                    hint: 'أدخل اسم المستخدم',
                    filled: true,
                    fillColor: AppColors.inputFillLight,
                  ),
                  const SizedBox(height: 16),

                  // حقل كلمة المرور مع أيقونة العين
                  CustomTextField(
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    isPassword: _isPasswordObscured,
                    filled: true,
                    fillColor: AppColors.inputFillLight,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. الشروط والأحكام (Checkbox)
                  Row(
                    children: [
                      Checkbox(
                        value: _isTermsAccepted,
                        activeColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _isTermsAccepted = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        'أوافق على ',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      GestureDetector(
                        onTap: () {
                          // فتح صفحة الشروط والأحكام مستقبلاً
                        },
                        child: const Text(
                          'الشروط والأحكام',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 5. زر التسجيل
                  PrimaryButton(
                    text: 'تسجيل حساب',
                    onPressed: () {
                      if (_isTermsAccepted) {
                        // تنفيذ كود التسجيل
                      } else {
                        // إظهار رسالة تفيد بضرورة الموافقة على الشروط
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // 6. العودة لشاشة تسجيل الدخول
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'لديك حساب بالفعل؟ ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () {
                          // العودة للشاشة السابقة (تسجيل الدخول)
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
