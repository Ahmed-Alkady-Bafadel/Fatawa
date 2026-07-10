
import 'package:hive/hive.dart';

part 'fatwa_model.g.dart';
@HiveType(typeId: 0)
class FatwaModel extends HiveObject{
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String questionSnippet;
  @HiveField(2)
  final String date;
  @HiveField(3)
  final String pdfUrl; 
  @HiveField(4)
  final bool isAnswered; // حالة الفتوى: هل تمت الإجابة عليها أم لا؟

   FatwaModel({
    required this.title,
    required this.questionSnippet,
    required this.date,
    required this.pdfUrl,
    this.isAnswered = false,
  });
}
