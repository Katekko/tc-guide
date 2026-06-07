import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

/// Filled call-to-action button that navigates to [route].
class PrimaryActionButton extends StatelessWidget {
  /// Creates a primary action button.
  const PrimaryActionButton({
    required this.label,
    required this.route,
    super.key,
  });

  /// Button label.
  final String label;

  /// Route to navigate to on press.
  final String route;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => context.go(route),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

/// Outlined call-to-action button that navigates to [route].
class SecondaryActionButton extends StatelessWidget {
  /// Creates a secondary action button.
  const SecondaryActionButton({
    required this.label,
    required this.route,
    super.key,
  });

  /// Button label.
  final String label;

  /// Route to navigate to on press.
  final String route;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.go(route),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white70),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
