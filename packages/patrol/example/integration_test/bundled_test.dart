// ignore_for_file: invalid_use_of_internal_member, depend_on_referenced_packages, directives_ordering

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';
import 'package:test_api/src/backend/invoker.dart';

// START: GENERATED CODE
import 'example_test.dart' as example_test;
import 'permissions/permissions_location_test.dart'
    as permissions_location_test;
import 'permissions/permissions_many_1_test.dart' as permissions_many_1_test;
import 'permissions/permissions_many_2_test.dart' as permissions_many_2_test;
import 'sign_in/sign_in_email_test.dart' as sign_in_email_test;
import 'sign_in/sign_in_facebook_test.dart' as sign_in_facebook_test;
import 'sign_in/sign_in_google_test.dart' as sign_in_google_test;
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
  test('patrol_test_explorer', () {
    final topLevelGroup = Invoker.current!.liveTest.groups.first;
    final dartTestGroup = createDartTestGroup(topLevelGroup);
    testExplorationCompleter.complete(dartTestGroup);
  });

  // START: GENERATED CODE
  group('permissions', () {
    group('permissions_location_test.dart', permissions_location_test.main);
    group('permissions_many_1_test.dart', permissions_many_1_test.main);
    group('permissions_many_2_test.dart', permissions_many_2_test.main);
  });
  group('sign_in', () {
    group('sign_in_test.dart', sign_in_email_test.main);
    group('sign_in_google_test.dart', sign_in_google_test.main);
    group('sign_in_facebook_test.dart', sign_in_facebook_test.main);
  });
  group('example_test.dart', example_test.main);
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
