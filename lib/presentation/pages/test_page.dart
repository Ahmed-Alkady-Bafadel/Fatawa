import 'dart:io';
import 'package:fatawa/presentation/pages/fatwa_pdf_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/fatwa_model.dart'; // مسار المودل الخاص بك

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _isLoading = false;

  // دالة تحاكي الـ API وتقوم بتجهيز الملف المحلي
  Future<void> _loadMockDataAndNavigate() async {
    setState(() => _isLoading = true);

    try {
      // 1. محاكاة انتظار الإنترنت
      await Future.delayed(const Duration(seconds: 1));

      // 2. نسخ ملف الـ PDF من مجلد الأصول إلى ذاكرة الهاتف الداخلية
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/test_fatwa.pdf');
      if(!await file.exists())
      {
      final byteData = await rootBundle.load('assets/files/1-8.pdf');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        }
        
      // 3. إنشاء مودل وهمي يحتوي على المسار الحقيقي
      final mockFatwa = FatwaModel(
        title: ' أحكام المعاملات',
        questionSnippet: 'هذا نص مبدئي تم جلبه من الـ API الوهمي...',
        localPdfPath: file.path,  pdfUrl: 'assets/files/1-8.pdf', // هنا مربط الفرس!
      );

      // 4. الانتقال للشاشة
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FatwaPdfScreen(fatwa: mockFatwa),
          ),
        );
      }
    } catch (e) {
      debugPrint('حدث خطأ في تجهيز الملف: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شاشة الاختبار')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _loadMockDataAndNavigate,
                child: const Text('اختبار شاشة الـ PDF'),
              ),
      ),
    );
  }
}
