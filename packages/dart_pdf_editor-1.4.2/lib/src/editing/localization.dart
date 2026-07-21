import 'dart:ui';

abstract class PdfEditorStrings {
  const PdfEditorStrings();

  String get select;
  String get content;
  String get form;
  String get redact;
  String get snapshot;
  String get tools;
  String get draw;
  String get markup;
  String get bookmarks;
  String get searchResults;
  String get save;
  String get pages;
  String get properties;
  String get settings;
  String get cancel;
  String get apply;
  String get ok;
  String get undo;
  String get redo;
  String get font;
  String get style;
  String get alignLeft;
  String get alignCenter;
  String get alignRight;
  String get color;
  String get signature;
  String get multiline;
  String get autoSize;
  String get lineType;
  String get lineStart;
  String get lineEnd;
  String get editTextStyle;
  String get moreColors;
  String get loadFont;
  String get edit;
  String get textBox;
  String get textField;
  String get measure;
  String get squiggly;
  String get selectTextToUseMarkup;
  String get highlight;
  String get underline;
  String get strikeOut;
  String get eraseInk;
  String get shapes;
  String get rectangle;
  String get ellipse;
  String get line;
  String get arrow;
  String get polyline;
  String get polygon;
  String get cloudPolygon;
  String get insert;
  String get callout;
  String get note;
  String get count;
  String get image;
  String get stamp;

  static const english = _EnglishPdfEditorStrings();
  static const arabic = _ArabicPdfEditorStrings();
}

class _EnglishPdfEditorStrings extends PdfEditorStrings {
  const _EnglishPdfEditorStrings();

  @override
  String get select => 'Select';
  @override
  String get content => 'Content';
  @override
  String get form => 'Form';
  @override
  String get redact => 'Redact';
  @override
  String get snapshot => 'Snapshot';
  @override
  String get tools => 'Tools';
  @override
  String get draw => 'Draw';
  @override
  String get bookmarks => 'Bookmarks';
  @override
  String get searchResults => 'Search results';
  @override
  String get save => 'Save';
  @override
  String get pages => 'Pages';
  @override
  String get properties => 'Properties';
  @override
  String get settings => 'Settings';
  @override
  String get cancel => 'Cancel';
  @override
  String get apply => 'Apply';
  @override
  String get ok => 'OK';
  @override
  String get undo => 'Undo';
  @override
  String get redo => 'Redo';
  @override
  String get font => 'Font';
  @override
  String get style => 'Style';
  @override
  String get alignLeft => 'Align left';
  @override
  String get alignCenter => 'Align center';
  @override
  String get alignRight => 'Align right';
  @override
  String get color => 'Color';
  @override
  String get signature => 'Signature';
  @override
  String get multiline => 'Multiline';
  @override
  String get autoSize => 'Auto-size';
  @override
  String get lineType => 'Line type';
  @override
  String get lineStart => 'Line start';
  @override
  String get lineEnd => 'Line end';
  @override
  String get editTextStyle => 'Edit text & style';
  @override
  String get moreColors => 'More colors…';
  @override
  String get loadFont => 'Load font…';
  @override
  String get edit => 'Edit';
  @override
  String get textBox => 'Text box';
  @override
  String get textField => 'Text field';
  @override
  String get measure => 'Measure';
  @override
  String get selectTextToUseMarkup => 'Select text to use markup';
  @override
  String get markup => 'Markup';
  @override
  String get highlight => 'highlight';
  @override
  String get underline => 'underline';
  @override
  String get strikeOut => 'strikeOut';
  @override
  String get squiggly => 'squiggly';
  @override
  String get eraseInk => 'Erase ink strokes';
  @override
  String get shapes => 'Shapes';
  @override
  String get rectangle => 'Rectangle';
  @override
  String get ellipse => 'Ellipse';
  @override
  String get arrow => 'Arrow';
  @override
  String get line => 'Line';
  @override
  String get polyline => 'Polyline';
  @override
  String get cloudPolygon => 'Cloud polygon';
  @override
  String get polygon => 'polygon';
  @override
  String get callout => 'Callout';
  @override
  String get count => 'Count';
  @override
  String get image => 'Image';
  @override
  String get insert => 'Insert';
  @override
  String get note => 'Note';

  @override
  // TODO: implement stamp
  String get stamp => 'Stamp';
}

class _ArabicPdfEditorStrings extends PdfEditorStrings {
  const _ArabicPdfEditorStrings();

  @override
  String get select => 'تحديد';
  @override
  String get content => 'المحتوى';
  @override
  String get form => 'النماذج';
  @override
  String get redact => 'إخفاء';
  @override
  String get snapshot => 'لقطة';
  @override
  String get tools => 'الأدوات';
  @override
  String get draw => 'رسم';
  @override
  String get bookmarks => 'الإشارات المرجعية';
  @override
  String get searchResults => 'نتائج البحث';
  @override
  String get save => 'حفظ';
  @override
  String get pages => 'الصفحات';
  @override
  String get properties => 'الخصائص';
  @override
  String get settings => 'الإعدادات';
  @override
  String get cancel => 'إلغاء';
  @override
  String get apply => 'تطبيق';
  @override
  String get ok => 'موافق';
  @override
  String get undo => 'تراجع';
  @override
  String get redo => 'إعادة';
  @override
  String get font => 'الخط';
  @override
  String get style => 'النمط';
  @override
  String get alignLeft => 'محاذاة لليسار';
  @override
  String get alignCenter => 'توسيط';
  @override
  String get alignRight => 'محاذاة لليمين';
  @override
  String get color => 'لون';
  @override
  String get signature => 'التوقيع';
  @override
  String get multiline => 'متعدد الأسطر';
  @override
  String get autoSize => 'حجم تلقائي';
  @override
  String get lineType => 'نوع الخط';
  @override
  String get lineStart => 'بداية الخط';
  @override
  String get lineEnd => 'نهاية الخط';
  @override
  String get editTextStyle => 'تحرير النص والنمط';
  @override
  String get moreColors => 'ألوان أخرى…';
  @override
  String get loadFont => 'تحميل خط…';
  @override
  String get edit => 'تحرير';
  @override
  String get textBox => 'مربع نص';
  @override
  String get textField => 'حقل نص';
  @override
  String get measure => 'قياس';
  @override
  String get selectTextToUseMarkup => 'حدد النص لاستخدام أدوات التمييز';
  @override
  String get markup => 'تعليقات';
  @override
  String get highlight => 'تمييز النص';
  @override
  String get underline => 'خط سفلي';
  @override
  String get strikeOut => 'شطب النص';
  @override
  String get squiggly => 'خطين تحت النص';
  @override
  String get eraseInk => 'ممحاة';
  @override
  String get shapes => 'الأشكال';
  @override
  String get rectangle => 'مستطيل';
  @override
  String get ellipse => 'دائرة';
  @override
  String get arrow => 'سهم';
  @override
  String get line => 'خط';
  @override
  String get polyline => 'متعدد خطوط';
  @override
  String get cloudPolygon => 'مضلع سحابي';
  @override
  String get polygon => 'مضلع';
  @override
  String get callout => 'وسيلة شرح';
  @override
  String get count => 'عداد';
  @override
  String get image => 'صورة';
  @override
  String get insert => 'إدراج';
  @override
  String get note => 'ملاحظة';
  @override
  String get stamp => 'ختم';
}

final PdfEditorStrings pdfStrings =
    PlatformDispatcher.instance.locale.languageCode == 'ar'
        ? PdfEditorStrings.arabic
        : PdfEditorStrings.english;

String tr(String en, String ar) {
  return PlatformDispatcher.instance.locale.languageCode == 'ar' ? ar : en;
}
