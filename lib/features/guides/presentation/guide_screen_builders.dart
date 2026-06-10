import 'package:flutter/widgets.dart';

import 'package:tc_flutter_web/core/router/app_routes.dart';

import 'screens/gears_screen.dart';
import 'screens/getting_started_screen.dart';
import 'screens/heroes_screen.dart';
import 'screens/heroes_star_up_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/nyx_screen.dart';
import 'screens/reroll_screen.dart';
import 'screens/shop_priority_screen.dart';
import 'screens/soul_mirrors_screen.dart';
import 'screens/spending_screen.dart';
import 'screens/starter_carry_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/team_comps_screen.dart';
import 'screens/tier_list_screen.dart';
import 'screens/ur_introduction_screen.dart';
import 'screens/ur_plus_screen.dart';
import 'screens/ur_priority_screen.dart';

/// The single source of truth mapping each guide route to its screen builder.
///
/// The router builds one [GoRoute]-equivalent per entry, and a test asserts
/// these keys match the navigation tree exposed by `GuidesRepository`.
const Map<String, WidgetBuilder> guideScreenBuilders = {
  AppRoutes.intro: _intro,
  AppRoutes.gettingStarted: _gettingStarted,
  AppRoutes.reroll: _reroll,
  AppRoutes.starterCarry: _starterCarry,
  AppRoutes.shopPriority: _shopPriority,
  AppRoutes.spending: _spending,
  AppRoutes.urIntroduction: _urIntroduction,
  AppRoutes.urPriority: _urPriority,
  AppRoutes.urPlus: _urPlus,
  AppRoutes.nyx: _nyx,
  AppRoutes.stats: _stats,
  AppRoutes.gears: _gears,
  AppRoutes.soulMirrors: _soulMirrors,
  AppRoutes.teamComps: _teamComps,
  AppRoutes.tierList: _tierList,
  AppRoutes.heroes: _heroes,
  AppRoutes.heroesStarUp: _heroesStarUp,
};

Widget _intro(BuildContext context) => const IntroScreen();
Widget _gettingStarted(BuildContext context) => const GettingStartedScreen();
Widget _reroll(BuildContext context) => const RerollScreen();
Widget _starterCarry(BuildContext context) => const StarterCarryScreen();
Widget _shopPriority(BuildContext context) => const ShopPriorityScreen();
Widget _spending(BuildContext context) => const SpendingScreen();
Widget _urIntroduction(BuildContext context) => const UrIntroductionScreen();
Widget _urPriority(BuildContext context) => const UrPriorityScreen();
Widget _urPlus(BuildContext context) => const UrPlusScreen();
Widget _nyx(BuildContext context) => const NyxScreen();
Widget _stats(BuildContext context) => const StatsScreen();
Widget _gears(BuildContext context) => const GearsScreen();
Widget _soulMirrors(BuildContext context) => const SoulMirrorsScreen();
Widget _teamComps(BuildContext context) => const TeamCompsScreen();
Widget _tierList(BuildContext context) => const TierListScreen();
Widget _heroes(BuildContext context) => const HeroesScreen();
Widget _heroesStarUp(BuildContext context) => const HeroesStarUpScreen();
