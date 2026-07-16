import 'dart:ui';

bool get isArabic => PlatformDispatcher.instance.locale.languageCode == 'ar';
  String tr(String en, String ar) {
     

    return isArabic ? ar : en;
  }