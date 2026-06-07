import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tc_flutter_web/core/config/contact_config.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/feedback_category.dart';

/// A labelled row of alternative contact channels (GitHub, Discord) shown
/// inside the feedback sheet for people who would rather open an issue / PR or
/// chat on Discord than send an email.
class ContactLinksRow extends StatelessWidget {
  /// Creates the contact links row.
  ///
  /// When [category] / [title] are provided, the GitHub link pre-fills a new
  /// issue with the matching label and title.
  const ContactLinksRow({this.category, this.title, super.key});

  /// Optional category used to pre-fill a GitHub issue label.
  final FeedbackCategory? category;

  /// Optional title used to pre-fill a GitHub issue title.
  final String? title;

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.feedbackChannelsLabel,
          style: const TextStyle(color: AppColors.mutedText, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _open(
                ContactConfig.newIssueUrl(category: category, title: title),
              ),
              icon: const Icon(Icons.code, size: 18),
              label: Text(l10n.feedbackGithub),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryText,
                side: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _open(ContactConfig.discordInviteUrl),
              icon: const Icon(Icons.forum_outlined, size: 18),
              label: Text(l10n.feedbackDiscord),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryText,
                side: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
