#!/usr/bin/env python3
"""Audit the auto-derived Soul Mirror tags against the mirror text.

For every mirror it scans the full skill text (activation + per-star) against a
*superset* of evidence phrases per filter tag — deliberately broader than the
live tagging rules in extract_soul_mirrors.py — and reports:

  UNDER  text clearly mentions a tag's keyword but the tag is missing
  OVER   a tag is assigned with no supporting keyword in the text

UNDER findings are tagger gaps to fix; OVER findings are false positives.
Run after extract_soul_mirrors.py:  python3 tools/audit_soul_mirror_tags.py

This is a read-only report — it never edits the data.
"""
import json
import re
import sys

DATA = 'assets/data/soul_mirrors/soul_mirrors.en.json'

# Text evidence per tag (lowercase regex). Tuned to avoid known false hits:
# "Final DMG RED" (reduction) is excluded from final-dmg via a lookahead, and
# "Max HP" (shield/scaling) is excluded from hp by requiring a +/by-number.
EVIDENCE = {
    'final-dmg': [r'final d(?:mg|amage)(?! red)'],
    'dmg-reduction': [r'dmg red', r'final dmg red', r'reduce[sd]? .{0,25}(?:dmg|damage)',
                      r'damage taken', r'reduces? excess'],
    'true-dmg': [r'true d(?:mg|amage)'],
    'crit': [r'\bcrit\b', r'crit rate', r'crit dmg', r'critical'],
    'crit-resist': [r'crit d(?:mg|amage) red', r'crit resist'],
    'heal': [r'\bheal', r'recover', r'revive', r'healing received', r'healed boost'],
    'shield': [r'shield'],
    'bleed': [r'bleed'],
    'infect': [r'infect'],
    'control': [r'\bstun', r'\bcontrol\b', r'\[lethal\]', r'silence', r'freeze', r'petrif'],
    'aoe': [r'area attack', r'\baoe\b', r'area damage', r'all enemies', r'distributed among all'],
    'basic-atk': [r'basic attack', r'\bbatk\b'],
    'ultimate': [r'ultimate'],
    'single-target': [r'single[ -](?:target|attack|skill|heal)'],
    'def-ignore': [r'def ignore', r'ignore .{0,8}def', r'penetrat', r'armor pen'],
    'effect-hit': [r'effect (?:hit|resist)'],
    'atk': [r'\batk \+\d', r'increase[sd]? .{0,6}atk by'],
    'def': [r'\bdef \+\d', r'increase[sd]? .{0,6}def by'],
    'hp': [r'\bhp \+\d', r'\bhp by \d', r'increase[sd]? .{0,6}hp by'],
}

# Machine params that justify a tag (mirrors extract_soul_mirrors.py PARAM_TAG).
# Used so param-derived tags aren't flagged as unsupported "EXTRA".
PARAM_JUSTIFY = {
    'increase_dmg': 'final-dmg', 'dr': 'dmg-reduction', 'crit': 'crit',
    'crit_dmg': 'crit', 'crit_dmg_imm': 'crit-resist', 'heal_rate': 'heal',
    'stun_rate': 'control', 'atk_per': 'atk', 'def_per': 'def', 'hp_per': 'hp',
    'arp_rate': 'def-ignore',
}


def mirror_text(m):
    parts = list(m.get('activationEffect') or [])
    sk = m.get('skill') or {}
    if sk.get('baseEffect'):
        parts.append(sk['baseEffect'])
    for s in sk.get('perStar') or []:
        if s.get('effectText'):
            parts.append(s['effectText'])
    return ' '.join(parts).lower()


def mirror_param_keys(m):
    keys = set()
    for s in (m.get('skill') or {}).get('perStar') or []:
        for kv in (s.get('effectParams') or '').split(','):
            k = kv.split('=', 1)[0].strip()
            if k:
                keys.add(k)
    return keys


def evidence_tags(text):
    return {tag for tag, pats in EVIDENCE.items()
            if any(re.search(p, text) for p in pats)}


def main():
    data = json.load(open(DATA))
    under_total, over_total, no_text = 0, 0, 0
    rows = []
    for m in data:
        text = mirror_text(m)
        if not text.strip():
            no_text += 1
            continue
        assigned = set(m.get('tags') or [])
        text_tags = evidence_tags(text)
        param_tags = {PARAM_JUSTIFY[k] for k in mirror_param_keys(m)
                      if k in PARAM_JUSTIFY}
        # UNDER: the text clearly implies a tag that wasn't assigned.
        under = sorted(text_tags - assigned)
        # OVER: a tag with no support from either the text or the machine params.
        over = sorted(assigned - text_tags - param_tags)
        if under or over:
            rows.append((m['name'], m['id'], m['quality'], under, over))
            under_total += len(under)
            over_total += len(over)

    rows.sort(key=lambda r: (-len(r[3]), r[1]))
    for name, mid, quality, under, over in rows:
        bits = []
        if under:
            bits.append(f'+MISSING {under}')
        if over:
            bits.append(f'-EXTRA {over}')
        print(f'{name or "?":<22} {mid} [{quality:<9}] {"  ".join(bits)}')

    print()
    print(f'mirrors with discrepancies: {len(rows)}/{len(data)} '
          f'| total missing: {under_total} | total extra: {over_total} '
          f'| text-less (skipped): {no_text}')
    # Non-zero exit when something needs attention, for easy scripting.
    return 1 if rows else 0


if __name__ == '__main__':
    sys.exit(main())
