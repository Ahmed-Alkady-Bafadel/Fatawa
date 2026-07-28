import 'package:dio/dio.dart';
import 'package:fatawa/core/network/api_constants.dart';
import '../models/fatwa_model.dart';

class FatwaRemoteDataSource {
  final Dio dio;
  final bool _useDummyData = true; // اجعله false عند ربط الـ API الحقيقي

  FatwaRemoteDataSource({required this.dio});

  Future<List<FatwaModel>> fetchNewFatwas() async {
    try {
      if (_useDummyData) {
        await Future.delayed(const Duration(seconds: 2));
        return [
          FatwaModel(
            title: 'حكم الصلاة في الطائرة',
            questionSnippet: 'هل يجوز لي أن أصلي الفريضة وأنا جالس بالطائرة؟',
            pdfUrl: 'assets/files/1-8.pdf',
            localPdfPath: '',
          ),
          FatwaModel(
            title: 'زكاة التجارة الإلكترونية',
            questionSnippet:
                'لدى متجر إلكتروني، كيف أحسب زكاة البضائع الموجودة في المستودع؟',
            pdfUrl: 'assets/files/المدود.pdf',
            localPdfPath: '',
          ),
        ];
      }

      final response = await dio.get(ApiConstants.getPendingFatwas);
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((json) => FatwaModel.fromJson(json))
            .toList();
      } else {
        throw Exception('فشل جلب الفتاوى من السيرفر');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> uploadAnsweredFatwa(FatwaModel fatwa) async {
    try {
      if (_useDummyData) {
        await Future.delayed(const Duration(seconds: 2));
        return true;
      }

      Map<String, dynamic> mapData = {'fatwa_identifier': fatwa.pdfUrl};

      if (fatwa.textAnswer != null && fatwa.textAnswer!.isNotEmpty) {
        mapData['text_answer'] = fatwa.textAnswer;
      }

      FormData formData = FormData.fromMap(mapData);

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

      if (fatwa.localAudioPath != null && fatwa.localAudioPath!.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'answered_audio',
            await MultipartFile.fromFile(
              fatwa.localAudioPath!,
              filename: 'fatwa_audio_answer.m4a',
            ),
          ),
        );
      }

      final response = await dio.post(ApiConstants.answerFatwa, data: formData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('فشل رفع الفتوى للسيرفر');
    }
  }
}
