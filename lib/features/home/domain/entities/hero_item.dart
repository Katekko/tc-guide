import 'package:equatable/equatable.dart';

/// A featured hero shown on the home screen, linking to that hero's guide.
class HeroItem extends Equatable {
  /// Creates a hero item.
  const HeroItem({
    required this.name,
    required this.role,
    required this.image,
    required this.route,
  });

  /// Hero display name.
  final String name;

  /// Short role label (e.g. "Starter Carry").
  final String role;

  /// Asset path to the hero's profile image.
  final String image;

  /// The in-app route this hero links to.
  final String route;

  @override
  List<Object?> get props => [name, role, image, route];
}
