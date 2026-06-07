import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/hero_grade.dart';

/// Evolution-ladder selector: a slider across the shared grade ladder
/// (Rare … Opal 5★) showing the picked tier/star and its level cap.
class GradeSelector extends StatelessWidget {
  /// Creates a grade selector.
  const GradeSelector({
    super.key,
    required this.grades,
    required this.index,
    required this.onChanged,
  });

  /// The full ladder.
  final List<HeroGrade> grades;

  /// Currently selected ladder index.
  final int index;

  /// Called with the new index as the slider moves.
  final ValueChanged<int> onChanged;

  /// Accent color per evolution tier.
  static Color tierColor(String tier) {
    switch (tier) {
      case 'Dawn':
        return const Color(0xffe0a050);
      case 'Eternal':
        return const Color(0xff5fd6d0);
      case 'Anima':
        return const Color(0xff8ca1ff);
      case 'Opal':
        return const Color(0xff7fd6a0);
      default:
        return AppColors.mutedText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final grade = grades[index];
    final accent = tierColor(grade.tier);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.heroEvolutionLabel.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Text(
                grade.label,
                style: TextStyle(
                  color: accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${l.levelCapLabel} ${grade.levelCap}',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accent,
              inactiveTrackColor: AppColors.cardBorder,
              thumbColor: accent,
              overlayColor: accent.withValues(alpha: 0.2),
              trackHeight: 3,
            ),
            child: Slider(
              value: index.toDouble(),
              min: 0,
              max: (grades.length - 1).toDouble(),
              divisions: grades.length - 1,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}
