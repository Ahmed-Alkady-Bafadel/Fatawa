class FatwaModel {
  final String title;
  final String questionSnippet;
  final String date;
  final String? pdfUrl; // رابط ملف الـ PDF (قد يكون null)
  final bool isAnswered; // حالة الفتوى: هل تمت الإجابة عليها أم لا؟

  const FatwaModel({
    required this.title,
    required this.questionSnippet,
    required this.date,
    required this.pdfUrl,
    this.isAnswered = false,
  });
}
