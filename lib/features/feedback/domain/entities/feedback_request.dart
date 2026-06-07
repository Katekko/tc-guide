import 'package:equatable/equatable.dart';

import 'feedback_category.dart';

/// A single piece of visitor feedback ready to be delivered.
///
/// [email] is optional — visitors may submit anonymously and only provide an
/// address when they want a reply. [pageRoute] and [locale] are attached
/// automatically so the maintainer knows exactly which guide (and language) the
/// message refers to.
class FeedbackRequest extends Equatable {
  /// Creates a feedback request.
  const FeedbackRequest({
    required this.title,
    required this.category,
    required this.body,
    this.email,
    this.pageRoute,
    this.locale,
  });

  /// Short headline summarizing the request.
  final String title;

  /// What kind of feedback this is.
  final FeedbackCategory category;

  /// The full message body.
  final String body;

  /// Optional reply-to address.
  final String? email;

  /// The in-app route the visitor was on when submitting.
  final String? pageRoute;

  /// The active locale code (e.g. `en`, `pt_BR`).
  final String? locale;

  @override
  List<Object?> get props => [title, category, body, email, pageRoute, locale];
}
