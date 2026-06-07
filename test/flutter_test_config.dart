import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Auto-loaded by the Flutter test runner. Configures Alchemist for consistent
/// golden rendering locally and in CI.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  const isCI = bool.fromEnvironment('CI');

  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      ciGoldensConfig: CiGoldensConfig(
        enabled: isCI,
        obscureText: true,
        renderShadows: false,
      ),
      platformGoldensConfig: PlatformGoldensConfig(enabled: !isCI),
    ),
    run: testMain,
  );
}
