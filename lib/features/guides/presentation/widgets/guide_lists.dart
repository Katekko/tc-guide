import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

import 'guide_text.dart';

/// A single row in a numbered or bulleted guide list.
class GuideListRow extends StatelessWidget {
  /// Creates a list row. An empty [marker] renders a bullet dot.
  const GuideListRow({required this.marker, required this.text, super.key});

  /// The leading marker (a number, or empty for a bullet).
  final String marker;

  /// The row text.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: marker.isEmpty ? Colors.transparent : AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 26,
              height: 26,
              child: Center(
                child: marker.isEmpty
                    ? const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.cardHoverBorder,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(width: 7, height: 7),
                      )
                    : Text(
                        marker,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: GuideParagraph(text)),
        ],
      ),
    );
  }
}

/// An ordered list with numeric markers.
class NumberedGuideList extends StatelessWidget {
  /// Creates a numbered list of [items].
  const NumberedGuideList({required this.items, super.key});

  /// Ordered item texts.
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .asMap()
          .entries
          .map(
            (entry) =>
                GuideListRow(marker: '${entry.key + 1}', text: entry.value),
          )
          .toList(),
    );
  }
}

/// An unordered list with bullet markers.
class BulletGuideList extends StatelessWidget {
  /// Creates a bulleted list of [items].
  const BulletGuideList({required this.items, super.key});

  /// Item texts.
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          items.map((item) => GuideListRow(marker: '', text: item)).toList(),
    );
  }
}
