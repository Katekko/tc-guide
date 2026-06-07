import 'package:equatable/equatable.dart';

/// A titled, described link to an in-app [route]. Used for the starter path,
/// guide-section cards, and similar navigational tiles on the home screen.
class LinkItem extends Equatable {
  /// Creates a link item.
  const LinkItem({
    required this.title,
    required this.text,
    required this.route,
  });

  /// Short headline for the tile.
  final String title;

  /// Supporting description.
  final String text;

  /// The in-app route this tile navigates to.
  final String route;

  @override
  List<Object?> get props => [title, text, route];
}
