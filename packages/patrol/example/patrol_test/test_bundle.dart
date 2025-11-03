// ignore_for_file: type=lint, invalid_use_of_internal_member

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/platform/platform_automator.dart';

// START: GENERATED TEST IMPORTS
import 'main_test.dart' as main_test;
// END: GENERATED TEST IMPORTS

Future<void> main() async {
  final platformAutomator = PlatformAutomator(
    config: PlatformAutomatorConfig.defaultConfig(),
  );
  await platformAutomator.initialize();

  PatrolBinding.ensureInitialized(platformAutomator)
    ..workaroundDebugDefaultTargetPlatformOverride =
        debugDefaultTargetPlatformOverride;

  // START: GENERATED TEST GROUPS
  group('main_test', main_test.main);
  // END: GENERATED TEST GROUPS
}
