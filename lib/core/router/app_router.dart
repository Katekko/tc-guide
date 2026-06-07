import 'package:go_router/go_router.dart';

import 'package:tc_flutter_web/features/guides/presentation/guide_screen_builders.dart';
import 'package:tc_flutter_web/features/guides/presentation/screens/hero_detail_screen.dart';
import 'package:tc_flutter_web/features/guides/presentation/widgets/guide_scaffold.dart';
import 'package:tc_flutter_web/features/home/presentation/screens/home_screen.dart';

import 'app_routes.dart';

/// Builds the app's [GoRouter].
///
/// The guide routes live inside a [ShellRoute] whose builder renders the
/// persistent [DocsScaffold] (app bar + sidebar). Each guide page is a
/// [NoTransitionPage], so switching guides instantly swaps only the content —
/// the left panel stays fixed and there is no whole-page animation. Adding a
/// guide page is still a one-line change in `guideScreenBuilders`.
GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.heroDetail,
        builder: (context, state) => HeroDetailScreen(
          id: int.parse(state.pathParameters['id']!),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => DocsScaffold(
          currentPath: state.matchedLocation,
          child: child,
        ),
        routes: [
          for (final entry in guideScreenBuilders.entries)
            GoRoute(
              path: entry.key,
              pageBuilder: (context, state) =>
                  NoTransitionPage(child: entry.value(context)),
            ),
        ],
      ),
    ],
  );
}
