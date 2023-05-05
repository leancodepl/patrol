// ignore_for_file: invalid_use_of_internal_member, depend_on_referenced_packages, directives_ordering

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';
import 'package:test_api/src/backend/invoker.dart';

// START: GENERATED CODE
import 'android_app_test.dart' as android_app_test;
import 'example_test.dart' as example_test;
import 'notifications_test.dart' as notifications_test;
import 'open_app_test.dart' as open_app_test;
import 'open_quick_settings_test.dart' as open_quick_settings_test;
import 'permissions_many_test.dart' as permissions_many_test;
import 'service_cellular_test.dart' as service_cellular_test;
import 'service_dark_mode_test.dart' as service_dark_mode_test;
import 'service_wifi_test.dart' as service_wifi_test;
import 'swipe_test.dart' as swipe_test;
// END: GENERATED CODE

Future<void> main() async {
  // TODO: Create and use PatrolNativeTestService instead of NativeAutomator
  final nativeAutomator = NativeAutomator(config: NativeAutomatorConfig());
  final binding = PatrolBinding.ensureInitialized();
  // Create a PatrolAppService.
  //
  // Android Test Orchestrator, before running the tests, makes an initial run
  // to gather the tests that it will later run. The native side of Patrol
  // (specifically: PatrolJUnitRunner class) is hooked into the Android Test
  // Orchestrator lifecycle and knows when that initial run happens. When it
  // does, PatrolJUnitRunner makes an RPC call to PatrolAppService and asks it
  // for the list of Dart tests.
  //
  // These Dart tests are later called by the single JUnit test that is
  // parametrized with the gathered Dart tests.

  final testExplorationCompleter = Completer<DartTestGroup>();

  // Run a single, special test to expore the hierarchy of groups and tests
  // This will break if the test order becomes randomized, since there'll be no
  // guarantee that patrol_test_explorer will be the first to run.
  test('patrol_test_explorer', () {
    final topLevelGroup = Invoker.current!.liveTest.groups.first;
    final dartTestGroup = createDartTestGroup(topLevelGroup);
    testExplorationCompleter.complete(dartTestGroup);
  });

  // START: GENERATED CODE
  group('android_app_test', android_app_test.main);
  group('example_test', example_test.main);
  group('notifications_test', notifications_test.main);
  group('open_app_test', open_app_test.main);
  group('open_quick_settings_test', open_quick_settings_test.main);
  group('permissions_many_test', permissions_many_test.main);
  group('service_cellular_test', service_cellular_test.main);
  group('service_dark_mode_test', service_dark_mode_test.main);
  group('service_wifi_test', service_wifi_test.main);
  group('swipe_test', swipe_test.main);
  // END: GENERATED CODE

  final dartTestGroup = await testExplorationCompleter.future;
  final appService = PatrolAppService(topLevelDartTestGroup: dartTestGroup);
  binding.patrolAppService = appService;
  await runAppService(appService);

  // Until now, the PatrolJUnit runner was waiting for us (the Dart side) to
  // come alive. Now that we did, let's share this information with it.
  await nativeAutomator.markPatrolAppServiceReady();

  await appService.testExecutionCompleted;
  print('End of bundled test');
}
