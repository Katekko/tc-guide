import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/core/widgets/hero_spine_view.dart';

/// A featured hero spotlight: a live Spine animation beside an eyebrow, name,
/// description, and a call-to-action linking to the hero's detail page. Stacks
/// the animation above the text on narrow screens.
class HeroSpineSpotlight extends StatelessWidget {
  /// Creates a hero spotlight.
  const HeroSpineSpotlight({
    required this.spineId,
    required this.eyebrow,
    required this.name,
    required this.description,
    required this.ctaLabel,
    required this.route,
    super.key,
  });

  /// Spine animation id (e.g. `'55007'`).
  final String spineId;

  /// Small kicker above the name.
  final String eyebrow;

  /// Hero display name.
  final String name;

  /// Supporting description.
  final String description;

  /// Label for the call-to-action.
  final String ctaLabel;

  /// Hero detail route.
  final String route;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff19233c), Color(0xff121a2e)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final animation = SizedBox(
              height: 320,
              child: HeroSpineView(heroId: spineId, height: 320),
            );
            final text = _SpotlightText(
              eyebrow: eyebrow,
              name: name,
              description: description,
              ctaLabel: ctaLabel,
              route: route,
            );

            if (constraints.maxWidth < 620) {
              return Column(children: [animation, text]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 280, child: animation),
                Expanded(child: text),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SpotlightText extends StatelessWidget {
  const _SpotlightText({
    required this.eyebrow,
    required this.name,
    required this.description,
    required this.ctaLabel,
    required this.route,
  });

  final String eyebrow;
  final String name;
  final String description;
  final String ctaLabel;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              color: AppColors.eyebrow,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 15.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          _CtaButton(label: ctaLabel, route: route),
        ],
      ),
    );
  }
}

/// A pill button navigating to the hero detail [route].
class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.label, required this.route});

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(route),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
