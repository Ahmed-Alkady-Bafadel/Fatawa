import 'package:fatawa/data/datasources/fatwa_local_data_source.dart';
import 'package:fatawa/data/datasources/fatwa_remote_data_source.dart';

import '../models/fatwa_model.dart';

class FatwaRepository {
  final FatwaLocalDataSource localDataSource;
  final FatwaRemoteDataSource remoteDataSource;

  FatwaRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  /// 1. مزامنة الفتاوى: رفع المعلق أولاً ثم جلب الجديد بصمت
  Future<List<FatwaModel>> syncAndFetchFatwas() async {
    final pendingFatwas = localDataSource.getPendingFatwasToSync();

    for (var fatwa in pendingFatwas) {
      try {
        final uploadSuccess = await remoteDataSource.uploadAnsweredFatwa(fatwa);
        if (uploadSuccess) {
          await localDataSource.deleteFatwa(fatwa.pdfUrl);
        }
      } catch (e) {
        continue;
      }
    }

    try {
      final newFatwas = await remoteDataSource.fetchNewFatwas();
      await localDataSource.saveFatwas(newFatwas);
    } catch (e) {
      // صمت
    }

    return localDataSource.getUnansweredFatwas();
  }

  /// 2. حفظ الإجابة (سواء كانت نص، صوت، أو PDF)
  /// الـ Cubit سيقوم بتجهيز الـ FatwaModel المليء بالإجابة ويمرره هنا
  Future<void> submitFatwaAnswerLocally(FatwaModel answeredFatwa) async {
    // نتأكد فقط أن حالة الفتوى أصبحت "مجاب عليها" للضمان
    final fatwaToSave = answeredFatwa.copyWith(isAnswered: true);

    // حفظ في الذاكرة المحلية
    await localDataSource.updateFatwa(fatwaToSave);

    // محاولة الرفع فوراً في الخلفية
    syncAndFetchFatwas();
  }

  Future<void> saveFatwaDraft(FatwaModel draftFatwa) async {
    await localDataSource.updateFatwa(draftFatwa);
  }
}
