#!/usr/bin/env python3
"""Extract TC "Soul Mirror" (魂镜) data into clean per-mirror JSON (English).

The Soul Mirror system is internally the *NewRune* system. Each mirror is a
PropCfg item in the 72xxx range (f11 = quality tier code) whose star scaling
lives in NewRuneStarCfg and whose per-star activation/skill text lives in
SkillStudyCfg under the id formula  18 + <heroId(5)> + <level(1)>  (level 1 =
Activate, 2..6 = 1..5 star). Hero mirrors are bound to a HeroCfg hero (same
name); Anima mirrors (quality code 11) are standalone and use generic crystal
effects not stored as readable text.

Output: assets/data/soul_mirrors/soul_mirrors.en.json  (one array).

Usage: python3 tools/extract_soul_mirrors.py
"""
import struct, sys, json, os, re

BASE_DIR = 'apk-extract/bundle_flatbuffer/assets/assets/bundle_flatbuffer'
INDEX = 'apk-extract/bundle_flatbuffer/bundle_flatbuffer-asset-index.json'

def u16(b, o): return struct.unpack_from('<H', b, o)[0]
def u32(b, o): return struct.unpack_from('<I', b, o)[0]
def i32(b, o): return struct.unpack_from('<i', b, o)[0]

class Table:
    def __init__(self, buf, pos):
        self.buf, self.pos = buf, pos
        self.vt = pos - i32(buf, pos)
        self.vt_size = u16(buf, self.vt)
    def nfields(self):
        return (self.vt_size - 4) // 2
    def fpos(self, i):
        vo = self.vt + 4 + i * 2
        if vo + 2 > self.vt + self.vt_size:
            return None
        r = u16(self.buf, vo)
        return self.pos + r if r else None
    def s(self, i):
        fp = self.fpos(i)
        if fp is None: return None
        try:
            tg = fp + u32(self.buf, fp); ln = u32(self.buf, tg)
            if 0 <= ln < 8000 and tg + 4 + ln <= len(self.buf):
                txt = self.buf[tg+4:tg+4+ln].decode('utf-8', 'replace')
                if txt and sum(c.isprintable() or c in '\n\r\t' for c in txt)/len(txt) > 0.8:
                    return txt
        except Exception:
            pass
        return None
    def i(self, idx):
        fp = self.fpos(idx)
        return u32(self.buf, fp) if fp is not None else None

def native_for(logical):
    for x in json.load(open(INDEX)):
        if x.get('logicalPath') == logical:
            return os.path.join(BASE_DIR, x['nativeFiles'][0])
    raise KeyError(logical)

def load(logical):
    return open(native_for(logical), 'rb').read()

def records(buf):
    r = Table(buf, u32(buf, 0))
    fp = r.fpos(0); vp = fp + u32(buf, fp); n = u32(buf, vp); start = vp + 4
    for k in range(n):
        ep = start + k*4
        yield Table(buf, ep + u32(buf, ep))

# ---- translation zh -> en --------------------------------------------------
print('loading LanguageCfg...', file=sys.stderr)
ZH2EN = {}
for t in records(load('LanguageCfg')):
    zh, en = t.s(1), t.s(3)
    if zh and en:
        ZH2EN[zh] = en
def tr(zh):
    return ZH2EN.get(zh, zh) if zh else zh

# ---- quality / type code maps ----------------------------------------------
# Lowercase keys so the Flutter UI can map them to localized labels + colors.
# PropCfg f11 quality-tier code (the contiguous 72xxx blocks).
QUALITY = {3: 'epic', 4: 'legendary', 8: 'eternal', 11: 'anima', 14: 'rare'}
# Fallback: id // 100 block -> quality (used when a mirror has no PropCfg item).
QUALITY_BY_BLOCK = {720: 'epic', 721: 'legendary', 722: 'eternal',
                    723: 'anima', 724: 'rare'}
QCODE_BY_QUALITY = {v: k for k, v in QUALITY.items()}
# NewRuneBaseCfg f6 type code (fallback); PropCfg f9 string label is primary.
TYPE_CODE = {1: 'def', 2: 'dps', 3: 'control', 4: 'support'}
TYPE_LABEL = {  # PropCfg f9 (translated) -> canonical type key
    'DPS Type': 'dps', 'Defense Type': 'def',
    'Control Type': 'control', 'Support Type': 'support',
}

# ---- auto-tagging ----------------------------------------------------------
# Mechanic tags ("what does this mirror actually do") derived from the machine
# effect params and the readable skill text. Auto-only for now (no curation).
PARAM_TAG = {
    'increase_dmg': 'final-dmg', 'dr': 'dmg-reduction',
    'crit': 'crit', 'crit_dmg': 'crit', 'crit_dmg_imm': 'crit-resist',
    'heal_rate': 'heal', 'stun_rate': 'control',
    'atk_per': 'atk', 'def_per': 'def', 'hp_per': 'hp',
    'arp_rate': 'def-ignore',
    # Intentionally NOT mapped:
    #  stun_imm  -> stun *immunity* (defensive Effect Resist), not dealing
    #               control; already covered by the effect-hit text rule.
    #  atk_dmg / skill_dmg -> attack/skill *damage* %, covered by the basic-atk /
    #               single-target / ultimate text rules (not the ATK stat tag).
}
# (tag, regex) applied to the lowercased, combined skill text.
TEXT_TAG = [
    # "Final DMG" not followed by "RED" = a damage increase (Yin, Ananke, Jacob);
    # "Final DMG RED" is reduction and is caught by dmg-reduction instead.
    ('final-dmg', r'final d(?:mg|amage)(?! red)'),
    ('dmg-reduction', r'dmg red|final dmg red|reduce[sd]? .{0,25}(?:dmg|damage)'),
    ('crit', r'crit'),
    ('heal', r'\bheal|recover|revive|healing received'),
    ('shield', r'shield'),
    ('bleed', r'bleed'),
    ('infect', r'infect'),
    ('control', r'\bstun|\bcontrol\b|\[lethal\]'),
    ('aoe', r'area attack|\baoe\b|area damage|all enemies|distributed among all'),
    ('basic-atk', r'basic attack|\bbatk\b'),
    ('ultimate', r'ultimate'),
    ('single-target', r'single[ -](?:target|attack|skill|heal)'),
    ('true-dmg', r'true d(?:mg|amage)'),
    ('def-ignore', r'def ignore|ignore .{0,8}def'),
    ('effect-hit', r'effect (?:hit|resist)'),
]
# Stable display order for the emitted tag list.
TAG_ORDER = ['final-dmg', 'dmg-reduction', 'crit', 'crit-resist', 'heal',
             'shield', 'bleed', 'infect', 'control', 'aoe', 'basic-atk',
             'ultimate', 'single-target', 'true-dmg', 'def-ignore',
             'effect-hit', 'atk', 'def', 'hp']

def derive_tags(texts, raw_params):
    """Auto-derive mechanic tags from effect text + machine params."""
    tags = set()
    for p in raw_params:
        for kv in (p or '').split(','):
            key = kv.split('=', 1)[0].strip()
            if key in PARAM_TAG:
                tags.add(PARAM_TAG[key])
    blob = ' '.join(t for t in texts if t).lower()
    for tag, pat in TEXT_TAG:
        if re.search(pat, blob):
            tags.add(tag)
    return [t for t in TAG_ORDER if t in tags]

# ---- source tables ---------------------------------------------------------
print('loading PropCfg...', file=sys.stderr)
PROP = {t.i(0): t for t in records(load('PropCfg')) if t.i(0)}

print('loading HeroCfg...', file=sys.stderr)
# Build hero lookup by both English and Chinese name (full f2, short f42).
HERO_STATS = {}
HERO_NAME = {}            # heroId -> English short name
for t in records(load('HeroCfg')):
    h = t.i(0)
    if h is None: continue
    HERO_STATS[h] = {'hp': t.i(14), 'atk': t.i(15), 'def': t.i(16)}
    HERO_NAME[h] = tr(t.s(42)) or tr(t.s(2))
# ---- skill text table (SkillStudyCfg): id -> (name_en, desc_en) ------------
# Soul-mirror skill ids are 18 + <heroId(5)> + <level(1)> for hero mirrors and
# 1888 + <crystalType(2)> + <level(1)> for Anima (generic "Soul Crystal").
print('loading SkillStudyCfg...', file=sys.stderr)
SKILL = {}
for t in records(load('SkillStudyCfg')):
    sid = t.i(0)
    if sid is not None:
        SKILL[sid] = (tr(t.s(3)), tr(t.s(4)))

def skill_desc(skill_id):
    return SKILL.get(skill_id, (None, None))[1]

# ---- star scaling (NewRuneStarCfg) -----------------------------------------
# f1 = star (blank => Activate / star 0); f4 (string) = the per-star skill id
# (18+heroId+level for hero mirrors, 1888xx+level generic crystal for Anima);
# f9 = machine effect params incl 'powerdisplayscale' (rating contribution).
print('loading NewRuneStarCfg...', file=sys.stderr)
STARS = {}  # mirrorId -> list of {star, skillId, params, powerscale}
for t in records(load('NewRuneStarCfg')):
    mid = t.i(0)
    if mid is None:
        continue
    params = t.s(9) or ''
    star = t.i(1)            # None for the activate (0) row
    sk = t.s(4)
    skill_id = int(sk) if (sk and re.fullmatch(r'18\d{6}', sk)) else None
    pscale = None
    m = re.search(r'powerdisplayscale=(\d+)', params)
    if m:
        pscale = int(m.group(1))
    STARS.setdefault(mid, []).append({
        'star': 0 if star is None else star,
        'skillId': skill_id,
        'params': params,
        'powerscale': pscale,
    })
for mid in STARS:
    STARS[mid].sort(key=lambda r: r['star'])

def hero_from_skill(skill_id):
    """heroId embedded in a hero-mirror skill id (18 + heroId + level), or None
    for the generic Anima crystals (1888xx + level)."""
    if skill_id is None:
        return None
    s = str(skill_id)                       # 8 digits, '18' + 5-digit hero + level
    hid = int(s[2:7])
    return hid if hid in HERO_STATS else None

# ---- base-stat-per-level table (NewRuneAllLevelCfg, level 1 = mirror base) ---
print('loading NewRuneAllLevelCfg...', file=sys.stderr)
def parse_stat(s):
    d = {}
    for kv in (s or '').split(','):
        if '=' in kv:
            k, v = kv.split('=', 1)
            try: d[k.strip()] = int(v)
            except ValueError: pass
    return d
LEVEL1_STATS = None
for t in records(load('NewRuneAllLevelCfg')):
    if t.i(0) == 1:
        LEVEL1_STATS = parse_stat(t.s(1))   # {'hp':100,'atk':10,'def':3}
        break

# ---- build mirror list (NewRuneBaseCfg = the defined mirrors) ---------------
print('loading NewRuneBaseCfg...', file=sys.stderr)
mirrors = []
for base in records(load('NewRuneBaseCfg')):
    mid = base.i(0)
    if mid is None:
        continue
    prop = PROP.get(mid)
    name_zh = prop.s(1) if prop else None
    name_en = tr(name_zh) if name_zh else None
    star_rows = STARS.get(mid, [])

    # quality: PropCfg f11 code primary; id-block fallback when no PropCfg item.
    qcode = prop.i(11) if prop else None
    quality = QUALITY.get(qcode) or QUALITY_BY_BLOCK.get(mid // 100)
    if qcode is None:
        qcode = QCODE_BY_QUALITY.get(quality)
    is_anima = (quality == 'anima')
    is_rare = (quality == 'rare')

    # type: PropCfg f9 label primary, NewRuneBaseCfg f6 fallback
    type_label = tr(prop.s(9)) if prop else None
    mtype = TYPE_LABEL.get(type_label) or TYPE_CODE.get(base.i(6))

    # heroId: from the embedded per-star skill id (authoritative & universal).
    hero_id = None
    for row in star_rows:
        h = hero_from_skill(row['skillId'])
        if h:
            hero_id = h
            break
    # name fallback when PropCfg item is missing (use bound hero's name)
    if not name_en and hero_id is not None:
        for raw_fi in (HERO_NAME.get(hero_id),):
            if raw_fi:
                name_en = raw_fi

    # per-star skill text resolved via the embedded skill id (works for Anima
    # too: it yields the generic "Soul Crystal" text).
    per_star = []
    base_effect = None
    for row in star_rows:
        txt = skill_desc(row['skillId'])
        if row['star'] == 0:
            base_effect = txt
        else:
            per_star.append({
                'star': row['star'],
                'effectText': txt,             # readable (hero + anima crystals)
                'effectParams': row['params'], # machine params (e.g. increase_dmg=250)
            })

    # 'powerScale' = cumulative powerdisplayscale across stars (the per-star
    # rating *contribution* from NewRuneStarCfg). NOTE: the in-game "Rating"
    # integer (e.g. Yin 1500) is a computed combat-power score and is NOT stored
    # as a single field anywhere we found, so 'rating' is left null. powerScale
    # is the closest data-backed proxy and is exposed for ranking/auto-tagging.
    power_scale = sum(r['powerscale'] for r in star_rows if r['powerscale']) or None
    rating = None

    tags = derive_tags(
        [base_effect] + [s['effectText'] for s in per_star],
        [r['params'] for r in star_rows],
    )

    mirrors.append({
        'id': mid,
        'name': name_en,
        'heroId': hero_id,
        'type': mtype,
        'quality': quality,
        'qualityCode': qcode,
        'isAnima': is_anima,
        'isRare': is_rare,
        # activation effect = the level-1 ("Activate") skill text (hero mirrors)
        'activationEffect': [base_effect] if base_effect else [],
        'rating': rating,            # in-game power score; not in data (see note)
        'powerScale': power_scale,   # sum of per-star powerdisplayscale (proxy)
        'skill': {
            'baseEffect': base_effect,
            'perStar': per_star,
        },
        'baseStats': LEVEL1_STATS,    # mirror base stats (level 1, common per system)
        'tags': tags,                 # auto-derived mechanic tags
        # raw machine params per star, kept for transparency / future curation
        'rawStarParams': [r['params'] for r in star_rows],
    })

mirrors.sort(key=lambda m: m['id'])

out_dir = 'assets/data/soul_mirrors'
os.makedirs(out_dir, exist_ok=True)
out_path = os.path.join(out_dir, 'soul_mirrors.en.json')
with open(out_path, 'w') as fh:
    json.dump(mirrors, fh, ensure_ascii=False, indent=2)

# ---- report ----------------------------------------------------------------
hero_m = [m for m in mirrors if m['heroId']]
anima_m = [m for m in mirrors if m['isAnima']]
from collections import Counter
qc = Counter(m['quality'] for m in mirrors)
print(f'\nwrote {out_path}', file=sys.stderr)
print(f'total mirrors: {len(mirrors)} | hero-linked: {len(hero_m)} | '
      f'anima: {len(anima_m)} | quality: {dict(qc)}', file=sys.stderr)
unlinked = [m['name'] for m in mirrors if not m['heroId'] and not m['isAnima']]
if unlinked:
    print(f'WARNING unlinked non-anima mirrors: {unlinked}', file=sys.stderr)

if __name__ == '__main__' and '--print' in sys.argv:
    print(json.dumps(mirrors, ensure_ascii=False, indent=2))
