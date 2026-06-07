import 'package:equatable/equatable.dart';

/// A single step in the "Start Here" learning path on the guide index: a short
/// title, a one-line explanation, and the guide it links to.
class GuideStep extends Equatable {
  /// Creates a start-path step.
  const GuideStep({
    required this.title,
    required this.text,
    required this.route,
  });

  /// Localized step title.
  final String title;

  /// Localized one-line description.
  final String text;

  /// Target in-app route.
  final String route;

  @override
  List<Object?> get props => [title, text, route];
}
