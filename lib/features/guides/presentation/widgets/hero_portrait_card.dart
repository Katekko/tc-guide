import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/core/widgets/card_link.dart';

/// A starter-target hero card: a portrait image, name, role tag, and a short
/// description, linking to the relevant guide [route].
class HeroPortraitCard extends StatelessWidget {
  /// Creates a hero portrait card.
  const HeroPortraitCard({
    required this.name,
    required this.role,
    required this.description,
    required this.image,
    required this.route,
    super.key,
  });

  /// Hero display name.
  final String name;

  /// Short role tag (e.g. "Starter Carry").
  final String role;

  /// One-line description.
  final String description;

  /// Portrait asset path.
  final String image;

  /// Target in-app route.
  final String route;

  @override
  Widget build(BuildContext context) {
    return CardLink(
      route: route,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _RoleTag(role),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small accent pill showing a hero's role.
class _RoleTag extends StatelessWidget {
  const _RoleTag(this.role);

  final String role;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x264568f0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x594568f0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Text(
          role,
          style: const TextStyle(
            color: AppColors.link,
            fontSize: 11,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
