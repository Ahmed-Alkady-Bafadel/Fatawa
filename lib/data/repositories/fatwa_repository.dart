import 'dart:io';
import '../datasources/fatwa_local_data_source.dart';
import '../datasources/fatwa_remote_data_source.dart';
import '../models/fatwa_model.dart';

class FatwaRepository {
  final FatwaLocalDataSource localDataSource;
  FatwaRemoteDataSource remoteDataSource;

  FatwaRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // المزامنة وجلب البيانات
  Future<List<FatwaModel>> syncAndFetchFatwas() async {
    // 1. التحقق من وجود اتصال بالإنترنت
    // final isConnected = await _hasInternetConnection();
    final isConnected = true;
    if (isConnected) {
      // ==========================================
      // المرحلة الأولى: المزامنة للأعلى (Sync UP)
      // ==========================================
      // جلب الفتاوى التي تم الإجابة عليها محلياً (ولم تُرفع بعد)
      final pendingFatwas = localDataSource.getPendingFatwasToSync();

      for (var fatwa in pendingFatwas) {
        try {
          // محاولة رفع الفتوى (النص، الصوت، والـ PDF المعدل) للدوكر/الـ API
          final uploadSuccess = await remoteDataSource.uploadAnsweredFatwa(
            fatwa,
          );

          if (uploadSuccess) {
            // إذا نجح الرفع، نحذفها من الذاكرة المحلية (Hive) لتنظيف المساحة
            await localDataSource.deleteFatwa(fatwa.pdfUrl);
          }
        } catch (e) {
          // إذا فشل رفع فتوى معينة (بسبب ضعف النت مثلاً)، نتجاوزها عبر continue
          // لتبقى في الذاكرة المحلية ونحاول رفعها في المرة القادمة
          continue;
        }
      }

      // ==========================================
      // المرحلة الثانية: المزامنة للأسفل (Sync DOWN)
      // ==========================================
      try {
        // جلب الفتاوى الجديدة من الـ API
        final newFatwas = await remoteDataSource.fetchNewFatwas();

        // إنشاء خريطة للبيانات المحلية الحالية للحفاظ على المسودات والتعديلات
        final oldMap = {
          for (final f in localDataSource.getAllFatwas()) f.pdfUrl: f,
        };

        for (final newFatwa in newFatwas) {
          final old = oldMap[newFatwa.pdfUrl];
          if (old != null) {
            newFatwa.textAnswer = old.textAnswer;
            newFatwa.localAudioPath = old.localAudioPath;
            newFatwa.localPdfPath = old.localPdfPath;
            newFatwa.isAnswered =
                old.isAnswered; // 💡 التعديل الذي أضفناه سابقاً
          }
        }

        // حفظ البيانات الجديدة بعد دمجها في Hive
        await localDataSource.saveFatwas(newFatwas);
      } catch (e) {
        // إذا فشل جلب البيانات الجديدة، نتجاهل الخطأ بصمت
        // لأن التطبيق سيكمل عمله ويعرض ما هو مخزن محلياً
      }
    }

    // 3. الخطوة النهائية: في كل الأحوال (بإنترنت أو بدون)
    // نعرض دائماً الفتاوى التي لم يُجاب عليها من الذاكرة المحلية فقط!
    return localDataSource.getUnansweredFatwas();
  }

  Future<List<FatwaModel>> submitFatwaAnswerLocally(
    FatwaModel answeredFatwa,
  ) async {
    final fatwaToSave = answeredFatwa.copyWith(isAnswered: true);
    await localDataSource.updateFatwa(fatwaToSave);
    return syncAndFetchFatwas();
  }

  Future<void> saveFatwaDraft(FatwaModel draftFatwa) async {
    await localDataSource.updateFatwa(draftFatwa);
  }
}
