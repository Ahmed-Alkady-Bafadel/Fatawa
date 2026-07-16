part of 'fatwa_loading_cubit.dart';

abstract class FatwaLoadingState {}

final class FatwaLoadingInitial extends FatwaLoadingState {}

class FatwaLoadingActionSuccess extends FatwaLoadingState {}

class FatwaLoadingActionError extends FatwaLoadingState {
  final String message;
  FatwaLoadingActionError(this.message);
}
