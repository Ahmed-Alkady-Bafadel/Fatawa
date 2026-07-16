import '../../data/models/fatwa_model.dart';

abstract class FatwaState {}

class FatwaInitial extends FatwaState {}

class FatwaLoading extends FatwaState {}

class FatwaLoaded extends FatwaState {
  final List<FatwaModel> fatwas;

  FatwaLoaded(this.fatwas);
}

// لم نضف حالة Error لأن الـ Repository الخاص بنا مصمم ليعالج الأخطاء بصمت
// ويرجع دائماً الفتاوى المتوفرة محلياً (Offline First).
