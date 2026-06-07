#!/usr/bin/env python3
"""Extract the shared hero evolution ladder into assets/data/grades.json.

The ladder (HeroGradeCfg) is the same for every hero: Rare/Epic/Legend then
Dawn/Eternal/Anima/Opal each in 1-5 stars, with a per-grade level cap. Tier
names come from LanguageCfg. This is the backbone for the grade selector.
"""
import sys, json, os
sys.argv = ['x']

# reuse the reader + translator from extract_hero.py
exec(open(os.path.join(os.path.dirname(__file__), 'extract_hero.py')).read()
     .split("# ---- skill name")[0])

# Tier grouping by HeroGradeCfg.f7 (tier id). Order matters for the ladder.
TIER_EN = {
    '稀有': 'Rare', '史诗': 'Epic', '传说': 'Legend',
    '曙光': 'Dawn', '永恒': 'Eternal', '原魂': 'Anima', '幻彩': 'Opal',
}

def split_name(zh):
    """'原魂2星' -> ('Anima', 2); '稀有' -> ('Rare', 0)."""
    import re
    m = re.match(r'^(.*?)(\d+)星$', zh or '')
    if m:
        return TIER_EN.get(m.group(1), tr(m.group(1))), int(m.group(2))
    return TIER_EN.get(zh, tr(zh)), 0

ladder = []
for t in records(load('HeroGradeCfg')):
    name_zh = t.s(6)
    if not name_zh:
        continue
    tier, star = split_name(name_zh)
    ladder.append({
        'tier': tier,
        'star': star,
        'levelCap': t.i(5),
        'label': f'{tier} {star}★' if star else tier,
    })

# The Awaken (passive) skill is the only slot the grade tier upgrades. Per the
# game it unlocks at Dawn 4★ and levels at Eternal 1★ / Eternal 3★ / Anima 1★.
# Stored as ladder indices so the UI can map a grade -> awaken level.
AWAKEN_UNLOCK = [('Dawn', 4), ('Eternal', 1), ('Eternal', 3), ('Anima', 1)]
def grade_index(tier, star):
    return next(i for i, g in enumerate(ladder)
               if g['tier'] == tier and g['star'] == star)
awaken_unlock = [grade_index(t, s) for t, s in AWAKEN_UNLOCK]

result = {'ladder': ladder, 'awakenUnlock': awaken_unlock}
out = 'assets/data/grades.json'
os.makedirs(os.path.dirname(out), exist_ok=True)
with open(out, 'w') as fh:
    json.dump(result, fh, ensure_ascii=False, indent=2)
print(json.dumps(result, ensure_ascii=False, indent=2))
print(f'\nwrote {out} ({len(ladder)} grades)', file=sys.stderr)
