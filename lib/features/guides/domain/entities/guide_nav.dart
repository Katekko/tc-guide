import 'package:equatable/equatable.dart';

import 'guide_status.dart';

/// A single navigable guide entry (title + in-app route + freshness status).
class GuideNavItem extends Equatable {
  /// Creates a nav item. New pages default to [GuideStatus.draft] until they
  /// are reviewed.
  const GuideNavItem({
    required this.title,
    required this.route,
    this.status = GuideStatus.draft,
  });

  /// Localized display label.
  final String title;

  /// Target in-app route.
  final String route;

  /// Review/freshness state shown as a badge on the guide index.
  final GuideStatus status;

  @override
  List<Object?> get props => [title, route, status];
}

/// Base type for a top-level sidebar entry: either a standalone [GuideNavLink]
/// or a collapsible [GuideNavSection].
sealed class GuideNavEntry extends Equatable {
  const GuideNavEntry();
}

/// A standalone sidebar link with no children (e.g. the top-level index).
class GuideNavLink extends GuideNavEntry {
  /// Creates a standalone nav link. Defaults to [GuideStatus.current] since
  /// standalone links are typically finished index/landing pages.
  const GuideNavLink({
    required this.title,
    required this.route,
    this.status = GuideStatus.current,
  });

  /// Localized display label.
  final String title;

  /// Target in-app route.
  final String route;

  /// Review/freshness state shown as a badge.
  final GuideStatus status;

  @override
  List<Object?> get props => [title, route, status];
}

/// A collapsible category grouping several [GuideNavItem]s.
class GuideNavSection extends GuideNavEntry {
  /// Creates a nav section.
  const GuideNavSection({required this.title, required this.items});

  /// Localized section label.
  final String title;

  /// Items contained in the section.
  final List<GuideNavItem> items;

  @override
  List<Object?> get props => [title, items];
}
