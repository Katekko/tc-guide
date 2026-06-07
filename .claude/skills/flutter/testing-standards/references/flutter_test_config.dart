// =============================================================================
// FILE: test/flutter_test_config.dart
//
// This file is automatically loaded by the Flutter test framework before
// running any test. It configures Alchemist for consistent golden test
// rendering across platforms and CI environments.
//
// Copy this file to test/flutter_test_config.dart in your project.
// =============================================================================

import 'dart:async';

import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Determine if we're running in a CI environment.
  // Set the CI environment variable in your CI pipeline:
  //   CI=true flutter test
  const isCI = bool.fromEnvironment('CI', defaultValue: false);

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      // -----------------------------------------------------------------------
      // Theme Configuration
      // -----------------------------------------------------------------------
      // Use a consistent theme for all golden tests to avoid platform
      // differences in default theme rendering.
      //
      // Uncomment and customize if your app uses a specific theme:
      // theme: ThemeData(
      //   colorSchemeSeed: Colors.purple,
      //   useMaterial3: true,
      // ),

      // -----------------------------------------------------------------------
      // CI Goldens Configuration
      // -----------------------------------------------------------------------
      // CI goldens are platform-independent and render without platform-
      // specific artifacts (shadows, animations, etc.). Use these in CI
      // pipelines for reliable cross-platform comparison.
      ciGoldensConfig: CiGoldensConfig(
        enabled: isCI,
        // Obscure text to avoid font rendering differences across platforms.
        // Set to false if you need to verify text content in goldens.
        obscureText: true,
        // Render shadows as opaque to avoid anti-aliasing differences.
        renderShadows: false,
      ),

      // -----------------------------------------------------------------------
      // Platform Goldens Configuration
      // -----------------------------------------------------------------------
      // Platform goldens render with full fidelity and are platform-specific.
      // Use these for local development and visual review.
      platformGoldensConfig: PlatformGoldensConfig(
        // Only generate platform goldens when NOT in CI.
        enabled: !isCI,
      ),
    ),
    run: testMain,
  );
}

// =============================================================================
// USAGE NOTES
// =============================================================================
//
// 1. Place this file at: test/flutter_test_config.dart
//    The Flutter test runner auto-discovers it — no imports needed.
//
// 2. Generate / update golden baselines:
//    $ flutter test --update-goldens
//
// 3. Run tests and compare against baselines:
//    $ flutter test
//
// 4. In CI, set the CI environment variable:
//    $ CI=true flutter test
//    or
//    $ flutter test --dart-define=CI=true
//
// 5. Golden image output locations (default Alchemist behavior):
//    - CI goldens:       test/goldens/ci/
//    - Platform goldens: test/goldens/<platform>/
//
// 6. Commit golden images to version control so CI can compare against them.
//
// =============================================================================
