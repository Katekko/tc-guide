import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

import '../../domain/entities/guide_nav.dart';

/// The vertical guide navigation sidebar shown on wide screens.
class DocsSidebar extends StatelessWidget {
  /// Creates the sidebar for [entries], highlighting [currentPath].
  const DocsSidebar({
    required this.entries,
    required this.currentPath,
    super.key,
  });

  /// The navigation tree.
  final List<GuideNavEntry> entries;

  /// The currently active route.
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppColors.pageBackground,
        border: Border(right: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
          children: entries.map((entry) {
            switch (entry) {
              case GuideNavLink():
                return DocsIndexTile(
                  item: GuideNavItem(title: entry.title, route: entry.route),
                  selected: entry.route == currentPath,
                );
              case GuideNavSection():
                return DocsIndexSection(
                  section: entry,
                  currentPath: currentPath,
                );
            }
          }).toList(),
        ),
      ),
    );
  }
}

/// A collapsible category in the sidebar.
class DocsIndexSection extends StatelessWidget {
  /// Creates a sidebar section.
  const DocsIndexSection({
    required this.section,
    required this.currentPath,
    super.key,
  });

  /// The section data.
  final GuideNavSection section;

  /// The currently active route.
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final containsCurrent =
        section.items.any((item) => item.route == currentPath);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          key: PageStorageKey(section.title),
          initiallyExpanded: containsCurrent,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.only(left: 8, bottom: 4),
          expandedAlignment: Alignment.centerLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          iconColor: AppColors.secondaryText,
          collapsedIconColor: AppColors.secondaryText,
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(
            section.title,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          children: section.items
              .map(
                (item) => DocsIndexTile(
                  item: item,
                  selected: item.route == currentPath,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// A single tappable row in the sidebar.
class DocsIndexTile extends StatelessWidget {
  /// Creates a sidebar tile.
  const DocsIndexTile({required this.item, required this.selected, super.key});

  /// The item data.
  final GuideNavItem item;

  /// Whether this tile is the active route.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? AppColors.selectedBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => context.go(item.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Text(
              item.title,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: selected ? AppColors.link : AppColors.secondaryText,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
