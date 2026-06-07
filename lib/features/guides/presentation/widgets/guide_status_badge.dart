import 'package:flutter/material.dart';

import 'package:tc_flutter_web/features/guides/domain/entities/guide_status.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

/// A small colored pill communicating a guide's [GuideStatus] (draft, needs
/// review, current, outdated) on the guide index.
class GuideStatusBadge extends StatelessWidget {
  /// Creates a badge for [status].
  const GuideStatusBadge({required this.status, super.key});

  /// The status to display.
  final GuideStatus status;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final style = _styleFor(status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Text(
          _labelFor(t, status),
          style: TextStyle(
            color: style.foreground,
            fontSize: 11,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  static String _labelFor(AppLocalizations t, GuideStatus status) =>
      switch (status) {
        GuideStatus.draft => t.statusLabelDraft,
        GuideStatus.needsReview => t.statusLabelNeedsReview,
        GuideStatus.current => t.statusLabelCurrent,
        GuideStatus.outdated => t.statusLabelOutdated,
      };

  static _BadgeStyle _styleFor(GuideStatus status) => switch (status) {
        GuideStatus.draft => const _BadgeStyle(
            foreground: Color(0xffe6b455),
            background: Color(0x26d6a23e),
            border: Color(0x59d6a23e),
          ),
        GuideStatus.needsReview => const _BadgeStyle(
            foreground: Color(0xff8ca1ff),
            background: Color(0x264568f0),
            border: Color(0x594568f0),
          ),
        GuideStatus.current => const _BadgeStyle(
            foreground: Color(0xff5fcf80),
            background: Color(0x2643c96a),
            border: Color(0x5943c96a),
          ),
        GuideStatus.outdated => const _BadgeStyle(
            foreground: Color(0xff9aa6bd),
            background: Color(0x1f8190aa),
            border: Color(0x458190aa),
          ),
      };
}

/// Resolved colors for a single [GuideStatusBadge] variant.
class _BadgeStyle {
  const _BadgeStyle({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;
}
