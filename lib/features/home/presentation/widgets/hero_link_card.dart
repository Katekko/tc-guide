import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/core/widgets/card_link.dart';

import '../../domain/entities/hero_item.dart';

/// A compact hero tile (image + name + role) linking to that hero's guide.
class HeroLinkCard extends StatelessWidget {
  /// Creates a hero link card for [hero].
  const HeroLinkCard({required this.hero, super.key});

  /// The hero content.
  final HeroItem hero;

  @override
  Widget build(BuildContext context) {
    return CardLink(
      route: hero.route,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                hero.image,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hero.name,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hero.role,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
