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
            title: 'العمل في البنوك واستلام الفوائد  ',
            questionSnippet:
                'ما هو حكم العمل في البنوك؟ وهل الفوائد التي تعود علينا من إيداع الأموال في البنوك  حرام أو حلال؟ ',
            pdfUrl: 'assets/files/العمل في البنوك واستلام الفوائد _020955.pdf',
            localPdfPath: '',
          ),
          FatwaModel(
            title: 'القدوة في المسجد المتعدد الطوابق',
            questionSnippet:
                'عندنا  بعض  المساجد  تتكون  من  طابقين  أو  ثلاثة،  وللوصول  للطابق  الثاني  أو  الثالث  يتم  استخدام سلالم داخلية بها انعطاف وازورار، فهل تصح قدوة من في الطابق الثاني أو الثالث  بالإمام الذي في الطابق الأول؟',
            pdfUrl: 'assets/files/القدوة في المسجد المتعدد الطوابق.pdf',
            localPdfPath: '',
          ),
          FatwaModel(
            title: 'الوفاء بالوعد والأخذ بحق الظفر',
            questionSnippet:
                'رجل سافر إلى بلد لأجل العمل، واتفق مع الكفيل في العقد أن يتحمل عنه كلفة الإقامة،  ولكن الكفيل قام بخصم المبلغ من الراتب ، وقال: هذا نظامي، فهل يجوز ذلك للكفيل، علما  أن مع الرجل مبالغ تابعة للعمل، فهل يجوز له أخذ حقه؛ لأنه في حاجة للمال؟  ',
            pdfUrl: 'assets/files/الوفاء بالوعد والأخذ بحق الظفر.pdf',
            localPdfPath: '',
          ),
          FatwaModel(
            title: 'بيع جزء من الأرض ',
            questionSnippet:
                'باع رجل سدسا في قطعة أرض له محددة بحدود معروفة، فهل يصح البيع؟ وما الذي يترتب  عليه؟ ',
            pdfUrl: 'assets/files/بيع جزء من الأرض.pdf',
            localPdfPath: '',
          ),
          FatwaModel(
            title: 'دفع الزكاة لوالد الزوجة ',
            questionSnippet:
                'أريد أن أدفع جزءا من زكاة مالي إلى والد زوجتي؛ حيث إنه بحاجة ماسة إلى إجراء عملية  جراحية عاجلة، ولا يملك ما يغطي تكاليف العلاج والعملية، علما أن زوجتي لا تملك إلا  ذهبا فقط، ولديها ابن وبنت يعملان في الخارج وسيكملون المبلغ.  السؤال: هل يجوز لي شرعا أن أدفع من زكاة مالي لوالد زوجتي مع وجود ذهب زوجتي  وأولادها الذين يعملون؟',
            pdfUrl: 'assets/files/دفع الزكاة لوالد الزوجة.pdf',
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
