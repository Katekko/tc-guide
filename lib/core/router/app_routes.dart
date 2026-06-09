/// Canonical in-app route paths. Both the home tiles and the guide registry
/// reference these so navigation targets never drift apart.
abstract final class AppRoutes {
  /// Landing page.
  static const String home = '/';

  // Guide pages (kept identical to the previous Docusaurus URLs).
  static const String intro = '/docs/intro';
  static const String gettingStarted = '/docs/getting-started';
  static const String reroll = '/docs/getting-started/reroll';
  static const String starterCarry = '/docs/getting-started/starter-carry';
  static const String shopPriority = '/docs/resources/shop-priority';
  static const String spending = '/docs/resources/spending';
  static const String urIntroduction = '/docs/ur/introduction';
  static const String urPriority = '/docs/ur/priority';
  static const String urPlus = '/docs/ur/ur-plus';
  static const String nyx = '/docs/ur-plus/nyx';
  static const String stats = '/docs/gears-and-stats/stats';
  static const String gears = '/docs/gears-and-stats/gears';
  static const String soulMirrors = '/docs/beast-spirit/soul-mirrors';
  static const String teamComps = '/docs/team-comps';
  static const String tierList = '/docs/team-comps/tier-list';

  /// Heroes catalog: the browsable, filterable grid of every hero.
  static const String heroes = '/heroes';

  /// Per-hero page, keyed by a shareable slug (e.g. `/heroes/jeanne`).
  static const String heroBySlug = '/heroes/:name';

  /// Builds the concrete [heroBySlug] path for [slug] (e.g. `/heroes/jeanne`).
  static String heroPath(String slug) => '/heroes/$slug';

  /// Dev-only hero-rarity labelling tool (not linked from any nav).
  static const String heroLabelDev = '/dev/heroes-label';
}
