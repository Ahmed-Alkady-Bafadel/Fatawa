import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatawa/presentation/cubit/fatwa_state.dart';
import '../../data/repositories/fatwa_repository.dart';

class FatwaCubit extends Cubit<FatwaState> {
  final FatwaRepository repository;

  FatwaCubit({required this.repository}) : super(FatwaInitial());

  /// استدعاء الفتاوى (تتضمن المزامنة التلقائية مع التحقق من الإنترنت)
  Future<void> loadFatwas() async {
    emit(FatwaLoading());

    try {
      final fatwas = await repository.syncAndFetchFatwas();

      emit(FatwaLoaded(fatwas));
    } catch (e) {

    }
  }

}
