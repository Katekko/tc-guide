#!/usr/bin/env python3
"""Extract team-building config tables into assets/data/team/ (English).

Covers the systems documented in docs/gameplay-mechanics.md:
  relationships.json    HeroRelationShipCfg   pair/solo stat bonds
  fetters.json          FetterShowCfg+AttrCfg named 2-3 hero bonds, 3 levels
  faction_counters.json BattleArrayRestraintCfg camp counter wheel
  star_gate.json        StarActivateLevelCfg+SkillCfg Destiny Star Gate palaces
  formations.json       FormationCfg          6-of-10 slot layouts

Usage: python3 tools/extract_team_data.py
"""
import struct, sys, json, os, re

BASE_DIR = 'apk-extract/bundle_flatbuffer/assets/assets/bundle_flatbuffer'
INDEX = 'apk-extract/bundle_flatbuffer/bundle_flatbuffer-asset-index.json'
OUT_DIR = 'assets/data/team'

def u16(b, o): return struct.unpack_from('<H', b, o)[0]
def u32(b, o): return struct.unpack_from('<I', b, o)[0]
def i32(b, o): return struct.unpack_from('<i', b, o)[0]

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

# ---- translation: zh -> en --------------------------------------------------
print('loading LanguageCfg...', file=sys.stderr)
ZH2EN = {}
for t in records(load('LanguageCfg')):
    zh, en = t.s(1), t.s(3)
    if zh and en:
        ZH2EN[zh] = en
def tr(zh):
    return ZH2EN.get(zh, zh) if zh else zh

# ---- hero id -> display name (same derivation as extract_hero.py) ----------
print('loading HeroCfg...', file=sys.stderr)
HERO_NAME = {}
for t in records(load('HeroCfg')):
    hid = t.i(0)
    if hid is None:
        continue
    full = tr(t.s(2)) or ''
    name = re.sub(r'^[^-]+ - ', '', full).strip() if ' - ' in full else full.strip()
    HERO_NAME[hid] = name or tr(t.s(42)) or str(hid)
def hero_name(hid):
    return HERO_NAME.get(hid, str(hid))

CAMP = {1: 'Holylight', 2: 'Arcane Web', 3: 'Kindred', 4: 'Demonhunter',
        5: 'Sanctuary', 6: 'Fiend', 8: 'Otherworld'}

def parse_attrs(s):
    """'atk_per=1500,hp_per=300' -> [{'stat','value','percent'}] (values are x100)."""
    out = []
    for part in (s or '').split(','):
        if '=' not in part:
            continue
        k, v = part.split('=', 1)
        try:
            v = int(v)
        except ValueError:
            continue
        out.append({'stat': k.strip(), 'value': v, 'percent': v / 100})
    return out

# ---- relationships (HeroRelationShipCfg) ------------------------------------
relationships = []
for t in records(load('HeroRelationShipCfg')):
    ids = [int(x) for x in (t.s(1) or '').split(',') if x.strip().isdigit()]
    if not ids:
        continue
    relationships.append({
        'id': t.i(0),
        'heroIds': ids,
        'heroNames': [hero_name(h) for h in ids],
        'kind': 'pair' if len(ids) > 1 else 'solo',
        'bonus': parse_attrs(t.s(4)),
        # grade-ladder index at which the bond activates without the partner
        # (14 = Anima 1*, player-confirmed; docs/gameplay-mechanics.md §5a)
        'soloUnlockGradeIndex': t.i(3),
        'soloUnlockGrade': 'Anima 1★' if t.i(3) == 14 else None,
    })

# ---- fetters (FetterShowCfg members + FetterAttrCfg levels) -----------------
fetter_levels = {}
for t in records(load('FetterAttrCfg')):
    fid = t.i(0)
    fetter_levels.setdefault(fid, []).append({
        'level': t.i(1),
        'unlockThreshold': t.i(2),
        'bonus': parse_attrs(t.s(3)),
    })
fetters = []
for t in records(load('FetterShowCfg')):
    n = t.i(2) or 0
    ids = [h for h in (t.i(5 + 4 * k) for k in range(n)) if h]
    name_zh = t.s(1)
    fetters.append({
        'id': t.i(0),
        # fetter display names have no LanguageCfg entry; en name pending
        # (the feature is called "Fateful Bond" in the en client)
        'name': tr(name_zh) if tr(name_zh) != name_zh else None,
        'nameZh': name_zh,
        'heroIds': ids,
        'heroNames': [hero_name(h) for h in ids],
        'levels': sorted(fetter_levels.get(t.i(0), []), key=lambda x: x['level']),
    })

# ---- faction counters (BattleArrayRestraintCfg) -----------------------------
counters = []
for t in records(load('BattleArrayRestraintCfg')):
    counters.append({
        'camp': t.i(0),
        'campName': CAMP.get(t.i(0)),
        'versusCamp': t.i(1),
        'versusCampName': CAMP.get(t.i(1)),
        'relation': {1: 'counters', 2: 'countered_by'}.get(t.i(2)),
        'critMod': parse_attrs(t.s(3)),
        'triggerChance': (t.i(4) if t.i(2) == 1 else t.i(6)),
        'damageEffect': (t.i(5) if t.i(2) == 1 else t.i(7)),
        'description': tr(t.s(8)),
    })

# ---- Destiny Star Gate (StarActivateLevelCfg + StarActivateSkillCfg) -------
gate_nodes = []
for t in records(load('StarActivateLevelCfg')):
    gate_nodes.append({
        'palace': t.i(1),
        'subgroup': t.i(2),
        'statIndex': t.i(3),
        'statKey': t.s(5),
        'nameZh': t.s(7),
        'name': tr(t.s(7)),
        'maxLevel': t.i(4),
        # raw numeric fields pending semantics (per-level value / cost?)
        '_f11': t.i(11), '_f12': t.i(12),
    })
gate_skills = []
for t in records(load('StarActivateSkillCfg')):
    gate_skills.append({
        'palace': t.i(0),
        'nodeCode': t.i(1),
        'totalLevelRequired': t.i(2),
        'tier': t.i(3),
        'skillId': t.i(4),
    })

# ---- formations (FormationCfg) ----------------------------------------------
formations = []
for t in records(load('FormationCfg')):
    slots = [int(x) for x in (t.s(3) or '').split(',') if x.strip().isdigit()]
    formations.append({'id': t.i(0), 'slots': slots})

# ---- write -------------------------------------------------------------------
os.makedirs(OUT_DIR, exist_ok=True)
outputs = {
    'relationships.json': relationships,
    'fetters.json': fetters,
    'faction_counters.json': counters,
    'star_gate.json': {'nodes': gate_nodes, 'nodeSkills': gate_skills},
    'formations.json': formations,
}
for fname, data in outputs.items():
    path = os.path.join(OUT_DIR, fname)
    with open(path, 'w') as fh:
        json.dump(data, fh, ensure_ascii=False, indent=2)
    n = len(data['nodes']) if isinstance(data, dict) else len(data)
    print(f'wrote {path} ({n} records)', file=sys.stderr)
