part of 'feedback_cubit.dart';

/// Lifecycle of a feedback submission.
enum FeedbackStatus {
  /// No submission in progress; the form is editable.
  initial,

  /// A submission is being delivered.
  submitting,

  /// The last submission succeeded.
  success,

  /// The last submission failed; see [FeedbackState.error].
  failure,
}

/// Immutable state for [FeedbackCubit].
class FeedbackState extends Equatable {
  /// Creates a feedback state (defaults to [FeedbackStatus.initial]).
  const FeedbackState({this.status = FeedbackStatus.initial, this.error});

  /// Current submission status.
  final FeedbackStatus status;

  /// Failure message when [status] is [FeedbackStatus.failure].
  final String? error;

  /// Whether a submission is currently in flight.
  bool get isSubmitting => status == FeedbackStatus.submitting;

  @override
  List<Object?> get props => [status, error];
}
