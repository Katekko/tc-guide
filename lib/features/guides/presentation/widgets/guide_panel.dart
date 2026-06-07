import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

import 'guide_text.dart';

/// A bordered content panel with a title, optional body, and optional child.
class GuidePanel extends StatelessWidget {
  /// Creates a guide panel.
  const GuidePanel({required this.title, this.body, this.child, super.key});

  /// Panel heading.
  final String title;

  /// Optional body paragraph.
  final String? body;

  /// Optional child content (lists, grids, etc.).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (body != null) ...[
              const SizedBox(height: 10),
              GuideParagraph(body!),
            ],
            if (child != null) ...[const SizedBox(height: 14), child!],
          ],
        ),
      ),
    );
  }
}

/// A highlighted callout box for important notes.
/// The visual tone of a [GuideCallout], driving its icon and accent color.
enum GuideCalloutVariant {
  /// Neutral highlight (the original callout style).
  neutral,

  /// Informational aside.
  info,

  /// A helpful tip or pro move.
  tip,

  /// A warning about a common mistake.
  warning,
}

class GuideCallout extends StatelessWidget {
  /// Creates a callout with a [title] and optional [text] and/or [child]. The
  /// [variant] picks the icon and accent color; it defaults to
  /// [GuideCalloutVariant.neutral].
  const GuideCallout({
    required this.title,
    this.text,
    this.child,
    this.variant = GuideCalloutVariant.neutral,
    super.key,
  });

  /// Callout heading.
  final String title;

  /// Optional body paragraph.
  final String? text;

  /// Optional child content (e.g. a list) rendered below the body.
  final Widget? child;

  /// Visual tone of the callout.
  final GuideCalloutVariant variant;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(variant);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: style.accent, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(style.icon, color: style.accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (text != null) ...[
              const SizedBox(height: 8),
              GuideParagraph(text!),
            ],
            if (child != null) ...[const SizedBox(height: 12), child!],
          ],
        ),
      ),
    );
  }

  static _CalloutStyle _styleFor(GuideCalloutVariant variant) =>
      switch (variant) {
        GuideCalloutVariant.neutral => const _CalloutStyle(
            icon: Icons.push_pin_outlined,
            accent: AppColors.cardHoverBorder,
            background: AppColors.selectedBackground,
          ),
        GuideCalloutVariant.info => const _CalloutStyle(
            icon: Icons.info_outline,
            accent: Color(0xff5b9bff),
            background: Color(0x1a5b9bff),
          ),
        GuideCalloutVariant.tip => const _CalloutStyle(
            icon: Icons.lightbulb_outline,
            accent: Color(0xff5fcf80),
            background: Color(0x1a43c96a),
          ),
        GuideCalloutVariant.warning => const _CalloutStyle(
            icon: Icons.warning_amber_rounded,
            accent: Color(0xffe6b455),
            background: Color(0x1ad6a23e),
          ),
      };
}

/// Resolved visuals for a single [GuideCallout] variant.
class _CalloutStyle {
  const _CalloutStyle({
    required this.icon,
    required this.accent,
    required this.background,
  });

  final IconData icon;
  final Color accent;
  final Color background;
}

/// Lays out two panels side by side, stacking them on narrow screens.
class TwoColumnGuidePanels extends StatelessWidget {
  /// Creates a two-column panel layout.
  const TwoColumnGuidePanels({
    required this.left,
    required this.right,
    super.key,
  });

  /// Left panel.
  final Widget left;

  /// Right panel.
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(children: [left, const SizedBox(height: 16), right]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
