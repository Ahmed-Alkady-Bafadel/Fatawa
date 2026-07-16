import 'package:fatawa/presentation/cubit/fatwa_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/fatwa_model.dart';
import '../../data/repositories/fatwa_repository.dart';


class FatwaCubit extends Cubit<FatwaState> {
  final FatwaRepository repository;

  FatwaCubit({required this.repository}) : super(FatwaInitial());

  /// استدعاء الفتاوى (تتضمن المزامنة الصامتة تلقائياً)
  Future<void> loadFatwas() async {
    emit(FatwaLoading()); // إظهار مؤشر التحميل
    
    // الـ Repo سيقوم برفع المعلق، جلب الجديد، ثم إرجاع الفتاوى التي تنتظر إجابة فقط
    final fatwas = await repository.syncAndFetchFatwas();
    
    emit(FatwaLoaded(fatwas)); // عرض الفتاوى في الشاشة
  }

  /// إرسال الإجابة (سواء نص، صوت، أو PDF)
  Future<void> submitAnswer(FatwaModel answeredFatwa) async {
    // حفظ الإجابة محلياً وبدء الرفع في الخلفية
    await repository.submitFatwaAnswerLocally(answeredFatwa);
    
    // إعادة تحميل القائمة لتختفي الفتوى المجاب عليها من الشاشة
    loadFatwas(); 
  }
}
