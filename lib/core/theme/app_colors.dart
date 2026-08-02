import 'package:flutter/material.dart';

class AppColors {
  // 1. اللون الأساسي (الهوية)
  static const Color primaryGreen = Color(0xFF0F7A41);
  
  // 2. ألوان الخلفيات (Backgrounds)
  static const Color backgroundLight = Color(0xFFF7F9F8);
  static const Color backgroundDark = Color(0xFF121212); 
  
  // 3. ألوان الأسطح والبطاقات (Surfaces & Cards)
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // 4. ألوان النصوص - الوضع الفاتح
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textHintLight = Color(0xFFBDBDBD);

  // 5. ألوان النصوص - الوضع الداكن
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color textHintDark = Color(0xFF6E6E6E);

  // 6. ألوان الحقول والحدود (Inputs & Borders)
  static const Color inputFillLight = Color(0xFFF5F5F5);
  static const Color borderLight = Color(0xFFE0E0E0);
  
  static const Color inputFillDark = Color(0xFF2C2C2C);
  static const Color borderDark = Color(0xFF383838);

  // 7. ألوان الحالات (للفتاوى المجاب عليها وقيد الانتظار والأخطاء)
  static const Color success = Color(0xFF388E3C); // لون أخضر مناسب للردود
  static const Color warning = Color(0xFFF57C00); // لون برتقالي للانتظار
  static const Color error = Color(0xFFD32F2F);   // لون أحمر للأخطاء
}
