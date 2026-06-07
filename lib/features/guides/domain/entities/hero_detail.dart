import 'package:equatable/equatable.dart';

/// A hero's base combat stats, shown in the stat row of the detail screen.
class HeroStats extends Equatable {
  /// Creates a stat block.
  const HeroStats({
    required this.hp,
    required this.atk,
    required this.def,
    required this.spd,
  });

  /// Builds stats from the extracted JSON map.
  factory HeroStats.fromJson(Map<String, dynamic> json) => HeroStats(
        hp: json['hp'] as int,
        atk: json['atk'] as int,
        def: json['def'] as int,
        spd: json['spd'] as int,
      );

  /// Base HP.
  final int hp;

  /// Base ATK.
  final int atk;

  /// Base DEF.
  final int def;

  /// Base SPD.
  final int spd;

  @override
  List<Object?> get props => [hp, atk, def, spd];
}

/// One tier of a multi-level passive (an Awaken or Genesis effect).
class HeroSkillEffect extends Equatable {
  /// Creates a skill effect tier.
  const HeroSkillEffect({
    required this.tier,
    required this.name,
    required this.description,
  });

  /// Builds an effect tier from JSON.
  factory HeroSkillEffect.fromJson(Map<String, dynamic> json) =>
      HeroSkillEffect(
        tier: json['tier'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
      );

  /// 1-based tier index.
  final int tier;

  /// Tier name (e.g. "Genesis I").
  final String name;

  /// Tier description.
  final String description;

  @override
  List<Object?> get props => [tier, name, description];
}

/// One of the four in-game skill slots: Skills, Ultimate, Awaken, Genesis.
///
/// Active slots (Skills/Ultimate) carry a single [description] plus
/// [releaseTurn]/[cooldown]; passive slots (Awaken/Genesis) instead carry a
/// stack of [effects] and a [level].
class HeroSkillSlot extends Equatable {
  /// Creates a skill slot.
  const HeroSkillSlot({
    required this.key,
    required this.slot,
    required this.name,
    required this.type,
    this.description,
    this.releaseTurn,
    this.cooldown,
    this.level,
    this.effects = const [],
  });

  /// Builds a slot from JSON, handling both active and passive shapes.
  factory HeroSkillSlot.fromJson(Map<String, dynamic> json) => HeroSkillSlot(
        key: json['key'] as String,
        slot: json['slot'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        description: json['description'] as String?,
        releaseTurn: json['releaseTurn'] as int?,
        cooldown: json['cooldown'] as int?,
        level: json['level'] as int?,
        effects: (json['effects'] as List<dynamic>? ?? [])
            .map((e) => HeroSkillEffect.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Locale-independent slot id ("skills", "ultimate", "awaken", "genesis"),
  /// used for icon/color lookup.
  final String key;

  /// Localized slot display label ("Skills" / "Habilidades").
  final String slot;

  /// Skill display name.
  final String name;

  /// Type label shown in the modal (e.g. "Feat", "Ultimate").
  final String type;

  /// Single description (active slots only).
  final String? description;

  /// Earliest turn the skill can be cast (active slots only).
  final int? releaseTurn;

  /// Cooldown in turns (active slots only).
  final int? cooldown;

  /// Number of unlocked tiers (passive slots only).
  final int? level;

  /// Tier effects (passive slots only).
  final List<HeroSkillEffect> effects;

  /// Whether this slot is a multi-tier passive (Awaken/Genesis).
  bool get isPassive => effects.isNotEmpty;

  @override
  List<Object?> get props =>
      [key, slot, name, type, description, releaseTurn, cooldown, level, effects];
}

/// A fully-detailed hero, mirroring the in-game hero detail screen.
class HeroDetail extends Equatable {
  /// Creates a hero detail.
  const HeroDetail({
    required this.id,
    required this.name,
    required this.fullName,
    required this.epithet,
    required this.heroClass,
    required this.rarity,
    required this.stars,
    required this.roles,
    required this.bio,
    required this.height,
    required this.illustrator,
    required this.baseStats,
    required this.spineId,
    required this.skillSlots,
  });

  /// Builds a hero from the extracted JSON map.
  factory HeroDetail.fromJson(Map<String, dynamic> json) => HeroDetail(
        id: json['id'] as int,
        name: json['name'] as String,
        fullName: json['fullName'] as String,
        epithet: json['epithet'] as String,
        heroClass: json['heroClass'] as String,
        rarity: json['rarity'] as String,
        stars: json['stars'] as int,
        roles:
            (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
        bio: json['bio'] as String,
        height: (json['profile'] as Map<String, dynamic>)['height'] as String,
        illustrator:
            (json['profile'] as Map<String, dynamic>)['illustrator'] as String,
        baseStats:
            HeroStats.fromJson(json['baseStats'] as Map<String, dynamic>),
        spineId: json['spineId'] as String,
        skillSlots: (json['skillSlots'] as List<dynamic>)
            .map((e) => HeroSkillSlot.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// TC hero id (e.g. 55007).
  final int id;

  /// Short display name ("Jeanne").
  final String name;

  /// Full name ("God - Jeanne").
  final String fullName;

  /// Epithet ("Glory Saintess").
  final String epithet;

  /// Class ("Guard", "Assassin", …).
  final String heroClass;

  /// Rarity tier ("UR").
  final String rarity;

  /// Star count.
  final int stars;

  /// Role tags (e.g. "AOE DMG RED", "AOE Heal").
  final List<String> roles;

  /// Lore biography (may contain `<br/>` and `<color=#hex>` tags).
  final String bio;

  /// Height string (e.g. "175 cm").
  final String height;

  /// Illustrator name.
  final String illustrator;

  /// Base combat stats.
  final HeroStats baseStats;

  /// Spine animation id for [HeroSpineView].
  final String spineId;

  /// The four in-game skill slots.
  final List<HeroSkillSlot> skillSlots;

  @override
  List<Object?> get props => [
        id,
        name,
        fullName,
        epithet,
        heroClass,
        rarity,
        stars,
        roles,
        bio,
        height,
        illustrator,
        baseStats,
        spineId,
        skillSlots,
      ];
}
