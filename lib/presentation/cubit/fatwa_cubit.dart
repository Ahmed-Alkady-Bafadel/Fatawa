import 'dart:io';

import 'package:fatawa/presentation/cubit/fatwa_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/fatwa_model.dart';
import '../../data/repositories/fatwa_repository.dart';

class FatwaCubit extends Cubit<FatwaState> {
  final FatwaRepository repository;

  FatwaCubit({required this.repository}) : super(FatwaInitial());

  List<FatwaModel> _cachedFatwas = [];

  /// استدعاء الفتاوى (تتضمن المزامنة الصامتة تلقائياً)
  Future<void> loadFatwas() async {
    emit(FatwaLoading()); // إظهار مؤشر التحميل

    if (_cachedFatwas.isNotEmpty) {
      emit(FatwaLoaded(_cachedFatwas));
      return;
    }
    // الـ Repo سيقوم برفع المعلق، جلب الجديد، ثم إرجاع الفتاوى التي تنتظر إجابة فقط
    // final fatwas = await repository.syncAndFetchFatwas();
    await Future.delayed(const Duration(seconds: 1));

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/test_fatwa.pdf');
    if (!await file.exists()) {
      final byteData = await rootBundle.load('assets/files/1-8.pdf');
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }

    _cachedFatwas = [
      // 3. إنشاء مودل وهمي يحتوي على المسار الحقيقي
      FatwaModel(
        title: ' أحكام المعاملات',
        questionSnippet: 'هذا نص مبدئي تم جلبه من الـ API الوهمي...',
        localPdfPath: file.path,
        pdfUrl: 'assets/files/1-8.pdf', // هنا مربط الفرس!
      ),
      FatwaModel(
        title: ' أحكام المعاملات',
        questionSnippet: 'هذا نص مبدئي تم جلبه من الـ API الوهمي...',
        localPdfPath: file.path,
        pdfUrl: 'assets/files/1-8.pdf', // هنا مربط الفرس!
      ),
      FatwaModel(
        title: ' أحكام المعاملات',
        questionSnippet: 'هذا نص مبدئي تم جلبه من الـ API الوهمي...',
        localPdfPath: file.path,
        pdfUrl: 'assets/files/1-8.pdf', // هنا مربط الفرس!
      ),
      FatwaModel(
        title: ' أحكام المعاملات',
        questionSnippet: 'هذا نص مبدئي تم جلبه من الـ API الوهمي...',
        localPdfPath: file.path,
        pdfUrl: 'assets/files/1-8.pdf', // هنا مربط الفرس!
      ),
      FatwaModel(
        title: ' أحكام المعاملات',
        questionSnippet: 'هذا نص مبدئي تم جلبه من الـ API الوهمي...',
        localPdfPath: file.path,
        pdfUrl: 'assets/files/1-8.pdf', // هنا مربط الفرس!
      ),
    ];
    emit(FatwaLoaded(_cachedFatwas)); // عرض الفتاوى في الشاشة
  }

  /// إرسال الإجابة (سواء نص، صوت، أو PDF)
  Future<void> submitAnswer(FatwaModel answeredFatwa) async {
    // حفظ الإجابة محلياً وبدء الرفع في الخلفية
    await repository.submitFatwaAnswerLocally(answeredFatwa);

    // إعادة تحميل القائمة لتختفي الفتوى المجاب عليها من الشاشة
    loadFatwas();
  }

  void updateFatawa(FatwaModel updateFatwa) {
    final index = _cachedFatwas.indexWhere(
      (f) => f.pdfUrl == updateFatwa.pdfUrl,
    );
    if (index != -1) {
      _cachedFatwas[index] = updateFatwa;
      emit(FatwaLoaded(List.from(_cachedFatwas)));
    }
  }
}
