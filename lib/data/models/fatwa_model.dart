import 'package:hive/hive.dart';

part 'fatwa_model.g.dart';

@HiveType(typeId: 0)
class FatwaModel extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String questionSnippet;
  @HiveField(2)
  final String pdfUrl; // المعرف الأساسي
  @HiveField(3)
   bool isAnswered;
  @HiveField(4)
   String? localPdfPath; // إجابة عبر ملف PDF معدل
  @HiveField(5)
  final String date;
  @HiveField(6)
  String? localAudioPath; // إجابة عبر تسجيل صوتي
  @HiveField(7)
  String? textAnswer; // إجابة نصية

  FatwaModel({
    required this.title,
    required this.questionSnippet,
    required this.pdfUrl,
    this.isAnswered = false,
    this.localPdfPath,
    this.localAudioPath,
    this.textAnswer,
    String? date,
  }) : date =
           date ??
           '${DateTime.now().month}/${DateTime.now().day}'; // تم تحسين شكل التاريخ

  FatwaModel copyWith({
    String? title,
    String? questionSnippet,
    String? pdfUrl,
    bool? isAnswered,
    String? localPdfPath,
    String? localAudioPath,
    String? textAnswer,
    String? date,
  }) {
    return FatwaModel(
      title: title ?? this.title,
      questionSnippet: questionSnippet ?? this.questionSnippet,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      isAnswered: isAnswered ?? this.isAnswered,
      localPdfPath: localPdfPath ?? this.localPdfPath,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      textAnswer: textAnswer ?? this.textAnswer,
      date: date ?? this.date,
    );
  }

  factory FatwaModel.fromJson(Map<String, dynamic> json) {
    return FatwaModel(
      title: json['title'] ?? 'بدون عنوان',
      questionSnippet: json['questionSnippet'] ?? 'لا يوجد نص للسؤال',
      pdfUrl: json['pdfUrl'] ?? '',
      isAnswered: json['isAnswered'] ?? false,
    );
  }

  // 💡 إضافة جديدة: مفيدة جداً لاحقاً عند التعامل مع API معقد
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'questionSnippet': questionSnippet,
      'pdfUrl': pdfUrl,
      'isAnswered': isAnswered,
      'date': date,
    };
  }
}
