import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/core/router/app_routes.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/hero_summary.dart';
import '../../domain/repositories/hero_roster_repository.dart';
import '../widgets/guide_kit.dart';
import '../widgets/hero_roster_card.dart';

/// The Heroes catalog: a searchable, filterable grid of every hero. Tapping a
/// hero opens its page (`/heroes/:name`).
///
/// Besides the normal catalog browsing it offers a "Daily Hero" mode that helps
/// solve the in-game daily event: the game reveals the name's letter count plus
/// one letter, and this mode lists every hero whose name fits those clues.
class HeroesScreen extends StatelessWidget {
  /// Creates the heroes catalog screen.
  const HeroesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.heroesTitle,
      intro: t.heroesIntro,
      children: const [_HeroBrowser()],
    );
  }
}

/// Loads the roster once, then hands it to the interactive [_Browser].
class _HeroBrowser extends StatefulWidget {
  const _HeroBrowser();

  @override
  State<_HeroBrowser> createState() => _HeroBrowserState();
}

class _HeroBrowserState extends State<_HeroBrowser> {
  final Future<List<HeroSummary>> _future = sl<HeroRosterRepository>().loadAll();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HeroSummary>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load heroes: ${snapshot.error}',
              style: const TextStyle(color: AppColors.secondaryText),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _Browser(all: snapshot.data!);
      },
    );
  }
}

/// Owns all browsing state: the active mode (catalog search vs. daily-event
/// puzzle), the catalog filters, and the puzzle inputs.
class _Browser extends StatefulWidget {
  const _Browser({required this.all});

  final List<HeroSummary> all;

  @override
  State<_Browser> createState() => _BrowserState();
}

class _BrowserState extends State<_Browser> {
  // Catalog mode.
  String _query = '';
  String? _heroClass;
  String? _rarity;
  String? _faction;

  // Daily-event puzzle mode.
  bool _puzzle = false;
  final TextEditingController _countCtrl = TextEditingController();
  final TextEditingController _lettersCtrl = TextEditingController();
  bool _countSpaces = false;

  @override
  void dispose() {
    _countCtrl.dispose();
    _lettersCtrl.dispose();
    super.dispose();
  }

  void _clearPuzzle() {
    setState(() {
      _countCtrl.clear();
      _lettersCtrl.clear();
      _countSpaces = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ModeSwitch(
          puzzle: _puzzle,
          onChanged: (v) => setState(() => _puzzle = v),
        ),
        const SizedBox(height: 16),
        if (_puzzle) ..._buildPuzzle(context, l) else ..._buildCatalog(context, l),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Catalog mode: search box + class/rarity/faction chips.
  // ---------------------------------------------------------------------------

  List<Widget> _buildCatalog(BuildContext context, AppLocalizations l) {
    final all = widget.all;
    final classes = {for (final h in all) h.heroClass}.toList()..sort();
    final rarities = {for (final h in all) h.rarity}.toList()..sort();
    final factions = {for (final h in all) h.faction}.toList()..sort();

    final q = _query.trim().toLowerCase();
    final filtered = all.where((h) {
      if (q.isNotEmpty && !h.name.toLowerCase().contains(q)) return false;
      if (_heroClass != null && h.heroClass != _heroClass) return false;
      if (_rarity != null && h.rarity != _rarity) return false;
      if (_faction != null && h.faction != _faction) return false;
      return true;
    }).toList()
      // Strongest rarity first (UR+ → UR → SSR+ → SSR → R → N), then by name.
      ..sort((a, b) {
        final byRarity = _rarityRank(b.rarity).compareTo(_rarityRank(a.rarity));
        return byRarity != 0
            ? byRarity
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return [
      TextField(
        onChanged: (v) => setState(() => _query = v),
        style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
        decoration: _fieldDecoration(
          hint: l.heroSearchHint,
          prefix: const Icon(Icons.search, color: AppColors.mutedText),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _Chip(
            label: l.heroFilterAll,
            selected: _heroClass == null,
            color: AppColors.link,
            onTap: () => setState(() => _heroClass = null),
          ),
          for (final c in classes)
            _Chip(
              label: c,
              selected: _heroClass == c,
              color: AppColors.secondaryText,
              onTap: () => setState(() => _heroClass = c),
            ),
        ],
      ),
      if (rarities.length > 1) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in rarities)
              _Chip(
                label: r,
                selected: _rarity == r,
                color: const Color(0xffd9a441),
                onTap: () => setState(() => _rarity = _rarity == r ? null : r),
              ),
          ],
        ),
      ],
      if (factions.length > 1) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in factions)
              _Chip(
                label: f,
                selected: _faction == f,
                color: const Color(0xff9b8cff),
                onTap: () =>
                    setState(() => _faction = _faction == f ? null : f),
              ),
          ],
        ),
      ],
      const SizedBox(height: 12),
      ..._results(context, l, filtered, emptyMessage: l.heroEmpty),
    ];
  }

  // ---------------------------------------------------------------------------
  // Daily-event puzzle mode: letter count + known letters + count-spaces toggle.
  // ---------------------------------------------------------------------------

  List<Widget> _buildPuzzle(BuildContext context, AppLocalizations l) {
    final letterCount = int.tryParse(_countCtrl.text.trim());
    final knownLetters = _parseLetters(_lettersCtrl.text);
    final hasConstraints = letterCount != null || knownLetters.isNotEmpty;

    final matches = widget.all.where((h) {
      final lettersOnly = _lettersOnly(h.name);
      if (letterCount != null &&
          _nameLength(h.name, countSpaces: _countSpaces) != letterCount) {
        return false;
      }
      if (!_containsAll(lettersOnly, knownLetters)) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return [
      Text(
        l.heroPuzzleHelp,
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 13,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 14),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: TextField(
              controller: _countCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              onChanged: (_) => setState(() {}),
              style:
                  const TextStyle(color: AppColors.primaryText, fontSize: 14),
              decoration: _fieldDecoration(hint: l.heroPuzzleLetterCount),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _lettersCtrl,
              onChanged: (_) => setState(() {}),
              style:
                  const TextStyle(color: AppColors.primaryText, fontSize: 14),
              decoration: _fieldDecoration(
                hint: '${l.heroPuzzleKnownLetters} (${l.heroPuzzleKnownHint})',
                prefix: const Icon(Icons.abc, color: AppColors.mutedText),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          _Chip(
            label: l.heroPuzzleCountSpaces,
            selected: _countSpaces,
            color: AppColors.link,
            onTap: () => setState(() => _countSpaces = !_countSpaces),
          ),
          const Spacer(),
          if (hasConstraints)
            TextButton(
              onPressed: _clearPuzzle,
              child: Text(
                l.heroPuzzleClear,
                style: const TextStyle(color: AppColors.mutedText),
              ),
            ),
        ],
      ),
      if (knownLetters.isNotEmpty) ...[
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in knownLetters) _LetterTile(letter: c),
          ],
        ),
      ],
      const SizedBox(height: 16),
      if (!hasConstraints)
        _EmptyState(message: l.heroPuzzlePrompt)
      else
        ..._results(context, l, matches, emptyMessage: l.heroPuzzleNoMatch),
    ];
  }

  // ---------------------------------------------------------------------------
  // Shared results block: count label + responsive grid (or empty message).
  // ---------------------------------------------------------------------------

  List<Widget> _results(
    BuildContext context,
    AppLocalizations l,
    List<HeroSummary> filtered, {
    required String emptyMessage,
  }) {
    return [
      Text(
        '${filtered.length} ${l.heroShownLabel}',
        style: const TextStyle(
          color: AppColors.mutedText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
      if (filtered.isEmpty)
        _EmptyState(message: emptyMessage)
      else
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final h in filtered)
              HeroRosterCard(
                hero: h,
                onTap: () => context.go(AppRoutes.heroPath(h.slug)),
              ),
          ],
        ),
    ];
  }
}

/// Shared input decoration so the search box and puzzle fields look identical.
InputDecoration _fieldDecoration({required String hint, Widget? prefix}) {
  return InputDecoration(
    isDense: true,
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.mutedText),
    prefixIcon: prefix,
    filled: true,
    fillColor: AppColors.cardBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.cardHoverBorder),
    ),
  );
}

/// Sort weight for a rarity tier (higher = stronger / shown first).
int _rarityRank(String rarity) => const {
      'UR+': 6,
      'UR': 5,
      'SSR+': 4,
      'SSR': 3,
      'R': 2,
      'N': 1,
    }[rarity] ??
    0;

// -----------------------------------------------------------------------------
// Name-matching helpers for the daily-event puzzle.
// -----------------------------------------------------------------------------

/// Accent → base-letter folds so "Nüwa" matches a search for "nuwa".
const Map<String, String> _diacritics = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n', 'ý': 'y', 'ÿ': 'y',
};

/// Lowercases [input] and strips accents to their base letter.
String _fold(String input) {
  final lower = input.toLowerCase();
  final buf = StringBuffer();
  for (var i = 0; i < lower.length; i++) {
    final ch = lower[i];
    buf.write(_diacritics[ch] ?? ch);
  }
  return buf.toString();
}

/// The folded a–z letters of [name] with everything else (spaces, punctuation)
/// removed — e.g. "Wu Kong" → "wukong".
String _lettersOnly(String name) =>
    _fold(name).replaceAll(RegExp(r'[^a-z]'), '');

/// How long the game would render [name]: by default only its letters count,
/// but with [countSpaces] the gaps between words count too (collapsed to one).
int _nameLength(String name, {required bool countSpaces}) {
  if (!countSpaces) return _lettersOnly(name).length;
  return _fold(name)
      .replaceAll(RegExp(r'[^a-z ]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ')
      .length;
}

/// Parses a free-text "known letters" field into a multiset of a–z letters
/// (e.g. "a, r" or "AR" → ['a', 'r']).
List<String> _parseLetters(String raw) =>
    _fold(raw).replaceAll(RegExp(r'[^a-z]'), '').split('');

/// Whether [lettersOnly] contains every letter in [required], counting
/// multiplicity so "ll" requires two L's.
bool _containsAll(String lettersOnly, List<String> required) {
  if (required.isEmpty) return true;
  final pool = lettersOnly.split('');
  for (final letter in required) {
    final idx = pool.indexOf(letter);
    if (idx < 0) return false;
    pool.removeAt(idx);
  }
  return true;
}

// -----------------------------------------------------------------------------
// Small presentational widgets.
// -----------------------------------------------------------------------------

/// Segmented toggle between the catalog search and the daily-event puzzle.
class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.puzzle, required this.onChanged});

  final bool puzzle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Chip(
          label: l.heroModeSearch,
          selected: !puzzle,
          color: AppColors.link,
          onTap: () => onChanged(false),
        ),
        _Chip(
          label: l.heroModePuzzle,
          selected: puzzle,
          color: AppColors.link,
          onTap: () => onChanged(true),
        ),
      ],
    );
  }
}

/// A single uppercase letter pill echoing back a parsed "known letter".
class _LetterTile extends StatelessWidget {
  const _LetterTile({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.link.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.link),
      ),
      child: Text(
        letter.toUpperCase(),
        style: const TextStyle(
          color: AppColors.link,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Centered helper/empty message shared by both modes.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.secondaryText),
        ),
      ),
    );
  }
}

/// A small toggleable filter chip matching the dark theme.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.18) : AppColors.cardBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? color : AppColors.cardBorder),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : AppColors.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
