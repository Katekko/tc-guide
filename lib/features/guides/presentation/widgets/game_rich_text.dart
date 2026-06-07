import 'package:flutter/material.dart';

/// Renders the game's lightweight markup found in bios and skill text:
/// `<br/>` line breaks and `<color=#rrggbb>...</color>` colored spans.
///
/// Anything outside those tags is rendered with [baseStyle]. Square-bracket
/// buff names like `[Radiant Barrier]` are left as-is (the game emphasizes
/// them with color tags where it wants to).
class GameRichText extends StatelessWidget {
  /// Creates a rich-text view for game-formatted [text].
  const GameRichText(this.text, {super.key, this.baseStyle});

  /// Raw game string, possibly containing `<br/>` and `<color>` tags.
  final String text;

  /// Base text style for unstyled runs.
  final TextStyle? baseStyle;

  static final RegExp _token = RegExp(
    r'<color=#([0-9a-fA-F]{6,8})>(.*?)</color>|<br\s*/?>',
    dotAll: true,
  );

  @override
  Widget build(BuildContext context) {
    final base = baseStyle ??
        DefaultTextStyle.of(context).style.copyWith(height: 1.45);
    final spans = <InlineSpan>[];
    var index = 0;

    for (final m in _token.allMatches(text)) {
      if (m.start > index) {
        spans.add(TextSpan(text: text.substring(index, m.start)));
      }
      final colorHex = m.group(1);
      if (colorHex != null) {
        spans.add(TextSpan(
          text: m.group(2),
          style: TextStyle(color: _parseColor(colorHex)),
        ));
      } else {
        spans.add(const TextSpan(text: '\n'));
      }
      index = m.end;
    }
    if (index < text.length) {
      spans.add(TextSpan(text: text.substring(index)));
    }

    return Text.rich(TextSpan(style: base, children: spans));
  }

  static Color _parseColor(String hex) {
    final value = int.parse(hex, radix: 16);
    // Expand #rrggbb to opaque ARGB; pass #aarrggbb through unchanged.
    return Color(hex.length == 6 ? 0xff000000 | value : value);
  }
}
