import 'dart:io' show Platform;
import 'package:fatawa/presentation/pages/loading_page.dart';
import 'package:fatawa/widgets/custom_text_field.dart';
import 'package:fatawa/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(24),

                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
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
                              // الشعار
                              Center(
                                child: Image.asset(
                                  height: size.height * 0.12,
                                  'assets/images/logo-dome.png',
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface, // متجاوب مع الليل والنهار
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'أدخل بيانات الاعتماد للمتابعة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // الحقول
                              CustomTextField(
                                label: 'اسم المستخدم',
                                hint: 'أدخل اسم المستخدم',
                                filled: true,
                                controller: _usernameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty)
                                    return 'هذا الحقل مطلوب';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: 'كلمة المرور',
                                hint: 'أدخل كلمة المرور',
                                isPassword: _isPasswordObscured,
                                filled: true,
                                controller: _passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'كلمة المرور مطلوبة';
                                  return null;
                                },
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

                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'نسيت كلمة المرور؟',
                                    style: TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // زر الدخول
                              PrimaryButton(
                                text: 'دخول',
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoadingPage(),
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 24),

                              // الفاصل
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: isDark
                                          ? Colors.grey[800]
                                          : AppColors.inputBorder,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'أو',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[400]
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: isDark
                                          ? Colors.grey[800]
                                          : AppColors.inputBorder,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // زر تسجيل الدخول بواسطة جوجل
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.grey[700]!
                                        : AppColors.inputBorder,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isDark
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.g_mobiledata,
                                      size: 36,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'المتابعة باستخدام Google',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // الانتقال لإنشاء حساب
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ليس لديك حساب؟ ',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SignUpPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'سجل الآن',
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
