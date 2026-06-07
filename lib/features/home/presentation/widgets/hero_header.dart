import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/router/app_routes.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import 'action_buttons.dart';

/// The hero banner at the top of the home screen.
class HeroHeader extends StatelessWidget {
  /// Creates the hero header.
  const HeroHeader({required this.text, super.key});

  /// Localized strings for the current locale.
  final AppLocalizations text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 430),
      decoration: const BoxDecoration(
        color: Color(0xff101624),
        image: DecorationImage(
          image: AssetImage('assets/img/banner.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xee0c121f), Color(0xbb0c121f), Color(0x330c121f)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 42, 24, 58),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text.heroEyebrow.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xff9db7ff),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Text(
                          text.appTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Text(
                          text.heroSubtitle,
                          style: const TextStyle(
                            color: Color(0xffd8dfef),
                            fontSize: 20,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          PrimaryActionButton(
                            label: text.ctaStartHere,
                            route: AppRoutes.gettingStarted,
                          ),
                          SecondaryActionButton(
                            label: text.ctaUrGuide,
                            route: AppRoutes.urIntroduction,
                          ),
                          SecondaryActionButton(
                            label: text.ctaTeamComps,
                            route: AppRoutes.teamComps,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
