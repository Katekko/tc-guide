import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/core/widgets/flexible_card_grid.dart';
import 'package:tc_flutter_web/core/widgets/responsive_grid.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import 'package:tc_flutter_web/features/feedback/presentation/widgets/feedback_fab.dart';

import '../../domain/repositories/home_repository.dart';
import '../widgets/guide_card.dart';
import '../widgets/hero_header.dart';
import '../widgets/hero_link_card.dart';
import '../widgets/home_section.dart';
import '../widgets/note_band.dart';
import '../widgets/step_card.dart';

/// The landing page: hero banner, recommended start, featured heroes, guide
/// sections, and an attribution note.
class HomeScreen extends StatelessWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    final repository = sl<HomeRepository>();

    final starterPath = repository.starterPath(text);
    final featuredHeroes = repository.featuredHeroes(text);
    final guideSections = repository.guideSections(text);

    return Scaffold(
      floatingActionButton: const FeedbackFab(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: HeroHeader(text: text)),
          SliverToBoxAdapter(
            child: HomeSection(
              title: text.recommendedStartTitle,
              subtitle: text.recommendedStartText,
              child: ResponsiveGrid(
                minTileWidth: 230,
                children: starterPath
                    .asMap()
                    .entries
                    .map(
                      (entry) =>
                          StepCard(number: entry.key + 1, item: entry.value),
                    )
                    .toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: HomeSection(
              tone: SectionTone.subtle,
              title: text.featuredHeroesTitle,
              subtitle: text.featuredHeroesText,
              child: ResponsiveGrid(
                minTileWidth: 230,
                childAspectRatio: 2.6,
                children: featuredHeroes
                    .map((hero) => HeroLinkCard(hero: hero))
                    .toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: HomeSection(
              title: text.guideSectionsTitle,
              subtitle: text.guideSectionsText,
              child: FlexibleCardGrid(
                minTileWidth: 300,
                children: guideSections
                    .map((item) => GuideCard(item: item))
                    .toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(child: NoteBand(text: text.note)),
        ],
      ),
    );
  }
}
