#!/usr/bin/env python3
"""Extract a TC hero into a game-faithful structure (English).

Mirrors the in-game hero detail screen:
  header (name/epithet/class/role/stats) + skill groups (Skills/Ultimate/Awaken/Genesis),
  each skill carrying its modal fields (type label, description, release turn, cooldown).

Usage: python3 tools/extract_hero.py 55007    # Jeanne
"""
import struct, sys, json, os

BASE_DIR = 'apk-extract/bundle_flatbuffer/assets/assets/bundle_flatbuffer'
INDEX = 'apk-extract/bundle_flatbuffer/bundle_flatbuffer-asset-index.json'

def u16(b, o): return struct.unpack_from('<H', b, o)[0]
def u32(b, o): return struct.unpack_from('<I', b, o)[0]
def i32(b, o): return struct.unpack_from('<i', b, o)[0]
def f32(b, o): return struct.unpack_from('<f', b, o)[0]

class Table:
    def __init__(self, buf, pos):
        self.buf, self.pos = buf, pos
        self.vt = pos - i32(buf, pos)
        self.vt_size = u16(buf, self.vt)
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

# ---- translation: zh -> en (LanguageCfg key = md5(zh)) ---------------------
print('loading LanguageCfg...', file=sys.stderr)
ZH2EN = {}
for t in records(load('LanguageCfg')):
    zh, en = t.s(1), t.s(3)
    if zh and en:
        ZH2EN[zh] = en
def tr(zh):
    return ZH2EN.get(zh, zh) if zh else zh

# ---- skill name table & per-skill release/cooldown (SkillCfg) --------------
print('loading SkillCfg...', file=sys.stderr)
SKILL = {}
for t in records(load('SkillCfg')):
    sid = t.i(0)
    if sid is not None:
        SKILL[sid] = t
def skill_timing(sid):
    t = SKILL.get(sid)
    if not t: return (None, None)
    return (t.i(6), t.i(7))  # (release turn, cooldown)

# ---- skill / talent nodes (names + descriptions) (SkillStudyCfg) -----------
print('loading SkillStudyCfg...', file=sys.stderr)
STUDY = list(records(load('SkillStudyCfg')))

# in-game tab each node type belongs to (f7 type code -> UI category)
CATEGORY = {
    'jineng':  'Skills',    # 绝技  (active "Feat")
    'bisha':   'Ultimate',  # 必杀技
    'juexing': 'Awaken',    # 觉醒
}
def category_of(node):
    code = node.s(7)
    if code in CATEGORY:
        return CATEGORY[code]
    name = node.s(3) or ''
    if name.startswith('创世'): return 'Genesis'
    if name.startswith('终焉'): return 'Final'
    if name.startswith('专属'): return 'Exclusive'
    if name.startswith('觉醒之力'): return 'Awakening Power'
    if '普攻' in name: return 'Basic'
    return 'Other'

# ---- pull the hero ---------------------------------------------------------
hero_id = int(sys.argv[1]) if len(sys.argv) > 1 else 55007
print('loading HeroCfg...', file=sys.stderr)
hero = next((t for t in records(load('HeroCfg')) if t.i(0) == hero_id), None)
if not hero:
    sys.exit(f'hero {hero_id} not found')

# raw IEEE754 growth multipliers live as int-encoded floats
def growth(idx):
    fp = hero.fpos(idx)
    return round(f32(hero.buf, fp), 4) if fp is not None else None

# collect this hero's nodes, bucketed by in-game category
buckets = {}
for node in STUDY:
    nid = node.i(0)
    # Canonical tier nodes are <hero_id><group><tier> (e.g. 6501441); deeper
    # level-up variants (65014417, 650146951…) carry extra digits — exclude them
    # so a slot's tier count stays correct (Awaken 4, Genesis 5).
    if nid is None or nid // 100 != hero_id:
        continue
    name_zh, desc_zh = node.s(3), node.s(4)
    if not (name_zh or desc_zh):
        continue
    buckets.setdefault(category_of(node), []).append(node)

def sorted_nodes(cat):
    return sorted(buckets.get(cat, []), key=lambda n: n.i(0))

def active_slot(key, slot, cat, type_label):
    """Skills/Ultimate: one active skill (lowest-id canonical node) + timing."""
    nodes = sorted_nodes(cat)
    if not nodes:
        return None
    base = nodes[0]
    rel, cd = skill_timing(base.i(0))
    return {
        'key': key,            # locale-independent slot id (for icon/color)
        'slot': slot,          # localized display label
        'name': tr(base.s(3)),
        'type': type_label,
        'description': tr(base.s(4)),
        'releaseTurn': rel,
        'cooldown': cd,
    }

def passive_slot(key, slot, cat, type_label, name=None):
    """Awaken/Genesis: a stack of tier effects shown together."""
    nodes = sorted_nodes(cat)
    if not nodes:
        return None
    return {
        'key': key,
        'slot': slot,
        'name': name or tr(nodes[0].s(3)),
        'type': type_label,
        'level': len(nodes),
        'effects': [
            {'tier': i + 1, 'name': tr(n.s(3)), 'description': tr(n.s(4))}
            for i, n in enumerate(nodes)
        ],
    }

slots = [s for s in [
    active_slot('skills', 'Skills', 'Skills', 'Feat'),
    active_slot('ultimate', 'Ultimate', 'Ultimate', 'Ultimate'),
    passive_slot('awaken', 'Awaken', 'Awaken', 'Awaken'),
    passive_slot('genesis', 'Genesis', 'Genesis', 'Genesis', name='Genesis'),
] if s]

# Class (career) enum from HeroCareerDesCfg: f4 -> name.
CAREER = {1: 'Guard', 2: 'Assassin', 3: 'Control', 4: 'Assault', 5: 'Support'}
stars = hero.i(5)                       # base star rating (5 for UR/UR+)
# Rarity isn't a localized string (sprite in-game); derive it. 6xxxx ids are UR+.
rarity = 'UR+' if hero_id // 10000 == 6 else \
    {5: 'UR', 4: 'SSR', 3: 'SR', 2: 'R'}.get(stars, 'N')

result = {
    'id': hero_id,
    'name': tr(hero.s(42)),            # short name shown in UI ("Jeanne")
    'fullName': tr(hero.s(2)),         # "God - Jeanne"
    'epithet': tr(hero.s(1)),          # "Glory Saintess"
    'heroClass': CAREER.get(hero.i(4), 'Universal'),
    'rarity': rarity,
    'stars': stars,
    'roles': [tr(hero.s(22)), tr(hero.s(23))],
    'bio': tr(hero.s(43)),
    'profile': {
        'height': tr(hero.s(44)),
        'illustrator': tr(hero.s(40)),
    },
    'baseStats': {                     # NOTE: field labels still being confirmed
        'hp': hero.i(14), 'atk': hero.i(15), 'def': hero.i(16), 'spd': hero.i(17),
    },
    'spineId': str(hero_id),
    'skillSlots': slots,
}

# English is the source-of-truth locale extracted from the game.
for out_path in (f'apk-extract/heroes_data/{hero_id}.en.json',
                 f'assets/data/heroes/{hero_id}.en.json'):
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, 'w') as fh:
        json.dump(result, fh, ensure_ascii=False, indent=2)
print(json.dumps(result, ensure_ascii=False, indent=2))
print(f'\nwrote assets/data/heroes/{hero_id}.en.json', file=sys.stderr)
