import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fatawa/data/models/fatwa_model.dart';
import 'package:fatawa/data/repositories/fatwa_repository.dart';

part 'fatwa_loading_state.dart';

class FatwaLoadingCubit extends Cubit<FatwaLoadingState> {
  final FatwaRepository repository;

  FatwaLoadingCubit({required this.repository}) : super(FatwaLoadingInitial());

  Future<void>  submitFatwa({
    required FatwaModel originalFatwa,
    String? textAnswer,
    String? audioPath,
    Uint8List? editedPdfBytes,
  }) async {
    try {
      final finalLocalPdfPath = await _savePdfBytesToFile(originalFatwa, editedPdfBytes);

      final answeredFatwa = originalFatwa.copyWith(
        textAnswer: textAnswer,
        localAudioPath: audioPath,
        localPdfPath: finalLocalPdfPath,
        isAnswered: true, 
      );

      await repository.submitFatwaAnswerLocally(answeredFatwa);
      
      emit(FatwaLoadingActionSuccess());
    } catch (e) {
      emit(FatwaLoadingActionError('فشل حفظ وإرسال الفتوى: $e'));
    }
  }

  Future<void> saveDraft({
    required FatwaModel originalFatwa,
    String? textAnswer,
    String? audioPath,
    Uint8List? editedPdfBytes,
  }) async {
    try {
      final finalLocalPdfPath = await _savePdfBytesToFile(originalFatwa, editedPdfBytes);

      final draftFatwa = originalFatwa.copyWith(
        textAnswer: textAnswer,
        localAudioPath: audioPath,
        localPdfPath: finalLocalPdfPath,
        isAnswered: false, 
      );

      await repository.saveFatwaDraft(draftFatwa);
      emit(FatwaLoadingActionSuccess());
    } catch (e) {
      emit(FatwaLoadingActionError('فشل حفظ المسودة: $e'));
    }
  }

  Future<String?> _savePdfBytesToFile(FatwaModel originalFatwa, Uint8List? bytes) async {
    if (bytes == null) return originalFatwa.localPdfPath;

    if (originalFatwa.localPdfPath != null && originalFatwa.localPdfPath!.isNotEmpty) {
      final file = File(originalFatwa.localPdfPath!);
      await file.writeAsBytes(bytes);
      return originalFatwa.localPdfPath;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'fatwa_answered_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    }
  }
}
