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
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isTermsAccepted = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: Platform.isIOS
                  ? const BouncingScrollPhysics()
                  : const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).cardColor, // متجاوب مع المظهر
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // الأيقونة العلوية للخلفية الخضراء
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_add_alt_1,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'إنشاء حساب جديد',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'أدخل بياناتك للتسجيل',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // الحقول الأربعة مجهزة بالكامل بالتحقق والحفظ اللحظي
                              CustomTextFieldOptimized(
                                label: 'الاسم الكامل',
                                hint: 'أدخل اسمك الكامل',
                                filled: true,
                                controller: _fullNameController,
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'الاسم الكامل مطلوب'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              CustomTextFieldOptimized(
                                label: 'البريد الإلكتروني',
                                hint: 'أدخل بريدك الإلكتروني',
                                keyboardType: TextInputType.emailAddress,
                                filled: true,
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'البريد الإلكتروني مطلوب';
                                  }
                                  // التعبير النمطي للتحقق من صياغة الإيميل الإلزامية
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'الرجاء إدخال بريد إلكتروني صحيح ومكتمل';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              CustomTextFieldOptimized(
                                label: 'اسم المستخدم',
                                hint: 'أدخل اسم المستخدم',
                                filled: true,
                                controller: _usernameController,

                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'اسم المستخدم مطلوب'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              CustomTextFieldOptimized(
                                label: 'كلمة المرور',
                                hint: 'أدخل كلمة المرور',
                                isPassword: _isPasswordObscured,
                                filled: true,
                                controller: _passwordController,
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                    ? 'كلمة المرور مطلوبة'
                                    : null,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordObscured
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordObscured =
                                          !_isPasswordObscured;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),

                              // الشروط والأحكام
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
                                  Text(
                                    'أوافق على ',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
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

                              // تم إكمال بناء كائن الزر المغلق والمبتور سابقاً بشكل مثالي
                              PrimaryButton(
                                text: 'تسجيل حساب',
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    if (!_isTermsAccepted) {
                                      // تنبيه عائم في حال نسي قبول الشروط والأحكام
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'الرجاء الموافقة على الشروط والأحكام للمتابعة',
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }
                                    print(
                                      "كل البيانات سليمة وجاهزة للإرسال للـ API!",
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 24),

                              // العودة لتسجيل الدخول
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'لديك حساب بالفعل؟ ',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
