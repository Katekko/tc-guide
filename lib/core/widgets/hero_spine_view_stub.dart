import 'package:flutter/widgets.dart';

/// Non-web fallback: the Spine web player only exists on web, so render nothing.
class HeroSpineView extends StatelessWidget {
  /// Creates a (no-op on non-web) hero animation view.
  const HeroSpineView({
    super.key,
    required this.heroId,
    this.height = 420,
    this.animation,
  });

  /// TC hero id, e.g. `'55007'` for Jeanne.
  final String heroId;

  /// Height of the animation box in logical pixels.
  final double height;

  /// Optional animation clip name to force (defaults to Idle in the player).
  final String? animation;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}
