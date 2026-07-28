import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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

  // 💡 مهمتها الوحيدة: تجهيز ونسخ ملف الـ PDF التجريبي للذاكرة المحلية ليعمل التطبيق بدون أخطاء
  Future<void> _initDummyPdfIfNeeded() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/test_fatwa.pdf');

    if (!await file.exists()) {
      final byteData = await rootBundle.load('assets/files/1-8.pdf');
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
  }

  // المزامنة وجلب البيانات
  Future<List<FatwaModel>> syncAndFetchFatwas() async {
    await _initDummyPdfIfNeeded();

    final newFatwas = await remoteDataSource.fetchNewFatwas();

    final oldMap = {
      for (final fatwa in localDataSource.getAllFatwas()) fatwa.pdfUrl: fatwa,
    };

    for (final newFatwa in newFatwas) {
      final old = oldMap[newFatwa.pdfUrl];

      if (old != null) {
        newFatwa.textAnswer = old.textAnswer;
        newFatwa.localAudioPath = old.localAudioPath;
        newFatwa.localPdfPath = old.localPdfPath;
      }
    }

    await localDataSource.saveFatwas(newFatwas);

    // final isConnected = await _hasInternetConnection();

    // if (isConnected) {
    //   try {
    //     final pendingFatwas = localDataSource.getPendingFatwasToSync();
    //     for (var fatwa in pendingFatwas) {
    //       try {
    //         final uploadSuccess = await remoteDataSource.uploadAnsweredFatwa(
    //           fatwa,
    //         );
    //         if (uploadSuccess) {
    //           await localDataSource.deleteFatwa(fatwa.pdfUrl);
    //         }
    //       } catch (e) {
    //         continue;
    //       }
    //     }

    //   final newFatwas = await remoteDataSource.fetchNewFatwas();

    //   // ربط الـ PDF المحلي بالبيانات القادمة لضمان عمل شاشة العرض بسلاسة
    //   final dir = await getApplicationDocumentsDirectory();
    //   final localPath = '${dir.path}/test_fatwa.pdf';

    //   for (var fatwa in newFatwas) {
    //     // نضع المسار المحلي لكي تستطيع شاشة الـ PDF قراءته
    //     // (يمكنك تعديل هذا الشرط لاحقاً حسب تصميمك)
    //   }

    //   await localDataSource.saveFatwas(newFatwas);
    // } catch (e) {
    // صمت في حال فشل الجلب ليعتمد على التخزين المحلي
    //   }
    // }

    return localDataSource.getUnansweredFatwas();
  }

  Future<void> submitFatwaAnswerLocally(FatwaModel answeredFatwa) async {
    final fatwaToSave = answeredFatwa.copyWith(isAnswered: true);
    await localDataSource.updateFatwa(fatwaToSave);
    syncAndFetchFatwas();
  }

  Future<void> saveFatwaDraft(FatwaModel draftFatwa) async {
    await localDataSource.updateFatwa(draftFatwa);
  }
}
