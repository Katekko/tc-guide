import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

import '../../domain/entities/guide_nav.dart';

/// A horizontal chip strip used as the guide navigation on narrow screens.
class DocsMobileIndex extends StatelessWidget {
  /// Creates the mobile index from [items], highlighting [currentPath].
  const DocsMobileIndex({
    required this.items,
    required this.currentPath,
    super.key,
  });

  /// Flattened nav items in display order.
  final List<GuideNavItem> items;

  /// The currently active route.
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.pageBackground,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SizedBox(
        height: 58,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            return DocsIndexChip(
              item: item,
              selected: item.route == currentPath,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemCount: items.length,
        ),
      ),
    );
  }
}

/// A single chip in the mobile index strip.
class DocsIndexChip extends StatelessWidget {
  /// Creates a nav chip.
  const DocsIndexChip({required this.item, required this.selected, super.key});

  /// The item data.
  final GuideNavItem item;

  /// Whether this chip is the active route.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(item.title),
      onPressed: () => context.go(item.route),
      backgroundColor:
          selected ? AppColors.selectedBackground : AppColors.cardBackground,
      side: BorderSide(
        color: selected ? AppColors.cardHoverBorder : AppColors.cardBorder,
      ),
      labelStyle: TextStyle(
        color: selected ? AppColors.primaryText : AppColors.secondaryText,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      ),
    );
  }
}
