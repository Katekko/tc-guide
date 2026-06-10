# TC Gameplay & Team-Building Mechanics

Knowledge base for the (future) `team-comp-expert` agent and the Team Comps guide.
Counterpart of `docs/mirror-mechanics.md`.

**Status: draft v0 (2026-06-09).** Sources, in order of authority:
1. **Decompiled game logic** (the client battle code; see §13 for the damage formula).
2. APK FlatBuffer configs in `apk-extract/bundle_flatbuffer/` (decoded with `tools/fbexplore.py`; table → file resolved via `bundle_flatbuffer-asset-index.json`)
3. In-game screenshots provided by the maintainer (deploy screen, hero detailed attributes, race-bonus tooltip, Destiny Star Gate)
4. Maintainer braindump (active player)
5. Discord player guides in `raw/split/` (`team-comp-guides.md`, `linked-ur-discussion.md`, …)

Items tagged **[VERIFY]** are plausible readings of the config data that still need an
in-game check before the guide states them as fact.

Game-data conventions: percentages are stored ×100 (`atk_per=1500` = +15% ATK).
Camp ids (`HeroCampDesCfg`): 1 = Holylight (圣辉), 2 = Arcane Web (秘网), 3 = Kindred (血族),
4 = Demonhunter (猎魔), 5 = Sanctuary (圣殿), 6 = Fiend (魔煞), 8 = Otherworld (异界).

---

## 1. Battle structure

- A team deploys **6 heroes** ("Deployed: 0/6" on the deploy screen).
- The battlefield is a hex grid; the player's side has 6 numbered slots chosen from a
  larger 10-position layout (`FormationCfg`: 6 formations, each a list of 6 slots out of
  positions 1–10). Positions group into lines (confirmed by maintainer):
  **slot 1 = frontline, slots 2–3 = midline, slots 4–6 = backline** — i.e. the default
  shape is 1 front / 2 mid / 3 back.
- Enemy formations use the same system; PvE waves can field different formations.
- Turn order: heroes have a visible **Speed** stat (e.g. Wu Kong 1440). Skills in hero
  data carry `releaseTurn` and `cooldown`, so combat is turn-based with speed-ordered
  action inside a round. **[VERIFY]** exact initiative rules (per-round re-sort? ties?).

## 2. Stats glossary (hero "Detailed Attribute" panel)

Base: HP, ATK, DEF, Speed.
Offense: Crit Rate, Crit DMG, DEF Ignore, Hit Rate, Effect Hit Rate, Lifesteal Rate,
P.DMG Boost, M.DMG Boost, Basic Attack DMG Boost, Active Skill DMG Boost,
Ultimate DMG Boost, **Final DMG** (multiplies everything; endgame accounts reach ~40%+),
PVP DMG Boost, PVE DMG Boost.
Defense: Crit Resist Rate, Crit DMG RED, Evasion Rate, Effect Resist Rate,
P.DMG RED, M.DMG RED, Basic Attack DMG RED, Active Skill DMG RED, Ultimate DMG RED,
**Final DMG RED**, PVP DMG RED, PVE DMG RED, Spirit Armor.
Sustain: Healing Boost (outgoing), Healed Boost (incoming).

Implication for comps: "Final DMG / Final DMG RED" and the PvP-specific pair are the
premium scaling stats; Effect Hit vs Effect Resist is the control-vs-tank axis.

## 3. Faction (Race) deploy bonus — same-faction stacking

In-game tooltip (exact values): deploying heroes of the same faction buffs **all** heroes:

| Same-faction count | ATK | DEF | HP | Final DMG |
|---|---|---|---|---|
| 2 | +8% | +5% | +10% | — |
| 3 | +10% | +7% | +15% | — |
| 4 | +13% | +9% | +20% | — |
| 5 | +16% | +11% | +25% | — |
| 6 | +18% | +13% | +30% | — |
| 6 × Otherworld | +20% | +15% | +30% | +15% |

**Otherworld heroes count as ANY faction** for this bonus (wildcard). Since all UR/UR+
heroes are Otherworld, the standard meta core "1 SSR+ carry + 5 URs" automatically hits
the 6-same-race tier of the carry's faction.

**Maintainer guidance — do NOT over-weight this bonus.** The guide must not lead
players into fielding weak heroes just to match factions: that builds "a trash team
only for the faction". The bonus is a sensible tiebreaker in the first days, but in
the long run hero quality and kit synergy (§10) always come first — and a proper
endgame core gets the bonus for free through the Otherworld wildcard anyway.

## 4. Faction counter (`BattleArrayRestraintCfg`)

When your hero's faction **counters** the target's: **Crit Rate +10%** and **50% chance
of a "Strong Hit": damage effect +30%**. When countered: Crit Rate −10% and 50% chance
of a "Weak Hit": −30%.

Counter edges (clean-parsed via `tools/extract_team_data.py` →
`assets/data/team/faction_counters.json`; in-game term: **"Strong Strike"**):
**Holylight > Kindred, Kindred > Arcane Web, Arcane Web > Demonhunter,
Demonhunter > Sanctuary, Sanctuary > Kindred.**
The wheel is intentionally asymmetric: Kindred is countered twice (Holylight and
Sanctuary) and **nothing counters Holylight**. Fiend (6) and Otherworld (8) appear in
**no** counter relation.

Maintainer could not locate a counter chart in the game UI; the config is our only
source and we accept it as-is. **Practical relevance is low**: endgame teams are mostly
UR/UR+ heroes, all Otherworld — meaning they neither counter nor get countered. That is
itself a guide-worthy point: an Otherworld core is immune to faction-counter swings,
while SSR+ carries (Renais = Sanctuary, Adele/Rose = Demonhunter) can still be
countered by the right enemy camp.

## 5. Bonds (two systems)

### 5a. Relationship bonds (`HeroRelationShipCfg`, 31 records)
- 16 **hero pairs**, each granting a single stat: `atk_per/def_per/hp_per = 1500` (+15%).
  Confirmed pairs include Ling + Ying Gou (+15% ATK), Lilith + Tinplate (+15% ATK),
  Kira + Heidi (+15% DEF), Orpheus + Sariel (+15% HP), Alucard + Sherry (+15% HP),
  Michael + Albert (+15% ATK).
- 15 **solo entries** (newer heroes, mostly UR/UR+: Wu Kong, Jeanne, Lucifer,
  Enchantress, Nyx, Nüwa, Gaia, Mars, Ananke, Venus…): +20% to +25% of one stat with
  no partner requirement (power-creep: new heroes get the bond built in).
- **Solo unlock (grade-gated, player-confirmed):** once a hero reaches **Anima 1★**,
  its pair bond activates even without the partner deployed. The constant `14` in
  every record is the grade-ladder index — position 14 of `assets/data/grades.json`'s
  23-step ladder is exactly Anima 1★. So pair bonds constrain team-building only for
  heroes below Anima 1★ (early/mid-game); at endgame grades they are free stats.

### 5b. Fetters (`FetterShowCfg` / `FetterAttrCfg`, 21 named bonds)
Named 2–3-hero bonds (e.g. 正邪两立 = Dark Tide + Wu Kong). Three levels each:
**+1% / +3% / +5% to ATK+DEF+HP** (unlock thresholds 5/7/9 — likely combined star
count of the members **[VERIFY]**). Small; a tiebreaker, not a comp driver.

## 6. UR Link system ("Link Upgrade" / Echo)

- In-game text: *"Otherworld Heroes can be linked to improve Level and Quality."*
- A linked hero **shares level and grade** (Opal 1–5, Anima 1–3, …) with the UR it
  links to — upgrade one, both rise.
- **Hard rule: the UR and the hero linked to it cannot be deployed in the same fight.**
- Discord: getting a UR to Genesis 5 needs ~11 copies; non-core heroes are still worth
  pulling as link fodder.
- `HeroEchoCfg` lists the link-capable roster (5 levels each, cost item 575): the five
  SSR+ meta carries (Adele, Rose, Renais, Alucard, Ling) + the Otherworld URs (Jeanne,
  Lucifer, Nyx, Nüwa, Mars, Venus, and id 65020 — a hero newer than our extracted
  roster; re-run extraction). **[VERIFY]** whether Echo = the Link feature or a separate
  resonance system.

## 7. Destiny Star Gate (`StarActivate*Cfg`)

Account-wide stat tree with **4 palaces** (East/South/West/North), each a column of
nodes (5 or 10 levels per node). Per `StarActivateLevelCfg` the four palaces cover:

| Palace group | Stats |
|---|---|
| Offense | ATK %, Crit Rate, Effect Hit |
| Defense | DEF %, Crit Resist, Healed Boost |
| Vitality | HP %, True DMG Reduction, Effect Resist |
| Finality (guardian) | Final DMG, Crit DMG, Ult/Skill DMG — and Final DMG RED, Crit DMG RED, Ult/Skill DMG RED |

Every 20 total palace levels unlocks a node skill tier (`StarActivateSkillCfg`, 5 tiers).

**Confirmed (maintainer):** only the **first** Star Gate gives the per-battle-line
buffs (the later gates/palaces are not lane-based). Its lane scoping, as labeled
in-game: backline = ATK + HP + Final DMG; midline = DEF + ATK (midline ATK > backline
ATK) + **Crit Rate**; frontline = highest DEF + HP + Final DMG RED. This is the data
behind the Discord rule **"crit-scaling DPS belong in the midline"** (only midline
gets Crit Rate), and why the frontline slot wants the tankiest unit. **[VERIFY]** how
the first gate's palace groups map to the three lines numerically, and what the later
gates grant instead — resolve during extraction.

## 8. Power suppression (`FightSuppressCfg`)

PvE modes apply damage scaling by power difference, with per-mode schemes: default,
Tower floors 1–200, Tower 201–800+, Campaign power suppression, and "no suppression".
Matters for guide framing ("out-power it" vs "out-comp it" content), not for comp choice.

## 9. Modes & lineups

- Saved lineups exist per mode (`LineupCfg`: campaign lineup, arena attack & defense
  lineups; up to 20 saved — `LineupBaseCfg`).
- Cross-server modes (`TimeAndSpaceLinkOpenCfg`): Forgotten Canyon, Time-Space Duel,
  Cross-server Points Race, Glory Race, and **Peak Duel which requires 3 teams**.
- Maintainer: **campaign is easy and is not the problem.** Players want **one constant
  team that performs everywhere**, because building two teams is too expensive.
  Multi-team modes (Peak Duel) are where roster depth eventually matters.

## 10. Kit-mechanic synergy — the PRIMARY comp driver

**Maintainer-confirmed:** heroes are paired for their **kits**, not their stat bonds.
Adele + Rose run together because both work the same mechanic, not for the bond; same
for Ling + Ying Gou, who "both work with infected".

Mining the named mechanics (`[Tag]`) in all extracted skill texts reveals four
**debuff-engine families**, each aligned with a faction and each led by one of the
SSR+ carries from the link roster (§6):

| Engine | Heroes with it in-kit | Carry | Faction alignment |
|---|---|---|---|
| **[Infect]** | Ling, Ying Gou, Orpheus, Kira, Tinplate, Heidi, Vineshade, Blazer, Ramesses, Lilith | Ling | Arcane Web (+ Lilith) |
| **[Bleed]** | Alucard, Sherry, Dracula, Bathory, Isabella, Selina, Valendine, Blackquill, Yin | Alucard | Kindred |
| **[Holy Seal]** | Renais, Michael, Aurora, Arthur, Albert, Aelia, Isaac, Luna | Renais | Holylight/Sanctuary ("light team") |
| **[Sigil]** | Adele, Rose, Garvin, Elegy, Mica, Uncle Ying, Zhiming | Adele (+Rose) | Demonhunter |

A "team core" is therefore a **mechanic engine**: stack appliers + exploiters of one
named debuff. Because engines align with factions, the same picks usually feed the
same-race deploy bonus (§3) — kit synergy and faction synergy reinforce each other.
Smaller mechanic clusters also exist ([Charm]: Enchantress + Venus; [Taunt]:
Ramesses + Tinplate; [ATK Down]: Ada/Bathory/Sariel) and some Soul Mirrors gate on
these debuffs (see `docs/mirror-mechanics.md` — e.g. [Infect]-gated mirrors), so the
engine choice cascades into mirror choices.

**Verified engine loops (from extracted kit text; buff *stacking resolution* is
server-side, but application/exploit logic is fully described in skills):**
- **[Infect] — applier→snowball.** Ying Gou is the bulk applier (4→6 stacks/cast at
  60% on mid/back); Ling is the exploiter: her Ultimate adds True DMG (120% ATK) to
  Infect targets, and she gains [Battle Will] per infected enemy (max 6/turn) →
  free Ultimate at 8 stacks, [Demonblade Domain] at 6, another Ultimate at 14. So the
  core wants *many enemies infected fast* to fuel Ling's free ultimates. Orpheus adds
  %Max-HP damage to Infect targets (a third exploiter).
- **[Bleed] — self-sustaining.** Alucard applies on a single low-DEF target (100%),
  gains [Bloodlust] per application, and re-hits ALL Bleed targets with [Vacuum Blade]
  each active turn; Sherry is the AoE applier (70% to all). Bleed spreads then Alucard
  rakes the whole bled side.
- **[Holy Seal] is really two layers.** Renais's *own* engine is **[Quash]**, not Holy
  Seal: her Awaken stacks Quash on every attack/counter and deals +25% ATK × Quash
  stacks, plus +30% Crit Rate vs Quash targets — a self-contained counter engine.
  Separately she *applies* [Holy Seal], which **Michael** exploits ([Apotheosis] per
  sealed enemy → cooldown refresh at 25, True DMG on his Ultimate). So a "Renais core"
  is Renais's Quash self-engine + Holy-Seal appliers feeding Michael.
- **[Sigil] — Demonhunter debuff.** Adele + Rose are the appliers (50–80% on
  multi-hit); exploiters like Uncle Ying gain [Amulet] off Sigil application. The
  Sigil *payoff* scaling lives on other Demonhunter heroes, so Adele/Rose are the
  applier shell of a broader Demonhunter board.

### Current meta snapshot (player + Discord, 2026-06)

- Standard core: **Renais (SSR+ Sanctuary) + 5 URs** (all Otherworld ⇒ full 6-race
  bonus via the wildcard rule; Otherworld URs are also outside the counter wheel).
- Variants seen in play: **Adele + Rose** (Sigil engine), **Ling + Ying Gou** (Infect
  engine — the +15% ATK bond is a side perk, not the reason).
- Tanks optional; Jeanne/Sariel/Garvin are the viable picks when wanted.
- Open question: are the Sigil/Infect/Bleed engines competitive with the Renais core
  at endgame, or availability-driven? (Web research / tier-list cross-check.)
- Players want **one constant general-purpose team** (§9) — the guide should rank
  engines by all-content performance, not per-mode.

## 11. Verification checklist (in-game)

Resolved 2026-06-09: ~~faction wheel~~ (config trusted; low relevance, §4),
~~Star Gate per-line scoping~~ (§7), ~~slot→line mapping~~ (§1),
~~pair-bond solo unlock~~ (grade-gated at Anima 1★, not time-gated, §5a).

Still open:
1. Is "Echo" the Link Upgrade feature or something else? (§6)
2. Turn order details: speed re-sort per round, ultimate charging rules (§1).
3. Numeric palace-id ↔ battle-line mapping in Star Gate configs (§7).

## 12. Pipeline TODO

- [x] `tools/extract_team_data.py` → `assets/data/team/{relationships,fetters,
      faction_counters,star_gate,formations}.json` (hero names resolved, zh→en via
      LanguageCfg; fetter display names have no en entry — kept as `nameZh`).
- [ ] Heroes 65011 and 65020 are referenced by Echo/Relationship tables but absent
      from this APK dump's `HeroCfg` — unreleased at dump time. **Needs a newer APK
      dump** to extract.
- [ ] Web research pass (wikis/Reddit/YouTube) for meta cores beyond Renais.
- [ ] `.claude/agents/team-comp-expert.md` once this doc passes verification.
- [ ] Curated comps → `assets/data/team_comps/` (en+pt) → `TeamCompsScreen`.

---

## 13. Damage formula (decrypted from game code) ✅

Source: `apk-extract/decoded-js/game.js`, class `BattleDamageCalculate.calDemage`
(module `BattleDamageCalculate`) + `DamageVo.getTotal`.

**Architecture caveat (verified):** combat is **server-authoritative**. The client
receives a battle report (`ON_BATTLE_REPORT` → `BattleReportVo`) whose
`total_hurts[].be_hurt` values are *read only* (19 reads, 0 client-side computations) and
replayed for the animation. The `calDemage` function below has **zero callers** in the
29.6 MB bundle — it is the client-side **damage preview/predictor** (skill tooltips,
expected-damage UI), kept in sync with the server's core math. So treat it as the
authoritative **shape** of the per-hit formula (DEF mitigation, crit, true damage,
vulnerable), but NOT as the complete pipeline: the final-multiplier layer (§ below) is
applied server-side and is not present in this client code.

**Per-hit calculation:**

```
# Effective defence after the attacker's DEF-ignore (armor_hit = flat, armor_hit_rate = %)
effDef      = (target.phy_def − attacker.armor_hit) × (1 − attacker.armor_hit_rate)

# Mitigation. l, c, d are global tuning scalars (default 1, settable via
# realDamageRate/injuryFreeRate1-3 — sourced from battle config).
defenceRate = effDef·l / (c·attacker.atk + effDef·d)
            = effDef / (attacker.atk + effDef)          # with defaults → classic DEF/(DEF+ATK)

ATKpwr      = (attackType == PHYSICAL ? attacker.atk : attacker.magic_attack) / subNum
                                                         # subNum = multi-hit divisor

base        = skillMultiplier × ATKpwr × (1 − defenceRate)
                                                         # skillMultiplier = skill % ÷ 1e4 (150% → 15000)
realTrue    = realDamageRate × attacker.holy_dmg × ATKpwr × (1 − defenceRate)
                                                         # "holy"/true-damage portion, always added
crit        = base × (attacker.base_crit_dmg + attacker.crit_dmg − target.crit_dmg_imm)

# Combine (DamageVo.getTotal):
total       = (crit > 0 ? realTrue + crit : base + realTrue + crit)
              × (1 + target.vulnerable × 1e-4)          # vulnerable = extra "受伤" amplification
```

**Roll formulas:**
```
critChance  = max(0, attacker.crit − target.decrit)     # rolled vs getRandom()
hitChance   = max(0, 0.95 × attacker.base_hit + (attacker.hit − target.dodge))
```

**Reading it for team-building:**
- Mitigation is `DEF / (DEF + ATK)` shaped → DEF has **diminishing returns vs high ATK**;
  stacking attacker ATK both raises `base` and shrinks the enemy's `defenceRate`, so ATK
  scales roughly quadratically against a fixed-DEF target. This is why DPS scaling
  outruns tank DEF, and why **DEF Ignore** (`armor_hit` / `armor_hit_rate`) is premium on
  carries — it removes enemy DEF *before* the ratio.
- **True/holy damage** (`holy_dmg`) is added on every hit and also passes through
  `(1 − defenceRate)` here — i.e. it is mitigated in this client path; confirm whether a
  later layer makes it ignore DEF. **[VERIFY]**
- On a crit, `base` is dropped and only `realTrue + crit` count — crit already contains
  the base term scaled by crit-dmg, so Crit DMG is a direct multiplier on the bulk of a hit.

**Stat fields confirmed present** (FlatBuffer hero-stat accessors, snake_case runtime
attrs): `atk, magic_attack, phy_def, armor_hit, armor_hit_rate, crit, base_crit_dmg,
crit_dmg, crit_dmg_imm, decrit, hit, base_hit, dodge, holy_dmg, vulnerable,
increase_dmg (Final DMG), dr (Final DMG RED), skill_dmg, holy_dmg, phy_hurt_dmg,
phy_hurt_imm, mag_hurt_dmg, mag_hurt_imm`.

**The "final multiplier" layer is server-side (not recoverable from this bundle).**
`calDemage` (the client preview) does not apply Final DMG (`increase_dmg`), Final DMG RED
(`dr`), the phys/mag-hurt boost/reduction pairs, basic/skill/ultimate dmg boosts, or
PVP/PVE dmg. Because actual `be_hurt` values come from the server report (see the
architecture caveat above), the **exact multiply-site and stacking order of these stats
lives on the server and cannot be read from the APK.** What the client DOES give us,
authoritatively, is: (a) the full list of stats that exist and their names, and (b) their
per-level/config values (FlatBuffer tables). The power-suppression layer
(`FightSuppressCfg`, §8) confirms Final DMG / DR are the hooks suppression modifies
(`attacker_increase_dmg / attacker_dr / def_increase_dmg / def_dr` per power-gap tier).

**Practical consequence for a quantitative team-ranking engine:** we can model the *core*
hit (DEF mitigation, crit, true dmg) exactly and treat the final-multiplier stats
additively-then-multiplicatively as a reasonable approximation, but exact damage parity
with the game would require either server data or empirical calibration from in-game
damage numbers. For *relative* team comparison (the guide's actual need) the core formula
+ named multipliers is more than enough.

**Source note:** the formula above was read from the decompiled client battle code
(`BattleDamageCalculate.calDemage` / `DamageVo.getTotal`). The decompilation tooling is
kept local and is not part of this repository.

---

## 14. Grade star-up cost (SSR+ → Opal 5)

Source: community "Character Star Up Guide" (Twilight Chronicles Discord, @reyy).
Captured in `assets/data/grade_costs.json`. Grade ladder itself = `HeroGradeCfg`
(23 steps; see `assets/data/grades.json` and [[hero-grade-evolution-system]]).

**Total to take one SSR+ unit to Opal 5★: 17 duplicate copies + 1 base = 18 copies.**
Per-tier duplicate counts (verified by sum: 2+2+3+10 = 17):

| Tier band | Dupes | Fodder (same-faction unless noted) |
|---|---|---|
| Dawn 1→5 (6★–10★) | 2 + base | 3× 5★ unit, 2× Dawn-1, 1× Dawn-3 |
| Eternal 1→5 (11★–15★) | 2 | 3× Dawn-1, 3× Dawn-3 |
| Anima 1→5 (16★–20★) ⚠ priciest | 3 | 3× Dawn-1, 2× Dawn-3, 2× Dawn-5, +1× any Dawn-3, 1× any Dawn-5 |
| Opal 1→5 (21★–25★) | 10 | 1× Dawn-1, 8× any-faction Dawn-5 |

**Faction rule — VERIFIED from game code** (`game.js`, grade-up fodder eligibility):
`fodder.grade == required.grade && (fodder.camp == hero.camp || !fodder.camp ||
consumeType == ALL_CAMP)`. So fodder must be the **upgraded hero's own faction** (or
faction-less), **except** the explicit **any-faction** (`ALL_CAMP`) requirement lines.
"Light Faction" in the source image only reflected its example unit being Light. Note
this is the **SSR+ grade** system — distinct from the **UR Genesis** system (§6, ~11
copies for Gen 5).
