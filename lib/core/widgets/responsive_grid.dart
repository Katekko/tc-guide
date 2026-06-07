import 'package:flutter/material.dart';

/// A grid that picks a column count from the available width and falls back to
/// a single stacked column on narrow screens.
class ResponsiveGrid extends StatelessWidget {
  /// Creates a responsive grid for [children].
  const ResponsiveGrid({
    required this.children,
    required this.minTileWidth,
    this.childAspectRatio,
    super.key,
  });

  /// The grid items.
  final List<Widget> children;

  /// Minimum tile width used to derive the column count.
  final double minTileWidth;

  /// Optional fixed aspect ratio for tiles.
  final double? childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            (constraints.maxWidth / minTileWidth).floor().clamp(1, 4);

        if (columns == 1) {
          return Column(
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: child,
                  ),
                )
                .toList(),
          );
        }

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio ?? (columns >= 4 ? 1.35 : 0.75),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}
