import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/soul_mirror.dart';
import '../../domain/repositories/soul_mirror_repository.dart';
import '../widgets/guide_kit.dart';
import '../widgets/soul_mirror_card.dart';
import '../widgets/soul_mirror_kit.dart';
import '../widgets/soul_mirror_modal.dart';

/// The Soul Mirrors page: a searchable, filterable catalog of every mirror.
class SoulMirrorsScreen extends StatelessWidget {
  /// Creates the soul mirrors screen.
  const SoulMirrorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.soulMirrorsTitle,
      intro: t.soulMirrorsIntro,
      children: const [_SoulMirrorBrowser()],
    );
  }
}

/// Loads the mirror catalog and drives the search box + type/tag filters.
class _SoulMirrorBrowser extends StatefulWidget {
  const _SoulMirrorBrowser();

  @override
  State<_SoulMirrorBrowser> createState() => _SoulMirrorBrowserState();
}

class _SoulMirrorBrowserState extends State<_SoulMirrorBrowser> {
  Future<List<SoulMirror>>? _future;
  String? _languageCode;

  String _query = '';
  SoulMirrorType? _type;
  final Set<String> _tags = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    if (code != _languageCode) {
      _languageCode = code;
      _future = sl<SoulMirrorRepository>().loadAll(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SoulMirror>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load soul mirrors: ${snapshot.error}',
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
        return _Browser(
          all: snapshot.data!,
          query: _query,
          type: _type,
          tags: _tags,
          onQuery: (v) => setState(() => _query = v),
          onType: (v) => setState(() => _type = v),
          onToggleTag: (tag) => setState(() {
            if (!_tags.remove(tag)) _tags.add(tag);
          }),
        );
      },
    );
  }
}

class _Browser extends StatelessWidget {
  const _Browser({
    required this.all,
    required this.query,
    required this.type,
    required this.tags,
    required this.onQuery,
    required this.onType,
    required this.onToggleTag,
  });

  final List<SoulMirror> all;
  final String query;
  final SoulMirrorType? type;
  final Set<String> tags;
  final ValueChanged<String> onQuery;
  final ValueChanged<SoulMirrorType?> onType;
  final ValueChanged<String> onToggleTag;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    // Filter options derived from the actual data.
    final availableTypes = <SoulMirrorType>[
      for (final ty in SoulMirrorType.values)
        if (ty != SoulMirrorType.unknown && all.any((m) => m.type == ty)) ty,
    ];
    final tagCounts = <String, int>{};
    for (final m in all) {
      for (final t in m.tags) {
        tagCounts[t] = (tagCounts[t] ?? 0) + 1;
      }
    }
    final availableTags = tagCounts.keys.toList()
      ..sort((a, b) => tagCounts[b]!.compareTo(tagCounts[a]!));

    final q = query.trim().toLowerCase();
    final filtered = all.where((m) {
      if (q.isNotEmpty && !m.name.toLowerCase().contains(q)) return false;
      if (type != null && m.type != type) return false;
      if (tags.isNotEmpty && !tags.every(m.tags.contains)) return false;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: onQuery,
          style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            hintText: l.soulMirrorSearchHint,
            hintStyle: const TextStyle(color: AppColors.mutedText),
            prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardHoverBorder),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Chip(
              label: l.soulMirrorTypeAll,
              selected: type == null,
              color: AppColors.link,
              onTap: () => onType(null),
            ),
            for (final ty in availableTypes)
              _Chip(
                label: SoulMirrorTypeStyle.label(ty, l),
                selected: type == ty,
                color: SoulMirrorTypeStyle.of(ty).color,
                icon: SoulMirrorTypeStyle.of(ty).icon,
                onTap: () => onType(ty),
              ),
          ],
        ),
        if (availableTags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in availableTags)
                _Chip(
                  label: humanizeTag(tag),
                  selected: tags.contains(tag),
                  color: AppColors.secondaryText,
                  onTap: () => onToggleTag(tag),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Text(
          '${filtered.length} ${l.soulMirrorShownLabel}',
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Text(
                l.soulMirrorEmpty,
                style: const TextStyle(color: AppColors.secondaryText),
              ),
            ),
          )
        else
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final m in filtered)
                SoulMirrorCard(
                  mirror: m,
                  onTap: () => showSoulMirrorModal(context, m),
                ),
            ],
          ),
      ],
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
    this.icon,
  });

  final String label;
  final bool selected;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          selected ? color.withValues(alpha: 0.18) : AppColors.cardBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : AppColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 14,
                    color: selected ? color : AppColors.secondaryText),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : AppColors.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
