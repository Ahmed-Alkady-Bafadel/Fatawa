import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../models/fatwa_model.dart';

class FatwaRemoteDataSource {
  final Dio dio;

  FatwaRemoteDataSource({required this.dio});

  Future<List<FatwaModel>> fetchNewFatwas() async {
    try {
      final response = await dio.get(ApiConstants.getPendingFatwas); 
      
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((json) => FatwaModel.fromJson(json))
            .toList();
      } else {
        throw Exception('فشل جلب الفتاوى');
      }
    } catch (e) {
      rethrow; 
    }
  }

  Future<bool> uploadAnsweredFatwa(FatwaModel fatwa) async {
    try {
      // 1. تجهيز البيانات الأساسية (بما فيها الإجابة النصية إن وجدت)
      Map<String, dynamic> mapData = {
        'fatwa_identifier': fatwa.pdfUrl,
      };

      if (fatwa.textAnswer != null && fatwa.textAnswer!.isNotEmpty) {
        mapData['text_answer'] = fatwa.textAnswer;
      }

      FormData formData = FormData.fromMap(mapData);

      // 2. إذا كانت الإجابة بملف PDF معدل
      if (fatwa.localPdfPath != null && fatwa.localPdfPath!.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'answered_pdf', 
            await MultipartFile.fromFile(
              fatwa.localPdfPath!, 
              filename: 'fatwa_answer.pdf',
            ),
          ),
        );
      }

      // 3. إذا كانت الإجابة بتسجيل صوتي
      if (fatwa.localAudioPath != null && fatwa.localAudioPath!.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'answered_audio', 
            await MultipartFile.fromFile(
              fatwa.localAudioPath!, 
              filename: 'fatwa_audio_answer.m4a', // صيغة الصوت المعتادة
            ),
          ),
        );
      }

      // 4. إرسال الطلب للسيرفر
      final response = await dio.post(ApiConstants.answerFatwa, data: formData); 
      return response.statusCode == 200 || response.statusCode == 201;
      
    } catch (e) {
      throw Exception('فشل رفع الفتوى');
    }
  }
}
