import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/feedback_request.dart';
import '../../domain/repositories/feedback_repository.dart';

part 'feedback_state.dart';

/// Drives the feedback form: submits a [FeedbackRequest] through the
/// [FeedbackRepository] and exposes the submission lifecycle as
/// [FeedbackState].
class FeedbackCubit extends Cubit<FeedbackState> {
  /// Creates the cubit backed by [_repository].
  FeedbackCubit(this._repository) : super(const FeedbackState());

  final FeedbackRepository _repository;

  /// Delivers [request], emitting submitting → success/failure.
  Future<void> submit(FeedbackRequest request) async {
    emit(const FeedbackState(status: FeedbackStatus.submitting));
    try {
      await _repository.send(request);
      emit(const FeedbackState(status: FeedbackStatus.success));
    } on FeedbackException catch (error) {
      emit(FeedbackState(status: FeedbackStatus.failure, error: error.message));
    } on Exception catch (error) {
      emit(FeedbackState(status: FeedbackStatus.failure, error: '$error'));
    }
  }

  /// Returns the form to its editable initial state.
  void reset() => emit(const FeedbackState());
}
