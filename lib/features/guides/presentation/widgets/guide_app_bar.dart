import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tc_flutter_web/core/locale/language_dropdown.dart';
import 'package:tc_flutter_web/core/router/app_routes.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

/// The app bar shown on guide pages: page title, language switcher, and a
/// "Back Home" action.
class GuideAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates the guide app bar.
  const GuideAppBar({required this.title, super.key});

  /// The current page title.
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.pageBackground,
      foregroundColor: Colors.white,
      actions: [
        const LanguageDropdown(),
        TextButton(
          onPressed: () => context.go(AppRoutes.home),
          child: Text(AppLocalizations.of(context).backHome),
        ),
      ],
    );
  }
}
