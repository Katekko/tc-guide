import '../entities/feedback_request.dart';

/// Delivers visitor feedback to the maintainer.
abstract class FeedbackRepository {
  /// Sends [request]. Completes normally on success and throws a
  /// [FeedbackException] on any delivery failure.
  Future<void> send(FeedbackRequest request);
}

/// Raised when a feedback submission could not be delivered.
class FeedbackException implements Exception {
  /// Creates a feedback exception with a human-readable [message].
  const FeedbackException(this.message);

  /// Description of what went wrong.
  final String message;

  @override
  String toString() => 'FeedbackException: $message';
}
