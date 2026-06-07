import 'package:flutter/material.dart';

/// Centralized color palette for the app, mirroring the dark theme that was
/// previously scattered across `main.dart` and the markdown stylesheet.
abstract final class AppColors {
  /// Page-level background (darkest surface).
  static const Color pageBackground = Color(0xff070b16);

  /// Default content section background.
  static const Color sectionBackground = Color(0xff0c1222);

  /// Alternate (slightly lighter) section background.
  static const Color sectionAltBackground = Color(0xff111a2d);

  /// Card / panel surface.
  static const Color cardBackground = Color(0xff151f34);

  /// Default card / divider border.
  static const Color cardBorder = Color(0xff2a3856);

  /// Card border on hover / emphasis.
  static const Color cardHoverBorder = Color(0xff6f8cff);

  /// Background used to highlight the selected nav item.
  static const Color selectedBackground = Color(0xff1d2a46);

  /// Primary, high-contrast text.
  static const Color primaryText = Color(0xfff4f7fb);

  /// Secondary, lower-emphasis text.
  static const Color secondaryText = Color(0xffa8b4c7);

  /// Muted text (captions, roles).
  static const Color mutedText = Color(0xff8190aa);

  /// Long-form body text inside guide pages.
  static const Color bodyText = Color(0xffc4cee0);

  /// Accent / brand color (buttons, markers).
  static const Color accent = Color(0xff4568f0);

  /// Link and selected-item accent.
  static const Color link = Color(0xff8ca1ff);

  /// Eyebrow / kicker text above headings.
  static const Color eyebrow = Color(0xff9db7ff);
}
