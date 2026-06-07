import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/feedback_category.dart';
import 'feedback_sheet.dart';

/// Lightweight "Was this guide helpful?" prompt shown at the foot of every
/// guide page.
///
/// Because the site is static there is no backend to tally votes, so the two
/// answers do different things: **Yes** shows a local thank-you (a feel-good
/// acknowledgment), while **No** opens the feedback sheet pre-filled for the
/// current guide — turning a negative signal into an actionable report.
class HelpfulVote extends StatefulWidget {
  /// Creates the helpful-vote prompt.
  const HelpfulVote({super.key});

  @override
  State<HelpfulVote> createState() => _HelpfulVoteState();
}

class _HelpfulVoteState extends State<HelpfulVote> {
  final ValueNotifier<bool> _votedYes = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _votedYes.dispose();
    super.dispose();
  }

  void _no(BuildContext context) {
    FeedbackSheet.show(
      context,
      initialCategory: FeedbackCategory.guide,
      pageRoute: GoRouterState.of(context).matchedLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: _votedYes,
      builder: (context, votedYes, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: votedYes
              ? Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: AppColors.accent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.helpfulThanks,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(
                      l10n.helpfulQuestion,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _votedYes.value = true,
                      icon: const Icon(Icons.thumb_up_outlined, size: 16),
                      label: Text(l10n.helpfulYes),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryText,
                        side: const BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _no(context),
                      icon: const Icon(Icons.thumb_down_outlined, size: 16),
                      label: Text(l10n.helpfulNo),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryText,
                        side: const BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
