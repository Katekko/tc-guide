import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/grade_cost.dart';
import '../../domain/repositories/grade_cost_repository.dart';

/// Full-page content for the Heroes → Star-Up sub-tab: the universal
/// SSR+ → Opal 5★ cost reference (same for every hero), one card per tier band.
class StarUpCostView extends StatefulWidget {
  /// Creates the star-up cost view.
  const StarUpCostView({super.key});

  @override
  State<StarUpCostView> createState() => _StarUpCostViewState();
}

class _StarUpCostViewState extends State<StarUpCostView> {
  Future<GradeCost>? _future;
  String? _languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    if (code != _languageCode) {
      _languageCode = code;
      _future = sl<GradeCostRepository>().load(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FutureBuilder<GradeCost>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load star-up costs: ${snapshot.error}',
              style: const TextStyle(color: AppColors.secondaryText),
            ),
          );
        }
        final data = snapshot.data;
        if (data == null) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TotalStrip(
              text: t.heroesStarUpTotal(data.totalCopies, data.duplicates),
            ),
            const SizedBox(height: 14),
            for (final band in data.bands) ...[
              _BandCard(band: band),
              const SizedBox(height: 12),
            ],
            if (data.tips.isNotEmpty) ...[
              const SizedBox(height: 4),
              _Heading(t.heroesStarUpTipsLabel),
              const SizedBox(height: 6),
              for (final tip in data.tips) _Bullet(tip),
            ],
            if (data.fodderNote.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                data.fodderNote,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12.5,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (data.source.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                '${t.heroesStarUpSourceLabel}: ${data.source}',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TotalStrip extends StatelessWidget {
  const _TotalStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x1ad9a441),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x59d9a441)),
      ),
      child: Row(
        children: [
          const Icon(Icons.military_tech, size: 18, color: Color(0xffd9a441)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BandCard extends StatelessWidget {
  const _BandCard({required this.band});

  final GradeCostBand band;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                band.range,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              _Pill(
                '${band.duplicates}× ${t.heroesStarUpDuplicatesLabel}'
                '${band.needsBaseCopy ? ' ${t.heroesStarUpBaseCopy}' : ''}',
                color: const Color(0xffd9a441),
              ),
              if (band.mostExpensive)
                _Pill(t.heroesStarUpMostExpensive,
                    color: const Color(0xfff02e2e)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            t.heroesStarUpFodderLabel.toUpperCase(),
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 5),
          for (final line in band.fodder) _Bullet(line),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primaryText,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7, right: 8),
            child: Icon(Icons.circle, size: 5, color: AppColors.mutedText),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
