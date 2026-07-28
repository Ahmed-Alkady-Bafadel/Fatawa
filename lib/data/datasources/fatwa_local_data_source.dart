import 'package:hive_flutter/hive_flutter.dart';
import '../models/fatwa_model.dart';

class FatwaLocalDataSource {
  final String boxName = 'fatwas_box';

  Box<FatwaModel> get _box => Hive.box<FatwaModel>(boxName);

  List<FatwaModel> getUnansweredFatwas() {
    return _box.values.where((fatwa) => fatwa.isAnswered == false).toList();
  }

  List<FatwaModel> getPendingFatwasToSync() {
    return _box.values.where((fatwa) => fatwa.isAnswered == true).toList();
  }

List<FatwaModel> getAllFatwas() {
    return _box.values.toList();
  }

  Future<void> saveFatwas(List<FatwaModel> fatwas) async {
    final Map<dynamic, FatwaModel> fatwasMap = {
      for (var f in fatwas) f.pdfUrl: f 
    };
    await _box.putAll(fatwasMap);
  }

  Future<void> updateFatwa(FatwaModel fatwa) async {
    await _box.put(fatwa.pdfUrl, fatwa);
  }

  Future<void> deleteFatwa(String pdfUrl) async {
    await _box.delete(pdfUrl);
  }
}
