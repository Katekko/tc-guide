import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/core/widgets/hero_spine_view.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/hero_detail.dart';
import '../../domain/entities/hero_grade.dart';
import '../../domain/repositories/hero_detail_repository.dart';
import '../widgets/game_rich_text.dart';
import '../widgets/grade_selector.dart';
import '../widgets/skill_slot_modal.dart';

/// Hero data bundled with the shared evolution ladder.
class _HeroData {
  const _HeroData(this.hero, this.grades);
  final HeroDetail hero;
  final GradeData grades;
}

/// Standalone hero detail screen at `/hero/:id` — wraps [HeroDetailView] in a
/// scrollable, centered scaffold.
class HeroDetailScreen extends StatelessWidget {
  /// Creates the detail screen for the given TC hero [id].
  const HeroDetailScreen({super.key, required this.id});

  /// TC hero id (e.g. 55007 for Jeanne).
  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(child: HeroDetailView(id: id)),
        ),
      ),
    );
  }
}

/// Game-faithful hero detail content: live Spine portrait, header, the four
/// skill slots (tap for the skill modal), class/role, stats and lore.
///
/// Scaffold-free so it can be embedded inside a guide page or the standalone
/// [HeroDetailScreen]. Loads its data from [HeroDetailRepository].
class HeroDetailView extends StatefulWidget {
  /// Creates the detail view for the given TC hero [id].
  const HeroDetailView({super.key, required this.id});

  /// TC hero id (e.g. 55007 for Jeanne).
  final int id;

  @override
  State<HeroDetailView> createState() => _HeroDetailViewState();
}

class _HeroDetailViewState extends State<HeroDetailView> {
  Future<_HeroData>? _future;
  String? _languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload hero text when the locale changes (the ladder is locale-agnostic).
    final code = Localizations.localeOf(context).languageCode;
    if (code != _languageCode) {
      _languageCode = code;
      final repo = sl<HeroDetailRepository>();
      _future = Future.wait([
        repo.load(widget.id, code),
        repo.loadGrades(),
      ]).then((r) => _HeroData(r[0] as HeroDetail, r[1] as GradeData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HeroData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load hero: ${snapshot.error}',
                style: const TextStyle(color: AppColors.secondaryText)),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _HeroBody(data: snapshot.data!);
      },
    );
  }
}

class _HeroBody extends StatefulWidget {
  const _HeroBody({required this.data});

  final _HeroData data;

  @override
  State<_HeroBody> createState() => _HeroBodyState();
}

class _HeroBodyState extends State<_HeroBody> {
  late int _gradeIndex = widget.data.grades.ladder.length - 1;

  @override
  Widget build(BuildContext context) {
    final hero = widget.data.hero;
    final grades = widget.data.grades;
    // The grade tier drives only the Awaken passive's level.
    final awakenLevel = grades.awakenLevelAt(_gradeIndex);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Portrait(hero: hero),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (grades.ladder.isNotEmpty)
                GradeSelector(
                  grades: grades.ladder,
                  index: _gradeIndex,
                  onChanged: (i) => setState(() => _gradeIndex = i),
                ),
              const SizedBox(height: 16),
              _SkillRow(hero: hero, awakenLevel: awakenLevel),
              const SizedBox(height: 16),
              _ClassRoleBar(hero: hero),
              const SizedBox(height: 12),
              _StatsRow(stats: hero.baseStats),
              const SizedBox(height: 22),
              _BioCard(hero: hero),
            ],
          ),
        ),
      ],
    );
  }
}

class _Portrait extends StatelessWidget {
  const _Portrait({required this.hero});

  final HeroDetail hero;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Live Spine animation on web; an empty box on other targets.
        HeroSpineView(heroId: hero.spineId, height: 460),
        // Bottom fade into the page background so the UI sits on the art.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.pageBackground],
                ),
              ),
            ),
          ),
        ),
        Positioned(top: 16, left: 16, child: _NamePlate(hero: hero)),
      ],
    );
  }
}

class _NamePlate extends StatelessWidget {
  const _NamePlate({required this.hero});

  final HeroDetail hero;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Element/grade ("Anima") lives in the evolution slider now, so the
        // title only needs the rarity badge.
        _Badge(hero.rarity, const Color(0xffd9a441)),
        const SizedBox(height: 6),
        Text(
          hero.epithet,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          hero.fullName,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            shadows: [Shadow(color: Colors.black, blurRadius: 8)],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            hero.stars,
            (_) => const Icon(Icons.star, size: 14, color: Color(0xffd9a441)),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.hero, required this.awakenLevel});

  final HeroDetail hero;

  /// Awaken passive level driven by the current evolution grade (0 = locked).
  final int awakenLevel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final slot in hero.skillSlots)
          _SkillSlotButton(slot: slot, awakenLevel: awakenLevel),
      ],
    );
  }
}

class _SkillSlotButton extends StatelessWidget {
  const _SkillSlotButton({required this.slot, required this.awakenLevel});

  final HeroSkillSlot slot;
  final int awakenLevel;

  @override
  Widget build(BuildContext context) {
    // Skill & Ultimate never level up (always Lv 1). Awaken is grade-driven and
    // locked below Dawn 4★. Genesis is dupe-fed and configured in its modal.
    final locked = slot.key == 'awaken' && awakenLevel == 0;
    final String levelLabel;
    switch (slot.key) {
      case 'awaken':
        levelLabel = locked ? '🔒' : 'Lv $awakenLevel';
      case 'genesis':
        levelLabel = 'Lv ${slot.effects.length}';
      default:
        levelLabel = 'Lv 1';
    }
    final unlockedTiers = slot.key == 'awaken' ? awakenLevel : null;
    return InkWell(
      onTap: () => showSkillSlotModal(context, slot, unlockedTiers: unlockedTiers),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Opacity(
          opacity: locked ? 0.55 : 1,
          child: Column(
            children: [
              Text(
                slot.slot,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              SkillSlotIcon(slotKey: slot.key, size: 54),
              const SizedBox(height: 6),
              Text(
                levelLabel,
                style: TextStyle(
                  color: slotColor(slot.key),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassRoleBar extends StatelessWidget {
  const _ClassRoleBar({required this.hero});

  final HeroDetail hero;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shield, size: 16, color: AppColors.secondaryText),
        const SizedBox(width: 6),
        Text(AppLocalizations.of(context).heroClassFormat(hero.heroClass),
            style: const TextStyle(
                color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
        const SizedBox(width: 18),
        ...hero.roles.map((r) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(r,
                    style: const TextStyle(
                        color: AppColors.bodyText, fontSize: 12)),
              ),
            )),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final HeroStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Builder(builder: (context) {
        final l = AppLocalizations.of(context);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Stat(Icons.favorite, l.statHp, stats.hp, const Color(0xffe5677a)),
            _Stat(Icons.gps_fixed, l.statAtk, stats.atk, const Color(0xffe0a050)),
            _Stat(Icons.shield, l.statDef, stats.def, const Color(0xff5fa8ff)),
            _Stat(Icons.bolt, l.statSpd, stats.spd, const Color(0xff7fd6a0)),
          ],
        );
      }),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.label, this.value, this.color);

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text('$value',
            style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(
                color: AppColors.mutedText, fontSize: 11)),
      ],
    );
  }
}

class _BioCard extends StatelessWidget {
  const _BioCard({required this.hero});

  final HeroDetail hero;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.heroBackground,
              style: const TextStyle(
                  color: AppColors.eyebrow,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6)),
          const SizedBox(height: 8),
          GameRichText(
            hero.bio,
            baseStyle: const TextStyle(
                color: AppColors.bodyText, fontSize: 14, height: 1.55),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 4,
            children: [
              _Meta(l.heroHeightLabel, hero.height),
              _Meta(l.heroIllustratorLabel, hero.illustrator),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: [
      TextSpan(
          text: '$label: ',
          style: const TextStyle(
              color: AppColors.mutedText, fontSize: 12)),
      TextSpan(
          text: value,
          style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
    ]));
  }
}
