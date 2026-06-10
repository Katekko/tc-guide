import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Twilight Chronicle Guides'**
  String get appTitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Structured Twilight Chronicle community guides'**
  String get appDescription;

  /// No description provided for @heroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Community Guide Dashboard'**
  String get heroEyebrow;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Structured progression, hero, team, gear, and currency guides for Twilight Chronicle.'**
  String get heroSubtitle;

  /// No description provided for @ctaStartHere.
  ///
  /// In en, this message translates to:
  /// **'Start Here'**
  String get ctaStartHere;

  /// No description provided for @ctaUrGuide.
  ///
  /// In en, this message translates to:
  /// **'UR Guide'**
  String get ctaUrGuide;

  /// No description provided for @ctaTeamComps.
  ///
  /// In en, this message translates to:
  /// **'Team Comps'**
  String get ctaTeamComps;

  /// No description provided for @recommendedStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended Start'**
  String get recommendedStartTitle;

  /// No description provided for @recommendedStartText.
  ///
  /// In en, this message translates to:
  /// **'Follow this route first if you are setting up a new account or cleaning up early progression.'**
  String get recommendedStartText;

  /// No description provided for @starterRerollTitle.
  ///
  /// In en, this message translates to:
  /// **'Reroll'**
  String get starterRerollTitle;

  /// No description provided for @starterRerollText.
  ///
  /// In en, this message translates to:
  /// **'Start with a strong SSR+ carry instead of spending weeks fixing the account.'**
  String get starterRerollText;

  /// No description provided for @starterCarryTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a Carry'**
  String get starterCarryTitle;

  /// No description provided for @starterCarryText.
  ///
  /// In en, this message translates to:
  /// **'Renais, Adele, and Ling are the current starter-route anchors in the notes.'**
  String get starterCarryText;

  /// No description provided for @starterSpendTitle.
  ///
  /// In en, this message translates to:
  /// **'Spend Cleanly'**
  String get starterSpendTitle;

  /// No description provided for @starterSpendText.
  ///
  /// In en, this message translates to:
  /// **'Use gems and shop buys where they move progression instead of noise.'**
  String get starterSpendText;

  /// No description provided for @starterUrTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan UR Pulls'**
  String get starterUrTitle;

  /// No description provided for @starterUrText.
  ///
  /// In en, this message translates to:
  /// **'Avoid scattering UR resources before the account has a clear direction.'**
  String get starterUrText;

  /// No description provided for @featuredHeroesTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured Heroes'**
  String get featuredHeroesTitle;

  /// No description provided for @featuredHeroesText.
  ///
  /// In en, this message translates to:
  /// **'Fast links for hero names already used in the guide text.'**
  String get featuredHeroesText;

  /// No description provided for @roleStarterCarry.
  ///
  /// In en, this message translates to:
  /// **'Starter Carry'**
  String get roleStarterCarry;

  /// No description provided for @roleUrGuide.
  ///
  /// In en, this message translates to:
  /// **'UR Guide'**
  String get roleUrGuide;

  /// No description provided for @guideSectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Guide Sections'**
  String get guideSectionsTitle;

  /// No description provided for @guideSectionsText.
  ///
  /// In en, this message translates to:
  /// **'Use these sections when you already know what system you need to check.'**
  String get guideSectionsText;

  /// No description provided for @guideGettingStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get guideGettingStartedTitle;

  /// No description provided for @guideGettingStartedText.
  ///
  /// In en, this message translates to:
  /// **'Rerolling, starter carry choices, and the first route through early progression.'**
  String get guideGettingStartedText;

  /// No description provided for @guideResourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get guideResourcesTitle;

  /// No description provided for @guideResourcesText.
  ///
  /// In en, this message translates to:
  /// **'Shop priorities, spending notes, and where to avoid wasting scarce currency.'**
  String get guideResourcesText;

  /// No description provided for @guideUrTitle.
  ///
  /// In en, this message translates to:
  /// **'UR and UR+'**
  String get guideUrTitle;

  /// No description provided for @guideUrText.
  ///
  /// In en, this message translates to:
  /// **'UR priorities, hero-specific notes, and long-term upgrade planning.'**
  String get guideUrText;

  /// No description provided for @guideGearTitle.
  ///
  /// In en, this message translates to:
  /// **'Gear and Stats'**
  String get guideGearTitle;

  /// No description provided for @guideGearText.
  ///
  /// In en, this message translates to:
  /// **'Stat targets, gear systems, and upgrade choices for damage and survivability.'**
  String get guideGearText;

  /// No description provided for @guideBeastTitle.
  ///
  /// In en, this message translates to:
  /// **'Beast Spirit'**
  String get guideBeastTitle;

  /// No description provided for @guideBeastText.
  ///
  /// In en, this message translates to:
  /// **'Soul mirror and beast spirit notes for common team paths.'**
  String get guideBeastText;

  /// No description provided for @guideTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Team Comps'**
  String get guideTeamTitle;

  /// No description provided for @guideTeamText.
  ///
  /// In en, this message translates to:
  /// **'Team-building notes, tier-list material, and formation guidance.'**
  String get guideTeamText;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Adapted from credited guide material and maintained separately on this site.'**
  String get note;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get backHome;

  /// No description provided for @startHereEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Start Here'**
  String get startHereEyebrow;

  /// No description provided for @startHereTitle.
  ///
  /// In en, this message translates to:
  /// **'New Player Guide'**
  String get startHereTitle;

  /// No description provided for @startHereIntro.
  ///
  /// In en, this message translates to:
  /// **'A simple first route for free-to-play and light-spending players. The goal is to start clean, build one carry first, and avoid wasting scarce resources.'**
  String get startHereIntro;

  /// No description provided for @quickStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get quickStartTitle;

  /// No description provided for @quickStartOne.
  ///
  /// In en, this message translates to:
  /// **'Start on the newest open server if you are rerolling.'**
  String get quickStartOne;

  /// No description provided for @quickStartTwo.
  ///
  /// In en, this message translates to:
  /// **'Use the free 1k summon at the beginning.'**
  String get quickStartTwo;

  /// No description provided for @quickStartThree.
  ///
  /// In en, this message translates to:
  /// **'Keep the account if it starts with Renais or Adele.'**
  String get quickStartThree;

  /// No description provided for @quickStartFour.
  ///
  /// In en, this message translates to:
  /// **'Ling can also work with Ying Gou if you specifically want that route.'**
  String get quickStartFour;

  /// No description provided for @quickStartFive.
  ///
  /// In en, this message translates to:
  /// **'If the free 1k misses your target, reroll before investing serious time.'**
  String get quickStartFive;

  /// No description provided for @quickStartSix.
  ///
  /// In en, this message translates to:
  /// **'Build around your starter carry first, then plan the full team.'**
  String get quickStartSix;

  /// No description provided for @starterTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Starter Target'**
  String get starterTargetTitle;

  /// No description provided for @starterTargetIntro.
  ///
  /// In en, this message translates to:
  /// **'Your first account decision is simple: get one reliable carry, then stop chasing a perfect reroll.'**
  String get starterTargetIntro;

  /// No description provided for @targetRenais.
  ///
  /// In en, this message translates to:
  /// **'Renais: preferred beginner carry target.'**
  String get targetRenais;

  /// No description provided for @targetAdele.
  ///
  /// In en, this message translates to:
  /// **'Adele: follows the same general starter plan.'**
  String get targetAdele;

  /// No description provided for @targetLing.
  ///
  /// In en, this message translates to:
  /// **'Ling: optional route when paired with Ying Gou.'**
  String get targetLing;

  /// No description provided for @starterCarryPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Starter Carry Plan'**
  String get starterCarryPlanTitle;

  /// No description provided for @starterCarryPlanText.
  ///
  /// In en, this message translates to:
  /// **'The early route is built around pushing your starter carry quickly. Treat random drops as a bonus, not the foundation of the account.'**
  String get starterCarryPlanText;

  /// No description provided for @copySourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Main copy sources'**
  String get copySourcesTitle;

  /// No description provided for @copySourceStarter.
  ///
  /// In en, this message translates to:
  /// **'Starter summons and early account rewards.'**
  String get copySourceStarter;

  /// No description provided for @copySourceRace.
  ///
  /// In en, this message translates to:
  /// **'Race tokens from race summons.'**
  String get copySourceRace;

  /// No description provided for @copySourceShards.
  ///
  /// In en, this message translates to:
  /// **'Hero shard drops, if lucky.'**
  String get copySourceShards;

  /// No description provided for @copySourceBattle.
  ///
  /// In en, this message translates to:
  /// **'King Final Battle platinum division rewards.'**
  String get copySourceBattle;

  /// No description provided for @copySourceCrates.
  ///
  /// In en, this message translates to:
  /// **'Selection crates from UR summon rewards.'**
  String get copySourceCrates;

  /// No description provided for @copySourceLightSpender.
  ///
  /// In en, this message translates to:
  /// **'First top-up or voucher options for light spenders.'**
  String get copySourceLightSpender;

  /// No description provided for @urDisciplineTitle.
  ///
  /// In en, this message translates to:
  /// **'UR Scroll Discipline'**
  String get urDisciplineTitle;

  /// No description provided for @urDisciplineText.
  ///
  /// In en, this message translates to:
  /// **'Do not spend UR scrolls randomly across every banner. Save for useful reward thresholds so early progress has a direction.'**
  String get urDisciplineText;

  /// No description provided for @gemSpendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Gem Spending'**
  String get gemSpendingTitle;

  /// No description provided for @gemSpendingIntro.
  ///
  /// In en, this message translates to:
  /// **'Gems become tighter later, especially around day 50 and beyond. Treat early gems as progression fuel, not disposable currency.'**
  String get gemSpendingIntro;

  /// No description provided for @gemSpendingOne.
  ///
  /// In en, this message translates to:
  /// **'Avoid impulse spending.'**
  String get gemSpendingOne;

  /// No description provided for @gemSpendingTwo.
  ///
  /// In en, this message translates to:
  /// **'Save for milestone events when possible.'**
  String get gemSpendingTwo;

  /// No description provided for @gemSpendingThree.
  ///
  /// In en, this message translates to:
  /// **'Check spending priorities before committing to banners or packs.'**
  String get gemSpendingThree;

  /// No description provided for @gemSpendingFour.
  ///
  /// In en, this message translates to:
  /// **'Prioritize resources that improve your main carry and core team.'**
  String get gemSpendingFour;

  /// No description provided for @milestoneEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestone Events'**
  String get milestoneEventsTitle;

  /// No description provided for @milestoneEventsText.
  ///
  /// In en, this message translates to:
  /// **'Some events reward you for spending specific currencies after reaching milestones. Saving can be stronger than spending immediately.'**
  String get milestoneEventsText;

  /// No description provided for @day46EventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Day 46 Rotational Events'**
  String get day46EventsTitle;

  /// No description provided for @day46EventsText.
  ///
  /// In en, this message translates to:
  /// **'Earlier notes say rotational events begin around day 46. Each event lasts about two weeks, then rotates out for about two weeks.'**
  String get day46EventsText;

  /// No description provided for @day46UrPlus.
  ///
  /// In en, this message translates to:
  /// **'UR+'**
  String get day46UrPlus;

  /// No description provided for @day46Beasts.
  ///
  /// In en, this message translates to:
  /// **'UR beasts'**
  String get day46Beasts;

  /// No description provided for @day46Mirrors.
  ///
  /// In en, this message translates to:
  /// **'UR mirrors'**
  String get day46Mirrors;

  /// No description provided for @day46UrPlusMirrors.
  ///
  /// In en, this message translates to:
  /// **'UR+ mirrors'**
  String get day46UrPlusMirrors;

  /// No description provided for @phaseOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Your First Session'**
  String get phaseOneTitle;

  /// No description provided for @phaseOneText.
  ///
  /// In en, this message translates to:
  /// **'Day one — get oriented and lock your account\'s direction.'**
  String get phaseOneText;

  /// No description provided for @phaseTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Your First Week'**
  String get phaseTwoTitle;

  /// No description provided for @phaseTwoText.
  ///
  /// In en, this message translates to:
  /// **'Build one carry and spend your resources with intent.'**
  String get phaseTwoText;

  /// No description provided for @phaseThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your First Month & Beyond'**
  String get phaseThreeTitle;

  /// No description provided for @phaseThreeText.
  ///
  /// In en, this message translates to:
  /// **'Settle into the long-term loops and your endgame anchor.'**
  String get phaseThreeText;

  /// No description provided for @heroRenaisDesc.
  ///
  /// In en, this message translates to:
  /// **'The preferred beginner carry target.'**
  String get heroRenaisDesc;

  /// No description provided for @heroAdeleDesc.
  ///
  /// In en, this message translates to:
  /// **'Follows the same general starter plan as Renais.'**
  String get heroAdeleDesc;

  /// No description provided for @heroLingDesc.
  ///
  /// In en, this message translates to:
  /// **'Optional route when paired with Ying Gou.'**
  String get heroLingDesc;

  /// No description provided for @gemTipTitle.
  ///
  /// In en, this message translates to:
  /// **'When in Doubt, Save'**
  String get gemTipTitle;

  /// No description provided for @gemTipText.
  ///
  /// In en, this message translates to:
  /// **'Early gems usually do more on guaranteed progression than on extra pulls. If a purchase is not clearly worth it, hold.'**
  String get gemTipText;

  /// No description provided for @jeanneSpotlightEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Long-Term Anchor'**
  String get jeanneSpotlightEyebrow;

  /// No description provided for @jeanneSpotlightText.
  ///
  /// In en, this message translates to:
  /// **'One of the few heroes you can pick up early and keep all the way to endgame. Investing in her rarely goes to waste.'**
  String get jeanneSpotlightText;

  /// No description provided for @jeanneSpotlightCta.
  ///
  /// In en, this message translates to:
  /// **'View Jeanne'**
  String get jeanneSpotlightCta;

  /// No description provided for @nextStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Next Steps'**
  String get nextStepsTitle;

  /// No description provided for @navGuideIndex.
  ///
  /// In en, this message translates to:
  /// **'Guide Index'**
  String get navGuideIndex;

  /// No description provided for @navSectionGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get navSectionGettingStarted;

  /// No description provided for @navGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'New Player Guide'**
  String get navGettingStarted;

  /// No description provided for @navReroll.
  ///
  /// In en, this message translates to:
  /// **'Reroll Guide'**
  String get navReroll;

  /// No description provided for @navStarterCarry.
  ///
  /// In en, this message translates to:
  /// **'Starter Carry Route'**
  String get navStarterCarry;

  /// No description provided for @navSectionResources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get navSectionResources;

  /// No description provided for @navShopPriority.
  ///
  /// In en, this message translates to:
  /// **'Shop Priority'**
  String get navShopPriority;

  /// No description provided for @navSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending Guide'**
  String get navSpending;

  /// No description provided for @navSectionUr.
  ///
  /// In en, this message translates to:
  /// **'UR'**
  String get navSectionUr;

  /// No description provided for @navUrIntroduction.
  ///
  /// In en, this message translates to:
  /// **'UR Introduction'**
  String get navUrIntroduction;

  /// No description provided for @navUrPriority.
  ///
  /// In en, this message translates to:
  /// **'UR Priority'**
  String get navUrPriority;

  /// No description provided for @navUrPlus.
  ///
  /// In en, this message translates to:
  /// **'UR+'**
  String get navUrPlus;

  /// No description provided for @navSectionUrPlus.
  ///
  /// In en, this message translates to:
  /// **'UR+'**
  String get navSectionUrPlus;

  /// No description provided for @navNyx.
  ///
  /// In en, this message translates to:
  /// **'Nyx Weapon'**
  String get navNyx;

  /// No description provided for @navSectionGears.
  ///
  /// In en, this message translates to:
  /// **'Gears and Stats'**
  String get navSectionGears;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navGears.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get navGears;

  /// No description provided for @navSectionGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get navSectionGrowth;

  /// No description provided for @navSoulMirrors.
  ///
  /// In en, this message translates to:
  /// **'Soul Mirrors'**
  String get navSoulMirrors;

  /// No description provided for @navSectionHeroes.
  ///
  /// In en, this message translates to:
  /// **'Heroes'**
  String get navSectionHeroes;

  /// No description provided for @navSectionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get navSectionComingSoon;

  /// No description provided for @navHeroes.
  ///
  /// In en, this message translates to:
  /// **'All Heroes'**
  String get navHeroes;

  /// No description provided for @navHeroesStarUp.
  ///
  /// In en, this message translates to:
  /// **'Star-Up'**
  String get navHeroesStarUp;

  /// No description provided for @navTeamComps.
  ///
  /// In en, this message translates to:
  /// **'Team Comps'**
  String get navTeamComps;

  /// No description provided for @navTierList.
  ///
  /// In en, this message translates to:
  /// **'Tier List'**
  String get navTierList;

  /// No description provided for @heroesTitle.
  ///
  /// In en, this message translates to:
  /// **'Heroes'**
  String get heroesTitle;

  /// No description provided for @heroesIntro.
  ///
  /// In en, this message translates to:
  /// **'Browse every hero, filter by class and rarity, and tap one for its full kit and recommended Soul Mirror.'**
  String get heroesIntro;

  /// No description provided for @heroesStarUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Star-Up Costs (SSR+ → Opal 5★)'**
  String get heroesStarUpTitle;

  /// No description provided for @heroesStarUpIntro.
  ///
  /// In en, this message translates to:
  /// **'Exactly how many copies and fodder you need to take an SSR+ hero all the way to Opal 5★. Same costs for every hero.'**
  String get heroesStarUpIntro;

  /// No description provided for @heroesStarUpTotal.
  ///
  /// In en, this message translates to:
  /// **'{copies} copies total ({duplicates} duplicates + 1 base)'**
  String heroesStarUpTotal(int copies, int duplicates);

  /// No description provided for @heroesStarUpDuplicatesLabel.
  ///
  /// In en, this message translates to:
  /// **'duplicates'**
  String get heroesStarUpDuplicatesLabel;

  /// No description provided for @heroesStarUpBaseCopy.
  ///
  /// In en, this message translates to:
  /// **'+ base copy'**
  String get heroesStarUpBaseCopy;

  /// No description provided for @heroesStarUpMostExpensive.
  ///
  /// In en, this message translates to:
  /// **'Priciest tier'**
  String get heroesStarUpMostExpensive;

  /// No description provided for @heroesStarUpFodderLabel.
  ///
  /// In en, this message translates to:
  /// **'Fodder'**
  String get heroesStarUpFodderLabel;

  /// No description provided for @heroesStarUpTipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get heroesStarUpTipsLabel;

  /// No description provided for @heroesStarUpSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get heroesStarUpSourceLabel;

  /// No description provided for @heroSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search heroes by name'**
  String get heroSearchHint;

  /// No description provided for @heroFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get heroFilterAll;

  /// No description provided for @heroShownLabel.
  ///
  /// In en, this message translates to:
  /// **'heroes'**
  String get heroShownLabel;

  /// No description provided for @heroEmpty.
  ///
  /// In en, this message translates to:
  /// **'No heroes match these filters.'**
  String get heroEmpty;

  /// No description provided for @heroNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Hero not found'**
  String get heroNotFoundTitle;

  /// No description provided for @heroNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'We don\'t have a page for this hero yet. Browse the full roster from the Heroes tab.'**
  String get heroNotFoundBody;

  /// No description provided for @heroMirrorHintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended Soul Mirror'**
  String get heroMirrorHintsTitle;

  /// No description provided for @heroMirrorHintsBody.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s bonded Soul Mirror. Tap it for the full skill scaling.'**
  String heroMirrorHintsBody(Object name);

  /// No description provided for @heroMirrorRankingTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended Mirrors'**
  String get heroMirrorRankingTitle;

  /// No description provided for @heroMirrorShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show full ranking ({count})'**
  String heroMirrorShowMore(Object count);

  /// No description provided for @heroMirrorShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get heroMirrorShowLess;

  /// No description provided for @toExtractTitle.
  ///
  /// In en, this message translates to:
  /// **'To Extract'**
  String get toExtractTitle;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Status: draft'**
  String get statusDraft;

  /// No description provided for @statusNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Status: needs review'**
  String get statusNeedsReview;

  /// No description provided for @introTitle.
  ///
  /// In en, this message translates to:
  /// **'Twilight Chronicle Guides'**
  String get introTitle;

  /// No description provided for @introIntro.
  ///
  /// In en, this message translates to:
  /// **'A structured rewrite of community guide material, maintained and reviewed on this site.'**
  String get introIntro;

  /// No description provided for @introMainSectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Main Sections'**
  String get introMainSectionsTitle;

  /// No description provided for @introSourcePolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Source Policy'**
  String get introSourcePolicyTitle;

  /// No description provided for @introSourcePolicyText.
  ///
  /// In en, this message translates to:
  /// **'Each page tracks its source capture, verification date, and whether the information is current.'**
  String get introSourcePolicyText;

  /// No description provided for @introStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'draft: copied or summarized, not fully reviewed.'**
  String get introStatusDraft;

  /// No description provided for @introStatusNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'needs review: likely useful but may be outdated or incomplete.'**
  String get introStatusNeedsReview;

  /// No description provided for @introStatusCurrent.
  ///
  /// In en, this message translates to:
  /// **'current: reviewed against the current game state.'**
  String get introStatusCurrent;

  /// No description provided for @introStatusOutdated.
  ///
  /// In en, this message translates to:
  /// **'outdated: kept for history, not recommended as current advice.'**
  String get introStatusOutdated;

  /// No description provided for @introStartHereTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Here'**
  String get introStartHereTitle;

  /// No description provided for @introStartHereText.
  ///
  /// In en, this message translates to:
  /// **'New to the game? Follow these four steps in order.'**
  String get introStartHereText;

  /// No description provided for @introBrowseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse Guides'**
  String get introBrowseTitle;

  /// No description provided for @introBrowseText.
  ///
  /// In en, this message translates to:
  /// **'Every guide, grouped by topic. Pick a category to dive in.'**
  String get introBrowseText;

  /// No description provided for @introStatusKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Status key'**
  String get introStatusKeyTitle;

  /// No description provided for @statusLabelDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusLabelDraft;

  /// No description provided for @statusLabelNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get statusLabelNeedsReview;

  /// No description provided for @statusLabelCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get statusLabelCurrent;

  /// No description provided for @statusLabelOutdated.
  ///
  /// In en, this message translates to:
  /// **'Outdated'**
  String get statusLabelOutdated;

  /// No description provided for @guideCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 guide} other{{count} guides}}'**
  String guideCountLabel(int count);

  /// No description provided for @rerollTitle.
  ///
  /// In en, this message translates to:
  /// **'Reroll Guide'**
  String get rerollTitle;

  /// No description provided for @rerollGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get rerollGoalTitle;

  /// No description provided for @rerollGoalText.
  ///
  /// In en, this message translates to:
  /// **'Rerolling is only about the free 1k summon you get at the start. Do not build a complicated route around it, and do not spend extra resources trying to force the account.'**
  String get rerollGoalText;

  /// No description provided for @rerollLoopTitle.
  ///
  /// In en, this message translates to:
  /// **'The Loop'**
  String get rerollLoopTitle;

  /// No description provided for @rerollLoopOne.
  ///
  /// In en, this message translates to:
  /// **'Create a new account on the newest open server.'**
  String get rerollLoopOne;

  /// No description provided for @rerollLoopTwo.
  ///
  /// In en, this message translates to:
  /// **'Claim the free 1k summon.'**
  String get rerollLoopTwo;

  /// No description provided for @rerollLoopThree.
  ///
  /// In en, this message translates to:
  /// **'Use that free 1k summon.'**
  String get rerollLoopThree;

  /// No description provided for @rerollLoopFour.
  ///
  /// In en, this message translates to:
  /// **'If you get the target character, keep the account.'**
  String get rerollLoopFour;

  /// No description provided for @rerollLoopFive.
  ///
  /// In en, this message translates to:
  /// **'If you miss, start over with a new account.'**
  String get rerollLoopFive;

  /// No description provided for @rerollTargetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Targets'**
  String get rerollTargetsTitle;

  /// No description provided for @rerollTargetsText.
  ///
  /// In en, this message translates to:
  /// **'Stop as soon as the free 1k gives you one of the recommended starter carries:'**
  String get rerollTargetsText;

  /// No description provided for @rerollTargetOne.
  ///
  /// In en, this message translates to:
  /// **'Renais'**
  String get rerollTargetOne;

  /// No description provided for @rerollTargetTwo.
  ///
  /// In en, this message translates to:
  /// **'Adele'**
  String get rerollTargetTwo;

  /// No description provided for @rerollTargetThree.
  ///
  /// In en, this message translates to:
  /// **'Ling with Ying Gou, if you specifically want to play that route.'**
  String get rerollTargetThree;

  /// No description provided for @rerollDontTitle.
  ///
  /// In en, this message translates to:
  /// **'What Not to Do'**
  String get rerollDontTitle;

  /// No description provided for @rerollDontOne.
  ///
  /// In en, this message translates to:
  /// **'Do not chase a perfect roll after getting a good starter carry.'**
  String get rerollDontOne;

  /// No description provided for @rerollDontTwo.
  ///
  /// In en, this message translates to:
  /// **'Do not spend paid currency on the reroll.'**
  String get rerollDontTwo;

  /// No description provided for @rerollDontThree.
  ///
  /// In en, this message translates to:
  /// **'Do not continue rerolling for extra copies once you hit the character you wanted.'**
  String get rerollDontThree;

  /// No description provided for @rerollDontFour.
  ///
  /// In en, this message translates to:
  /// **'Do not keep an account only because it has random SSRs if it missed the starter carry.'**
  String get rerollDontFour;

  /// No description provided for @starterCarryPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Starter Carry Route'**
  String get starterCarryPageTitle;

  /// No description provided for @starterCarryScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get starterCarryScopeTitle;

  /// No description provided for @starterCarryScopeText.
  ///
  /// In en, this message translates to:
  /// **'The notes focus on Renais, but the same strategy works for Adele or Ling. The goal is to push your starter carry high enough to carry early progression without relying heavily on luck.'**
  String get starterCarryScopeText;

  /// No description provided for @starterCarryMainIdeaTitle.
  ///
  /// In en, this message translates to:
  /// **'Main Idea'**
  String get starterCarryMainIdeaTitle;

  /// No description provided for @starterCarryMainIdeaText.
  ///
  /// In en, this message translates to:
  /// **'A free-to-play route toward Opal Renais within roughly the first month. The exact numbers need review against the current version, but the structure is useful:'**
  String get starterCarryMainIdeaText;

  /// No description provided for @starterCarryIdeaOne.
  ///
  /// In en, this message translates to:
  /// **'Get the first copy from starter summons.'**
  String get starterCarryIdeaOne;

  /// No description provided for @starterCarryIdeaTwo.
  ///
  /// In en, this message translates to:
  /// **'Use race tokens from race summons for more copies.'**
  String get starterCarryIdeaTwo;

  /// No description provided for @starterCarryIdeaThree.
  ///
  /// In en, this message translates to:
  /// **'Use King Final Battle platinum rewards where available.'**
  String get starterCarryIdeaThree;

  /// No description provided for @starterCarryIdeaFour.
  ///
  /// In en, this message translates to:
  /// **'Use UR summon reward selection crates.'**
  String get starterCarryIdeaFour;

  /// No description provided for @starterCarryIdeaFive.
  ///
  /// In en, this message translates to:
  /// **'Treat random hero shard drops as a bonus, not the foundation of the plan.'**
  String get starterCarryIdeaFive;

  /// No description provided for @starterCarryScrollTitle.
  ///
  /// In en, this message translates to:
  /// **'UR Scroll Discipline'**
  String get starterCarryScrollTitle;

  /// No description provided for @starterCarryScrollText.
  ///
  /// In en, this message translates to:
  /// **'Do not spend UR scrolls casually across every banner. Spend around useful thresholds, since selection rewards can give important starter carry copies. Scrolls carry over, so wasting partial progress on the wrong banner can delay the route.'**
  String get starterCarryScrollText;

  /// No description provided for @starterCarryLightTitle.
  ///
  /// In en, this message translates to:
  /// **'Light Spender Note'**
  String get starterCarryLightTitle;

  /// No description provided for @starterCarryLightText.
  ///
  /// In en, this message translates to:
  /// **'Light spenders may get extra Renais copies through voucher spending and first top-up rewards. This needs current validation before becoming a firm recommendation.'**
  String get starterCarryLightText;

  /// No description provided for @starterCarryCleanupTitle.
  ///
  /// In en, this message translates to:
  /// **'Cleanup Tasks'**
  String get starterCarryCleanupTitle;

  /// No description provided for @starterCarryCleanupOne.
  ///
  /// In en, this message translates to:
  /// **'Confirm current copy counts and reward thresholds.'**
  String get starterCarryCleanupOne;

  /// No description provided for @starterCarryCleanupTwo.
  ///
  /// In en, this message translates to:
  /// **'Confirm whether Renais, Adele, and Ling still share the same practical route.'**
  String get starterCarryCleanupTwo;

  /// No description provided for @starterCarryCleanupThree.
  ///
  /// In en, this message translates to:
  /// **'Add a table of copy sources.'**
  String get starterCarryCleanupThree;

  /// No description provided for @starterCarryCleanupFour.
  ///
  /// In en, this message translates to:
  /// **'Add a warning box for common early spending mistakes.'**
  String get starterCarryCleanupFour;

  /// No description provided for @shopPriorityTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop Priority'**
  String get shopPriorityTitle;

  /// No description provided for @shopPriorityExtractOne.
  ///
  /// In en, this message translates to:
  /// **'Daily shop purchases.'**
  String get shopPriorityExtractOne;

  /// No description provided for @shopPriorityExtractTwo.
  ///
  /// In en, this message translates to:
  /// **'Quick AFK priority.'**
  String get shopPriorityExtractTwo;

  /// No description provided for @shopPriorityExtractThree.
  ///
  /// In en, this message translates to:
  /// **'Event or limited shop priorities.'**
  String get shopPriorityExtractThree;

  /// No description provided for @shopPriorityExtractFour.
  ///
  /// In en, this message translates to:
  /// **'Differences by spending level.'**
  String get shopPriorityExtractFour;

  /// No description provided for @spendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending Guide'**
  String get spendingTitle;

  /// No description provided for @spendingExtractOne.
  ///
  /// In en, this message translates to:
  /// **'High-value purchases.'**
  String get spendingExtractOne;

  /// No description provided for @spendingExtractTwo.
  ///
  /// In en, this message translates to:
  /// **'Low-value traps.'**
  String get spendingExtractTwo;

  /// No description provided for @spendingExtractThree.
  ///
  /// In en, this message translates to:
  /// **'Spending priorities by budget.'**
  String get spendingExtractThree;

  /// No description provided for @spendingExtractFour.
  ///
  /// In en, this message translates to:
  /// **'Banner and event timing.'**
  String get spendingExtractFour;

  /// No description provided for @urIntroductionTitle.
  ///
  /// In en, this message translates to:
  /// **'UR Introduction'**
  String get urIntroductionTitle;

  /// No description provided for @urIntroductionExtractOne.
  ///
  /// In en, this message translates to:
  /// **'What UR heroes are.'**
  String get urIntroductionExtractOne;

  /// No description provided for @urIntroductionExtractTwo.
  ///
  /// In en, this message translates to:
  /// **'How UR heroes link to regular heroes.'**
  String get urIntroductionExtractTwo;

  /// No description provided for @urIntroductionExtractThree.
  ///
  /// In en, this message translates to:
  /// **'Genesis level basics.'**
  String get urIntroductionExtractThree;

  /// No description provided for @urIntroductionExtractFour.
  ///
  /// In en, this message translates to:
  /// **'Scroll and banner timing.'**
  String get urIntroductionExtractFour;

  /// No description provided for @urIntroductionExtractFive.
  ///
  /// In en, this message translates to:
  /// **'Upgrade priority overview.'**
  String get urIntroductionExtractFive;

  /// No description provided for @urPriorityTitle.
  ///
  /// In en, this message translates to:
  /// **'UR Priority'**
  String get urPriorityTitle;

  /// No description provided for @urPriorityExtractOne.
  ///
  /// In en, this message translates to:
  /// **'Recommended UR order.'**
  String get urPriorityExtractOne;

  /// No description provided for @urPriorityExtractTwo.
  ///
  /// In en, this message translates to:
  /// **'Jeanne, Lucifer, Wu Kong, Albella, and Enchantress notes.'**
  String get urPriorityExtractTwo;

  /// No description provided for @urPriorityExtractThree.
  ///
  /// In en, this message translates to:
  /// **'Niche or skipped URs.'**
  String get urPriorityExtractThree;

  /// No description provided for @urPriorityExtractFour.
  ///
  /// In en, this message translates to:
  /// **'Spender versus free-to-play differences.'**
  String get urPriorityExtractFour;

  /// No description provided for @urPlusTitle.
  ///
  /// In en, this message translates to:
  /// **'UR+'**
  String get urPlusTitle;

  /// No description provided for @urPlusExtractOne.
  ///
  /// In en, this message translates to:
  /// **'UR+ banner cadence.'**
  String get urPlusExtractOne;

  /// No description provided for @urPlusExtractTwo.
  ///
  /// In en, this message translates to:
  /// **'Required summon types.'**
  String get urPlusExtractTwo;

  /// No description provided for @urPlusExtractThree.
  ///
  /// In en, this message translates to:
  /// **'Upgrade system differences.'**
  String get urPlusExtractThree;

  /// No description provided for @urPlusExtractFour.
  ///
  /// In en, this message translates to:
  /// **'Priority targets.'**
  String get urPlusExtractFour;

  /// No description provided for @jeanneTitle.
  ///
  /// In en, this message translates to:
  /// **'Jeanne'**
  String get jeanneTitle;

  /// No description provided for @jeanneExtractOne.
  ///
  /// In en, this message translates to:
  /// **'Jeanne role.'**
  String get jeanneExtractOne;

  /// No description provided for @jeanneExtractTwo.
  ///
  /// In en, this message translates to:
  /// **'When to build her.'**
  String get jeanneExtractTwo;

  /// No description provided for @jeanneExtractThree.
  ///
  /// In en, this message translates to:
  /// **'Team usage.'**
  String get jeanneExtractThree;

  /// No description provided for @jeanneExtractFour.
  ///
  /// In en, this message translates to:
  /// **'Upgrade breakpoints.'**
  String get jeanneExtractFour;

  /// No description provided for @nyxTitle.
  ///
  /// In en, this message translates to:
  /// **'Nyx Weapon'**
  String get nyxTitle;

  /// No description provided for @nyxExtractOne.
  ///
  /// In en, this message translates to:
  /// **'Nyx weapon target.'**
  String get nyxExtractOne;

  /// No description provided for @nyxExtractTwo.
  ///
  /// In en, this message translates to:
  /// **'When to exchange only for Nyx.'**
  String get nyxExtractTwo;

  /// No description provided for @nyxExtractThree.
  ///
  /// In en, this message translates to:
  /// **'Follow-up priorities after Nyx.'**
  String get nyxExtractThree;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTitle;

  /// No description provided for @statsExtractOne.
  ///
  /// In en, this message translates to:
  /// **'Important stat categories.'**
  String get statsExtractOne;

  /// No description provided for @statsExtractTwo.
  ///
  /// In en, this message translates to:
  /// **'Stat priority by role.'**
  String get statsExtractTwo;

  /// No description provided for @statsExtractThree.
  ///
  /// In en, this message translates to:
  /// **'Where to gain each stat.'**
  String get statsExtractThree;

  /// No description provided for @statsExtractFour.
  ///
  /// In en, this message translates to:
  /// **'Common stat mistakes.'**
  String get statsExtractFour;

  /// No description provided for @gearsTitle.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get gearsTitle;

  /// No description provided for @gearsExtractOne.
  ///
  /// In en, this message translates to:
  /// **'Gear unlock timing.'**
  String get gearsExtractOne;

  /// No description provided for @gearsExtractTwo.
  ///
  /// In en, this message translates to:
  /// **'Gear slots and stat slots.'**
  String get gearsExtractTwo;

  /// No description provided for @gearsExtractThree.
  ///
  /// In en, this message translates to:
  /// **'Important stat tiers.'**
  String get gearsExtractThree;

  /// No description provided for @gearsExtractFour.
  ///
  /// In en, this message translates to:
  /// **'Saint Hill Trial connection.'**
  String get gearsExtractFour;

  /// No description provided for @soulMirrorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Soul Mirrors'**
  String get soulMirrorsTitle;

  /// No description provided for @soulMirrorsIntro.
  ///
  /// In en, this message translates to:
  /// **'Browse every Soul Mirror, filter by type and effect, and tap one for its full skill scaling.'**
  String get soulMirrorsIntro;

  /// No description provided for @soulMirrorSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get soulMirrorSearchHint;

  /// No description provided for @soulMirrorTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get soulMirrorTypeAll;

  /// No description provided for @soulMirrorTypeDps.
  ///
  /// In en, this message translates to:
  /// **'DPS'**
  String get soulMirrorTypeDps;

  /// No description provided for @soulMirrorTypeDef.
  ///
  /// In en, this message translates to:
  /// **'DEF'**
  String get soulMirrorTypeDef;

  /// No description provided for @soulMirrorTypeControl.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get soulMirrorTypeControl;

  /// No description provided for @soulMirrorTypeSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get soulMirrorTypeSupport;

  /// No description provided for @soulMirrorRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get soulMirrorRatingLabel;

  /// No description provided for @soulMirrorActivationLabel.
  ///
  /// In en, this message translates to:
  /// **'Activation Effect'**
  String get soulMirrorActivationLabel;

  /// No description provided for @soulMirrorSkillLabel.
  ///
  /// In en, this message translates to:
  /// **'Soul Mirror Skill'**
  String get soulMirrorSkillLabel;

  /// No description provided for @soulMirrorActivateLabel.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get soulMirrorActivateLabel;

  /// No description provided for @soulMirrorStatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Stat Bonus'**
  String get soulMirrorStatsLabel;

  /// No description provided for @soulMirrorAnimaLabel.
  ///
  /// In en, this message translates to:
  /// **'Anima'**
  String get soulMirrorAnimaLabel;

  /// No description provided for @soulMirrorRareLabel.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get soulMirrorRareLabel;

  /// No description provided for @soulMirrorQualityEpic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get soulMirrorQualityEpic;

  /// No description provided for @soulMirrorQualityLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get soulMirrorQualityLegendary;

  /// No description provided for @soulMirrorQualityEternal.
  ///
  /// In en, this message translates to:
  /// **'Eternal'**
  String get soulMirrorQualityEternal;

  /// No description provided for @soulMirrorPowerLabel.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get soulMirrorPowerLabel;

  /// No description provided for @soulMirrorShownLabel.
  ///
  /// In en, this message translates to:
  /// **'shown'**
  String get soulMirrorShownLabel;

  /// No description provided for @soulMirrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'No mirrors match these filters.'**
  String get soulMirrorEmpty;

  /// No description provided for @teamCompsTitle.
  ///
  /// In en, this message translates to:
  /// **'Team Comps'**
  String get teamCompsTitle;

  /// No description provided for @teamCompsIntro.
  ///
  /// In en, this message translates to:
  /// **'Battle-tested team cores for Twilight Chronicle: pick your engine, see why it works, and adapt it to the heroes you own.'**
  String get teamCompsIntro;

  /// No description provided for @teamCompsBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Team building 101'**
  String get teamCompsBasicsTitle;

  /// No description provided for @teamCompsBasicsSlots.
  ///
  /// In en, this message translates to:
  /// **'You deploy 6 heroes: 1 in the front, 2 in the mid line and 3 in the back.'**
  String get teamCompsBasicsSlots;

  /// No description provided for @teamCompsBasicsLines.
  ///
  /// In en, this message translates to:
  /// **'Lane buffs come from the first Destiny Star Gate (the later gates are not lane-based) — only the midline gets Crit Rate, so crit DPS go mid; the front slot gets the heaviest defensive buffs, so the tank goes there.'**
  String get teamCompsBasicsLines;

  /// No description provided for @teamCompsBasicsRace.
  ///
  /// In en, this message translates to:
  /// **'Same-faction heroes add a team-wide stat bonus, but treat it as a freebie, not a goal: NEVER bench a stronger hero to chase the faction bonus. It helps in your first days; in the long run hero quality and kit synergy win.'**
  String get teamCompsBasicsRace;

  /// No description provided for @teamCompsBasicsOtherworld.
  ///
  /// In en, this message translates to:
  /// **'Otherworld heroes (all URs) count as ANY faction for that bonus and sit outside the faction-counter wheel — so a strong endgame team usually gets the race bonus for free anyway.'**
  String get teamCompsBasicsOtherworld;

  /// No description provided for @teamCompsBasicsEngine.
  ///
  /// In en, this message translates to:
  /// **'A good team is a debuff engine: stack heroes that apply and exploit the same mechanic — [Holy Seal], [Infect], [Sigil] or [Bleed].'**
  String get teamCompsBasicsEngine;

  /// No description provided for @teamCompsVariantEndgame.
  ///
  /// In en, this message translates to:
  /// **'Endgame'**
  String get teamCompsVariantEndgame;

  /// No description provided for @teamCompsVariantBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get teamCompsVariantBudget;

  /// No description provided for @teamCompsLineFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get teamCompsLineFront;

  /// No description provided for @teamCompsLineMid.
  ///
  /// In en, this message translates to:
  /// **'Mid'**
  String get teamCompsLineMid;

  /// No description provided for @teamCompsLineBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get teamCompsLineBack;

  /// No description provided for @teamCompsWhyItWorks.
  ///
  /// In en, this message translates to:
  /// **'Why it works'**
  String get teamCompsWhyItWorks;

  /// No description provided for @teamCompsViewBuild.
  ///
  /// In en, this message translates to:
  /// **'View build'**
  String get teamCompsViewBuild;

  /// No description provided for @teamCompsRaceBonus.
  ///
  /// In en, this message translates to:
  /// **'{count}× {faction}: ATK +{atk}% · DEF +{def}% · HP +{hp}%'**
  String teamCompsRaceBonus(
    int count,
    Object faction,
    int atk,
    int def,
    int hp,
  );

  /// No description provided for @teamCompsRaceBonusOtherworld.
  ///
  /// In en, this message translates to:
  /// **'6× Otherworld: ATK +20% · DEF +15% · HP +30% · Final DMG +15%'**
  String get teamCompsRaceBonusOtherworld;

  /// No description provided for @tierListTitle.
  ///
  /// In en, this message translates to:
  /// **'Tier List'**
  String get tierListTitle;

  /// No description provided for @tierListExtractOne.
  ///
  /// In en, this message translates to:
  /// **'Tier definitions.'**
  String get tierListExtractOne;

  /// No description provided for @tierListExtractTwo.
  ///
  /// In en, this message translates to:
  /// **'Build order caveats.'**
  String get tierListExtractTwo;

  /// No description provided for @tierListExtractThree.
  ///
  /// In en, this message translates to:
  /// **'Separate notes for UR and UR+ heroes.'**
  String get tierListExtractThree;

  /// No description provided for @tierListExtractFour.
  ///
  /// In en, this message translates to:
  /// **'PvE versus PvP differences.'**
  String get tierListExtractFour;

  /// No description provided for @heroBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get heroBackground;

  /// No description provided for @heroHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heroHeightLabel;

  /// No description provided for @heroIllustratorLabel.
  ///
  /// In en, this message translates to:
  /// **'Illustrator'**
  String get heroIllustratorLabel;

  /// No description provided for @heroClassFormat.
  ///
  /// In en, this message translates to:
  /// **'{name} Class'**
  String heroClassFormat(Object name);

  /// No description provided for @skillReleaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Released on Turn'**
  String get skillReleaseLabel;

  /// No description provided for @skillCooldownLabel.
  ///
  /// In en, this message translates to:
  /// **'Cooldown'**
  String get skillCooldownLabel;

  /// No description provided for @turnsLabel.
  ///
  /// In en, this message translates to:
  /// **'Turns'**
  String get turnsLabel;

  /// No description provided for @statHp.
  ///
  /// In en, this message translates to:
  /// **'HP'**
  String get statHp;

  /// No description provided for @statAtk.
  ///
  /// In en, this message translates to:
  /// **'ATK'**
  String get statAtk;

  /// No description provided for @statDef.
  ///
  /// In en, this message translates to:
  /// **'DEF'**
  String get statDef;

  /// No description provided for @statSpd.
  ///
  /// In en, this message translates to:
  /// **'SPD'**
  String get statSpd;

  /// No description provided for @heroEvolutionLabel.
  ///
  /// In en, this message translates to:
  /// **'Evolution'**
  String get heroEvolutionLabel;

  /// No description provided for @levelCapLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Lv.'**
  String get levelCapLabel;

  /// No description provided for @genesisSkillTitle.
  ///
  /// In en, this message translates to:
  /// **'Genesis Skill'**
  String get genesisSkillTitle;

  /// No description provided for @genesisFooter.
  ///
  /// In en, this message translates to:
  /// **'Otherworld Hero Genesis Advance grants exclusive battle traits'**
  String get genesisFooter;

  /// No description provided for @genesisLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Genesis'**
  String get genesisLevelLabel;

  /// No description provided for @feedbackFabTooltip.
  ///
  /// In en, this message translates to:
  /// **'Feedback & requests'**
  String get feedbackFabTooltip;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Help improve the guides'**
  String get feedbackTitle;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Request a guide, report a bug, or suggest a fix. Email is optional — add it only if you\'d like a reply.'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get feedbackCategoryLabel;

  /// No description provided for @feedbackCategoryFeature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get feedbackCategoryFeature;

  /// No description provided for @feedbackCategoryBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get feedbackCategoryBug;

  /// No description provided for @feedbackCategoryFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get feedbackCategoryFix;

  /// No description provided for @feedbackCategoryGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get feedbackCategoryGuide;

  /// No description provided for @feedbackTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get feedbackTitleLabel;

  /// No description provided for @feedbackTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Short summary'**
  String get feedbackTitleHint;

  /// No description provided for @feedbackEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get feedbackEmailLabel;

  /// No description provided for @feedbackEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get feedbackEmailHint;

  /// No description provided for @feedbackMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get feedbackMessageLabel;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your request or the problem'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSend;

  /// No description provided for @feedbackSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get feedbackSending;

  /// No description provided for @feedbackSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your message was sent.'**
  String get feedbackSuccess;

  /// No description provided for @feedbackError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send. Try again, or use GitHub / Discord below.'**
  String get feedbackError;

  /// No description provided for @feedbackErrorTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add a title.'**
  String get feedbackErrorTitleRequired;

  /// No description provided for @feedbackErrorMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add a message.'**
  String get feedbackErrorMessageRequired;

  /// No description provided for @feedbackErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get feedbackErrorInvalidEmail;

  /// No description provided for @feedbackEmailUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Email isn\'t set up yet — please use GitHub or Discord.'**
  String get feedbackEmailUnavailable;

  /// No description provided for @feedbackPageNotice.
  ///
  /// In en, this message translates to:
  /// **'Your current page is included automatically.'**
  String get feedbackPageNotice;

  /// No description provided for @feedbackChannelsLabel.
  ///
  /// In en, this message translates to:
  /// **'Prefer another way? Reach out via'**
  String get feedbackChannelsLabel;

  /// No description provided for @feedbackGithub.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get feedbackGithub;

  /// No description provided for @feedbackDiscord.
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get feedbackDiscord;

  /// No description provided for @helpfulQuestion.
  ///
  /// In en, this message translates to:
  /// **'Was this guide helpful?'**
  String get helpfulQuestion;

  /// No description provided for @helpfulYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get helpfulYes;

  /// No description provided for @helpfulNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get helpfulNo;

  /// No description provided for @helpfulThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for the feedback!'**
  String get helpfulThanks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
