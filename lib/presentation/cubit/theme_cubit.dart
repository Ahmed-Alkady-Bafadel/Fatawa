import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  // القيمة الافتراضية هي الوضع الفاتح
  ThemeCubit() : super(ThemeMode.system);

  // دالة التبديل بين الوضعين
  void toggleTheme(ThemeMode themeMode) {
    emit(themeMode);
  }
}
