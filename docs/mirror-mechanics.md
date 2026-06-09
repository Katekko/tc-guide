# Soul Mirror Mechanics & Recommendation Methodology

This is the authoritative knowledge base for reasoning about **Soul Mirrors** (魂镜,
internally the **NewRune** system) and producing **per-hero mirror tier rankings**.
The `mirror-expert` subagent (`.claude/agents/mirror-expert.md`) reads this file as
its source of truth. Keep it correct — accuracy of every hero's recommendation
depends on it.

---

## 1. What a Soul Mirror is

A Soul Mirror is an equippable item that buffs a hero. There are **69 mirrors**:

- **54 hero-linked mirrors** — each is bound to one specific hero (`heroId`) and
  themed after them (Yin, Renais, Jeanne, …). *Being bound to a hero is just
  flavor/source — a mirror can be equipped on ANY hero.* The bond does **not**
  restrict who can use it.
- **15 Anima mirrors** — standalone (not tied to a hero), generic crystal effects.

Each mirror has:

| Field | Meaning |
|---|---|
| `type` | `dps` / `def` / `control` / `support` — its role category |
| `quality` | `rare` < `epic` < `legendary` < `eternal` < `anima` (ascending power tier) |
| `skill.baseEffect` | the **Activate** (0★) effect text |
| `skill.perStar[]` | the effect at **1★ … 5★** (text scales, and may add new clauses) |
| `tags` | auto-derived mechanic tags (`crit`, `final-dmg`, `bleed`, `heal`, …) |
| `powerScale` | sum of per-star power contribution — a raw-strength proxy only |
| `baseStats` | flat hp/atk/def the mirror grants (small, common to all) |

> Note on `quality`: it loosely tracks rarity/ceiling, **not** desirability for a
> given hero. A `rare` mirror with a perfectly-matching mechanic can be S-tier for
> one hero while an `anima` mirror is C-tier for them. Quality is a **tiebreaker**,
> never the primary driver.

---

## 2. The equip mechanic (how players actually use mirrors)

- A hero opens their **Soul Mirror tab** and equips mirrors into slots.
- **Up to 8 slots per hero.** The number of unlocked slots scales with the
  hero's **evolution tier** (a low-tier hero has fewer than 8). So a full
  recommendation is effectively *"which 8 (and in what priority) should this
  hero run"*, plus the full ranking behind them for players at lower tiers or
  who lack the top picks.
- Because there are 8 slots, the goal is a **prioritized set**, not a single
  pick. The tier ranking IS that priority: fill slots top-down (S first, then A…).
- A mirror works on any hero; there is **no type-must-match-class hard rule** and
  **no faction-match bonus** in the data. Type and faction are *soft* signals for
  synergy reasoning, not constraints (see §4).

---

## 3. Star breakpoints — THE most important nuance

A mirror's value can change drastically with its star level. Many mirrors are a
boring stat-stick at low stars but **unlock a second, qualitatively different
clause at 3★** (sometimes 4★/5★). The recommendation MUST reason about *when* a
mirror becomes good, not just whether.

Canonical example — **Renais** (`dps`, `eternal`):

```
Activate: +3% Basic Atk DMG per Counter/Basic Atk, 1 turn, up to 12%.
1★:       up to 16%.
2★:       up to 20%.
3★:       up to 25%; + When killing an enemy, 40% chance to launch a Basic
          Attack against a random enemy.        ← NEW EFFECT UNLOCKS HERE
4★:       up to 30%; on-kill chance 60%.
5★:       up to 40%; on-kill chance 80%.
```

For a basic-attack / multi-hit hero, Renais is a *mediocre* stat boost at 0–2★ but
becomes **S-tier at 3★+** because the on-kill re-attack chains. The agent must say
this explicitly: *"B-tier until 3★, S-tier at 3★+ where the on-kill basic attack
unlocks."*

**Rule:** in the data, a per-star `effectText` containing a `;` that the
`baseEffect` does not is a strong signal of a new-clause breakpoint. Always read
the full `perStar` array, find the star where a new clause appears, and fold that
into the tier (often as a conditional tier like "A → S at 3★").

50 of 69 mirrors have non-trivial per-star text; ~10 have a true new-clause
breakpoint (Renais, Van Helsing, Alucard, Rose, Lilith, Lucifer, Mars, Gaia,
Scale-Splitting, Titan Strength, Warding Blessing — verify against live data).

---

## 4. How to read a hero's kit (the mechanic profile)

Before ranking mirrors, build the hero's **mechanic profile** from their data
(`assets/data/heroes/<id>.en.json` + the `roles` array). Read every skill slot's
`description` and classify the hero along these axes:

- **Primary role** — `heroClass` (1=Guard/tank, 2=Assassin, 3=Control, 4=Assault,
  5=Support) and `roles` (e.g. `AOE DMG`, `Single-target DMG`, `AOE Heal`).
- **Damage delivery** — does the kit lean on **basic attacks**, **the ultimate**,
  **skills**, **single-target**, or **AOE**?
- **Damage scaling levers** — does it **crit**? scale with **final DMG %**, **true
  DMG**, **DEF-ignore**, **ATK%**?
- **Damage-over-time / debuffs** — does it apply **bleed**, **infect**, **stun /
  control**, **effect-hit**?
- **Defensive / sustain** — does it **heal**, **shield**, **reduce DMG**, reflect,
  or scale off **HP / DEF**?
- **Tempo** — does it kill fast (favoring on-kill effects like Renais), or grind
  (favoring stacking/ramping effects)?

The mirror `tags` and effect text use the same vocabulary, so matching is direct:
a **crit** hero wants `crit` mirrors; a **basic-attack** hero wants `basic-atk`
mirrors; a **bleed** hero wants `bleed`; a **tank** wants `def`/`hp`/`dmg-reduction`/
`shield`; a **healer** wants `heal`/`shield`/`support`.

---

## 5. Ranking methodology

Score each of the 69 mirrors for the target hero, **in this priority order**:

1. **Mechanic synergy (primary).** Does the mirror's effect amplify what the hero
   actually does? A mirror that boosts a damage type / trigger the hero spams is
   far better than a generic stat. This is the dominant factor.
   - *Conditional synergy counts:* if synergy only appears at a star breakpoint,
     rank the mirror at its post-breakpoint value and annotate the star.
2. **Role / type match (primary).** A `dps` mirror on a DPS hero, `def`/`support`
   on a tank/healer. Off-role mirrors (e.g. a `support` heal mirror on a pure DPS)
   drop hard unless they carry a universally-useful clause.
3. **Effect magnitude & uptime (secondary).** Big numbers, easy trigger
   conditions, high uptime, low/no anti-synergy. A conditional effect the hero
   can't reliably trigger is worth less than its text implies.
4. **Quality & powerScale (tiebreaker only).** Between two similarly-synergistic
   mirrors, prefer the higher quality / powerScale and the better stat line.

### Tier definitions

| Tier | Meaning |
|---|---|
| **S** | Core BiS. Strong, reliable synergy with the hero's main win condition. Slot first. |
| **A** | Excellent. Strong synergy or a great effect with minor conditions; clear keeper. |
| **B** | Solid filler. Useful stats / partial synergy; fine while building toward better. |
| **C** | Marginal. Works but the hero gains little; only if slots are empty. |
| **D** | Weak. Off-role or near-dead effect for this hero; rarely worth a slot. |
| **F / Trash** | Anti-synergy or wasted — the effect does nothing for this hero (e.g. a basic-attack-on-kill mirror on a hero who never basic-attacks, or a heal mirror on a hero with no allies-scaling). |

Because each hero has 8 slots, **S+A should typically total ≥8** (the realistic
loadout); B is the bench. Be honest about D/F — the user explicitly wants to know
*why* a mirror is trash for this hero, not just that it ranks low.

### Anti-synergy is real — call it out

The most useful part of the ranking is explaining the **trash** tier. Examples of
genuine anti-synergy to name explicitly:

- A `basic-atk` mirror (Renais, Adele) on a hero who only casts skills/ultimate.
- A `crit` mirror (Aelia, Vivi) on a hero/build that doesn't crit.
- An `ultimate`-conditional mirror (Uncle Ying, Van Helsing) on a hero with a weak
  or rarely-used ultimate.
- A `heal`/`support` mirror on a solo-burst DPS who never benefits from the heal.
- A `bleed`/`infect` mirror on a hero who applies neither.

---

## 6. Output format

Produce BOTH, in this order:

### A) Human-readable tier list

For the target hero, lead with a 2–3 line **mechanic profile** (what the hero
does), then the full tier list. For each mirror give: name, type, quality, and a
**one-line reason**. Spell out star breakpoints (`"A → S at 3★"`). Group F/Trash
and give a shared + per-item reason for *why it's dead for this hero*.

### B) Machine-readable block (for filling the app later)

End with a fenced ```json block so recommendations can be ingested into the hero
data later. Schema:

```json
{
  "heroId": 55007,
  "heroName": "Jeanne",
  "profile": "Otherworld Guard; team-wide DMG distribution + AOE heal/DR. Wants survivability and team-support effects, not personal DPS scaling.",
  "ranking": [
    {
      "mirrorId": 72xxx,
      "name": "Jeanne",
      "tier": "S",
      "recommendedStar": 3,
      "reason": "DMG-reduction + heal + true-dmg matches her tank/support kit; her own themed mirror."
    }
  ]
}
```

- `tier` ∈ `S A B C D F`.
- `recommendedStar` = the star at which the mirror is worth using (the breakpoint),
  or `0` if useful immediately. Use `null` if star-agnostic.
- **Every mirror gets its own entry — all 69, no exceptions.** Do NOT compress the
  F-tier into shared entries in the JSON (the app renders one chip per entry). It
  is fine to *group* the reasoning in the human-readable list, but the JSON array
  must hold all 69 ids exactly once. Before emitting, load the catalog and verify
  the count is 69 with no duplicates or omissions.

### C) Write the file the app reads

Save the JSON object to **`assets/data/heroes/<heroId>.mirrors.<lang>.json`** — one
file per locale, mirroring the hero data convention (`<id>.en.json` / `<id>.pt.json`).
English (`.mirrors.en.json`) is authoritative; other locales are optional and the
app falls back to English when a locale file is missing. Only `profile` and each
`reason` are translated — `mirrorId`/`name`/`tier`/`recommendedStar` stay identical
across locales (keep the id set 1:1 with the English file).

The hero page (`HeroMirrorSection` → `HeroMirrorRepository`) loads
`<id>.mirrors.<lang>.json` by hero id + locale and renders the tier list; heroes
without any file fall back to the bonded-mirror hint. `assets/data/heroes/` is
already a bundled asset dir, but a **new** file requires a full `flutter run`
relaunch (not hot reload/restart) to enter the asset manifest.

---

## 7. Data sources (all live in this repo)

| Data | Path |
|---|---|
| All mirrors (effects, stars, tags, type, quality) | `assets/data/soul_mirrors/soul_mirrors.en.json` |
| Hero roster (id, slug, name, class, rarity, faction, roles) | `assets/data/heroes/index.json` |
| Per-hero kit (full skill descriptions) | `assets/data/heroes/<id>.en.json` |
| Shared evolution / tier ladder (slot-unlock context) | `assets/data/grades.json` |

The mirror extractor is `tools/extract_soul_mirrors.py`; hero extractor is
`tools/extract_hero.py`. The in-game integer "Rating" is **not** in the data
(`rating` is always null) — use `powerScale` + quality as the strength proxy.

---

## 7b. Localization (translating rankings)

Rankings are **authored prose**, not game strings — there is no official zh→en
source for them. So translation is a **separate step** from ranking: the
`mirror-expert` writes the authoritative `*.mirrors.en.json`; the
`mirror-translator` agent later produces `*.mirrors.<lang>.json` from it.

**Rules for any translation:**
- Translate **only** `profile` and each `reason`. Copy `mirrorId`, `name`,
  `tier`, `recommendedStar` **verbatim**. Keep the id set 1:1 with the English file.
- **Do NOT translate** these (keep the English word): **"mirror" / "mirrors"**
  (per game-owner: never "espelho/espelhos"), every **mirror proper name**
  (Frostglow, Nuwa, Garvin…), **"Ultimate"**, and the acronyms **HP, ATK, DEF,
  DoT, AoE, DPS, CC**.
- Also keep in English (established gaming terms with no good PT equivalent):
  **Lifesteal**, **buff/debuff**, **burst**, **stat stick**, **BiS**, **uptime**.
- Keep **skill / status proper names verbatim** (e.g. [Linked Fates] → can be
  rendered as [Destinos Entrelaçados] if a translation reads naturally, but the
  bracketed game-state names like [Charm], [Lust], [Obsession], Crimson Lotus,
  Soul Embers, Time Energy, Inferno Trigger may stay English — consistency
  within a hero's file matters more than direction).
- Use the glossary below for consistent terms across all heroes. (Seeded from
  Jeanne; the game-owner will refine — when a term changes, update it here and the
  translator picks it up on the next run.)

**PT (pt / pt_BR) glossary — seed:**

| English | Portuguese |
|---|---|
| Final DMG RED | Redução de Dano Final |
| Final DMG | Dano Final |
| Damage-Share (state) | (estado de) Divisão de Dano |
| Effect Resist | Resistência a Efeitos |
| Effect Hit (Rate) | Precisão de Efeitos |
| Crit / Crit Rate / Crit DMG | Crítico / Taxa Crítica / Dano Crítico |
| Crit DMG RED | Redução de Dano Crítico |
| True DMG | Dano Verdadeiro |
| DEF Ignore | Ignorar DEF |
| Heal / Healing Received | Cura / Cura Recebida |
| Shield / Spirit Shield | Escudo / Escudo Espiritual |
| Spirit Armor | Armadura Espiritual |
| Bleed | Sangramento |
| Infect / Infection | Infecção |
| single-target | alvo único |
| AOE / area | em área (AoE) |
| basic attack | ataque básico |
| on-kill / killing | ao abater |
| Lethal | Letal |
| Torment | Tormento |
| Fox Fire | Fogo de Raposa |
| tank / damage sink | tanque / absorvedora de dano |
| filler | preenchimento / curinga |
| uptime / buff | uptime / buff |
| Heal Reduction / Heal-Down | Redução de Cura |
| DEF Pen / DEF Penetration | Penetração de DEF |
| on-kill re-attack | re-ataque ao abater |
| glass cannon | canhão de vidro |
| bench (tier-list sense) | bancada |
| dispel | dissipar (buffs) |
| ramp / ramping | acumulação / acumular |

Note: the section title for the ranking is l10n key `heroMirrorRankingTitle`
(EN "Recommended Mirrors", PT "Mirrors recomendados" — "Mirrors" kept English).

---

## 8. Appendix — full mirror reference

Type / quality / bound hero / tags / first new-clause star breakpoint (best read
live from the JSON; this snapshot is for quick orientation).

| Mirror | Type | Quality | Bound hero | Tags | Notable star breakpoint |
|---|---|---|---|---|---|
| Arthur | control | legendary | Arthur | control | - |
| Baleful Omen | control | anima | Anima | final-dmg,control | - |
| Bathory | control | legendary | Bathory | control,effect-hit | - |
| Elegy | control | legendary | Elegy | crit,heal | - |
| Enchantress | control | rare | Enchantress | control,true-dmg,effect-hit | - |
| Lilith | control | eternal | Lilith | infect,single-target,true-dmg | 3*: 2nd effect |
| Sariel | control | legendary | Sariel | infect | - |
| Sherry | control | eternal | Sherry | bleed | - |
| Ying Gou | control | eternal | Ying Gou | infect | - |
| Albert | def | legendary | Albert | hp | - |
| Alluring Gaze | def | anima | Anima | effect-hit | - |
| Azmodan | def | legendary | Azmodan | bleed | - |
| Dark Tide | def | eternal | Dark Tide | hp | - |
| Dracula | def | eternal | Dracula | heal,hp | - |
| Elbera‘s Soul Mirror | def | rare | Elbella | heal,effect-hit | - |
| Eternal Stand | def | anima | Anima | dmg-reduction | - |
| Flame Dawn | def | anima | Anima | heal | - |
| Frankenstein | def | epic | Frankenstein | hp | - |
| Frostglow | def | anima | Anima | dmg-reduction | - |
| Gaia Soul Mirror | def | rare | Gaia | aoe,true-dmg,hp | 3*: 2nd effect |
| Galos | def | epic | Galos | def | - |
| Garvin | def | legendary | Garvin | dmg-reduction | - |
| Jacob | def | legendary | Jacob | final-dmg,dmg-reduction | - |
| Jeanne | def | rare | Jeanne | dmg-reduction,heal,true-dmg | - |
| Rock Elephant | def | anima | Anima | dmg-reduction | - |
| Tinplate | def | legendary | Tinplate | true-dmg | - |
| Titan Strength | def | anima | Anima | heal,shield | 3*: 2nd effect |
| Ada | dps | legendary | Ada | - | - |
| Adele | dps | eternal | Adele | crit,basic-atk | - |
| Aelia | dps | epic | Aelia | crit | - |
| Alucard | dps | eternal | Alucard | crit | 3*: 2nd effect |
| Ananke Soul Mirror | dps | rare | Ananke | final-dmg,true-dmg | - |
| Aurora | dps | legendary | Aurora | def-ignore | - |
| Daisy | dps | rare | Daisy | final-dmg,crit | - |
| Firmament | dps | anima | Anima | final-dmg | - |
| Hinata Inori | dps | rare | Hinata Inori | final-dmg,crit | - |
| Horde-Assault | dps | anima | Anima | aoe,single-target,true-dmg | - |
| Isabella | dps | legendary | Isabella | final-dmg,shield | - |
| Kira | dps | legendary | Kira | single-target | - |
| Lincoln | dps | epic | Lincoln | dmg-reduction,crit,crit-resist | - |
| Ling | dps | eternal | Ling | infect,true-dmg | - |
| Lucifer | dps | rare | Lucifer | heal,true-dmg | 3*: 2nd effect |
| Luna | dps | eternal | Luna | aoe | - |
| Mars Soul Mirror | dps | rare | Mars | crit,heal,true-dmg | 3*: 2nd effect |
| Michael | dps | eternal | Michael | final-dmg | - |
| Mister | dps | epic | Mister | atk | - |
| Night Depths | dps | rare | Night Depths | true-dmg | - |
| Nuwa Soul Mirror | dps | rare | Nüwa | final-dmg,control,effect-hit | - |
| Nyx Soul Mirror | dps | rare | Nyx | aoe,true-dmg | - |
| Renais | dps | eternal | Renais | basic-atk | 3*: 2nd effect |
| Rose | dps | eternal | Rose | final-dmg,basic-atk,ultimate | 3*: 2nd effect |
| Royal Awe | dps | anima | Anima | - | - |
| Scale-Splitting | dps | anima | Anima | crit,basic-atk,true-dmg | 3*: 2nd effect |
| Throat-Slitting | dps | anima | Anima | final-dmg | - |
| Uncle Ying | dps | legendary | Uncle Ying | ultimate | - |
| Valendine | dps | legendary | Valendine | single-target | - |
| Van Helsing | dps | legendary | Van Helsing | basic-atk,ultimate | 3*: 2nd effect |
| Vivi | dps | epic | Vivi | crit | - |
| Wasteward | dps | anima | Anima | final-dmg,basic-atk | - |
| Wukong | dps | rare | Wu Kong | true-dmg | - |
| Yin | dps | epic | Yin | final-dmg | - |
| Zhiming | dps | epic | Zhiming | dmg-reduction | - |
| Heidi | support | legendary | Heidi | heal,single-target | - |
| Mystic Bull | support | anima | Anima | shield | - |
| Orpheus | support | legendary | Orpheus | heal | - |
| Raphael | support | legendary | Raphael | effect-hit | - |
| Theresa | support | legendary | Theresa | heal | - |
| Venus | support | rare | Venus | dmg-reduction | - |
| Warding Blessing | support | anima | Anima | shield | 3*: 2nd effect |

