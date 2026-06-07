import 'package:tc_flutter_web/features/feedback/domain/entities/feedback_category.dart';

/// Centralized contact / feedback configuration.
///
/// The Web3Forms access key is **never** hardcoded (see AGENTS.md). It is read
/// from a compile-time environment value, supplied locally via
/// `--dart-define=WEB3FORMS_ACCESS_KEY=...` and in CI via a GitHub Actions
/// secret of the same name. When the key is absent the feedback form degrades
/// gracefully to the GitHub / Discord channels only.
abstract final class ContactConfig {
  /// Web3Forms access key bound to `contact@gyanburuworld.com`.
  static const String web3formsAccessKey =
      String.fromEnvironment('WEB3FORMS_ACCESS_KEY');

  /// Whether email submission is wired up (key present at build time).
  static bool get isEmailConfigured => web3formsAccessKey.isNotEmpty;

  /// Web3Forms submission endpoint.
  static const String web3formsEndpoint = 'https://api.web3forms.com/submit';

  /// Public source repository (issues and PRs are enabled).
  static const String githubRepoUrl = 'https://github.com/Katekko/tc-guide';

  /// Community Discord invite.
  static const String discordInviteUrl = 'https://discord.gg/x7drkFpNFx';

  /// Builds a GitHub "new issue" URL pre-filled with the [category] label and an
  /// optional [title], so power users can open an issue instead of emailing.
  static String newIssueUrl({FeedbackCategory? category, String? title}) {
    final params = <String, String>{
      if (category != null) 'labels': category.key,
      if (title != null && title.isNotEmpty) 'title': title,
    };
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final base = '$githubRepoUrl/issues/new';
    return query.isEmpty ? base : '$base?$query';
  }
}
