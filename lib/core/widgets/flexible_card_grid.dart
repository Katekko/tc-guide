import 'package:flutter/material.dart';

/// A wrap-based grid that sizes each child to an even column width derived from
/// the available space.
class FlexibleCardGrid extends StatelessWidget {
  /// Creates a flexible card grid for [children].
  const FlexibleCardGrid({
    required this.children,
    required this.minTileWidth,
    super.key,
  });

  /// The grid items.
  final List<Widget> children;

  /// Minimum tile width used to derive the column count.
  final double minTileWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            (constraints.maxWidth / minTileWidth).floor().clamp(1, 4);
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
