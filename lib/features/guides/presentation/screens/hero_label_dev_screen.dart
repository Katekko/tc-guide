import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

/// **Dev-only** tool (route `/dev/heroes-label`) for hand-labelling every
/// hero's rarity tier, since rarity isn't stored in any extractable config.
///
/// Loads the full roster from `assets/data/heroes/_all_for_labeling.json`
/// (id/name/class/faction + an `f48`-derived UR/SSR+ guess), pre-selects the
/// guess, and lets you tap the correct tier per hero. The result is emitted as
/// a `{ "<id>": "<rarity>" }` JSON blob to copy back (faction is already
/// auto-derived, so only rarity needs labelling). Not linked from any nav.
class HeroLabelDevScreen extends StatefulWidget {
  /// Creates the dev labelling screen.
  const HeroLabelDevScreen({super.key});

  @override
  State<HeroLabelDevScreen> createState() => _HeroLabelDevScreenState();
}

class _HeroLabelDevScreenState extends State<HeroLabelDevScreen> {
  static const tiers = ['R', 'SR', 'SSR', 'SSR+', 'UR', 'UR+'];

  List<Map<String, dynamic>> _heroes = [];
  final Map<int, String> _labels = {};
  final _importCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _importCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final raw = await rootBundle
        .loadString('assets/data/heroes/_all_for_labeling.json');
    final list = (json.decode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    setState(() {
      _heroes = list;
      for (final h in list) {
        _labels[h['id'] as int] = h['guess'] as String? ?? 'SSR+';
      }
      _loading = false;
    });
  }

  String get _exportJson {
    final map = {for (final h in _heroes) '${h['id']}': _labels[h['id']]};
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  void _import() {
    try {
      final decoded = json.decode(_importCtrl.text) as Map<String, dynamic>;
      setState(() {
        decoded.forEach((k, v) {
          final id = int.tryParse(k);
          if (id != null && v is String) _labels[id] = v;
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Labels loaded from pasted JSON.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not parse JSON: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.primaryText,
        title: const Text('Label hero rarity (dev)'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  children: [
                    _Toolbar(
                      count: _heroes.length,
                      exportJson: _exportJson,
                      importCtrl: _importCtrl,
                      onImport: _import,
                    ),
                    const Divider(height: 1, color: AppColors.cardBorder),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _heroes.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final h = _heroes[i];
                          final id = h['id'] as int;
                          return _HeroRow(
                            index: i + 1,
                            name: h['name'] as String,
                            subtitle:
                                '${h['faction']} · ${h['heroClass']}  ·  #$id',
                            tiers: tiers,
                            selected: _labels[id],
                            guess: h['guess'] as String?,
                            onPick: (t) => setState(() => _labels[id] = t),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.count,
    required this.exportJson,
    required this.importCtrl,
    required this.onImport,
  });

  final int count;
  final String exportJson;
  final TextEditingController importCtrl;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '$count heroes — tap the correct tier, then copy',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: exportJson));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rarity JSON copied.')),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy JSON'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: importCtrl,
                  maxLines: 1,
                  style: const TextStyle(
                      color: AppColors.primaryText, fontSize: 12),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Paste a previously-copied JSON to resume…',
                    hintStyle: TextStyle(color: AppColors.mutedText),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: onImport, child: const Text('Load')),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroRow extends StatelessWidget {
  const _HeroRow({
    required this.index,
    required this.name,
    required this.subtitle,
    required this.tiers,
    required this.selected,
    required this.guess,
    required this.onPick,
  });

  final int index;
  final String name;
  final String subtitle;
  final List<String> tiers;
  final String? selected;
  final String? guess;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('$index',
                style: const TextStyle(color: AppColors.mutedText)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.mutedText, fontSize: 11)),
              ],
            ),
          ),
          Wrap(
            spacing: 6,
            children: [
              for (final t in tiers)
                _TierButton(
                  label: t,
                  selected: selected == t,
                  isGuess: guess == t,
                  onTap: () => onPick(t),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TierButton extends StatelessWidget {
  const _TierButton({
    required this.label,
    required this.selected,
    required this.isGuess,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isGuess;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xff6ea8ff);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? accent : AppColors.pageBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? accent
                : (isGuess ? accent.withValues(alpha: 0.5) : AppColors.cardBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
