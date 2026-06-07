import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

/// A tappable, hover-aware card that navigates to [route] when clicked.
///
/// The hover state is pure ephemeral UI, so this is the one place the app
/// intentionally uses [StatefulWidget]/`setState` (see AGENTS.md).
class CardLink extends StatefulWidget {
  /// Creates a card linking to [route] wrapping [child].
  const CardLink({required this.route, required this.child, super.key});

  /// The in-app route to navigate to on tap.
  final String route;

  /// The card body.
  final Widget child;

  @override
  State<CardLink> createState() => _CardLinkState();
}

class _CardLinkState extends State<CardLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? AppColors.cardHoverBorder : AppColors.cardBorder,
            ),
            boxShadow: _hovered
                ? const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
