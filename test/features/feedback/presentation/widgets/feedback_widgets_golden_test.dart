import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/features/feedback/domain/entities/feedback_category.dart';
import 'package:tc_flutter_web/features/feedback/presentation/widgets/contact_links_row.dart';
import 'package:tc_flutter_web/features/feedback/presentation/widgets/helpful_vote.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

/// Wraps a scenario with the inherited widgets the feedback pieces need:
/// directionality, localizations and a [Material] ancestor.
Widget _host(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: Localizations(
        locale: const Locale('en'),
        delegates: AppLocalizations.localizationsDelegates,
        child: Material(color: AppColors.pageBackground, child: child),
      ),
    );

void main() {
  goldenTest(
    'feedback widgets render the helpful vote and contact links',
    fileName: 'feedback_widgets',
    builder: () => GoldenTestGroup(
      columnWidthBuilder: (_) => const FixedColumnWidth(420),
      children: [
        GoldenTestScenario(
          name: 'helpful vote prompt',
          child: _host(const HelpfulVote()),
        ),
        GoldenTestScenario(
          name: 'contact links',
          child: _host(
            const Padding(
              padding: EdgeInsets.all(16),
              child: ContactLinksRow(category: FeedbackCategory.bug),
            ),
          ),
        ),
      ],
    ),
  );
}
