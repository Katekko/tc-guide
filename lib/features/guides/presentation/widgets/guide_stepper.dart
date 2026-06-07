import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

import 'guide_text.dart';

/// A vertical, connected stepper for an ordered sequence of actions — numbered
/// markers joined by a rail, used for the "Quick Start" steps so they read as a
/// path rather than a plain list.
class GuideStepper extends StatelessWidget {
  /// Creates a stepper for the ordered [steps].
  const GuideStepper({required this.steps, super.key});

  /// The ordered step texts.
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, step) in steps.indexed)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Rail(number: index + 1, isLast: index == steps.length - 1),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 1,
                      bottom: index == steps.length - 1 ? 0 : 20,
                    ),
                    child: GuideParagraph(step),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The numbered marker plus the connecting rail drawn down to the next step.
class _Rail extends StatelessWidget {
  const _Rail({required this.number, required this.isLast});

  final int number;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        if (!isLast)
          const Expanded(
            child: SizedBox(
              width: 2,
              child: ColoredBox(color: AppColors.cardBorder),
            ),
          ),
      ],
    );
  }
}
