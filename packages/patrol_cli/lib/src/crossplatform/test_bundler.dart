import 'package:file/file.dart';
import 'package:meta/meta.dart';

class TestBundler {
  TestBundler({required Directory dartToolDirectory})
      : _dartToolDirectory = dartToolDirectory;

  final Directory _dartToolDirectory;

  File createBundledTest(List<String> testFilePaths) {
    if (testFilePaths.isEmpty) {
      throw ArgumentError('testFilePaths must not be empty');
    }

    final contents = '''
// ignore_for_file: invalid_use_of_internal_member, depend_on_referenced_packages, directives_ordering

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';
import 'package:test_api/src/backend/invoker.dart';

// START: GENERATED CODE
${generateImports(testFilePaths)}
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
    print('dartTestGroup: \$dartTestGroup');
    testExplorationCompleter.complete(dartTestGroup);
  });

  // START: GENERATED CODE
  ${generateGroupsCode(testFilePaths)}
  // END: GENERATED CODE

  final dartTestGroup = await testExplorationCompleter.future;
  final appService = PatrolAppService(topLevelDartTestGroup: dartTestGroup);
  binding.patrolAppService = appService;
  await runAppService(appService);

  // Until now, the PatrolJUnit runner was waiting for us (the Dart side) to
  // come alive. Now that we did, let's share this information with it.
  await nativeAutomator.markPatrolAppServiceReady();

  await appService.testExecutionCompleted;
}
''';

    final bundledTestFile = _dartToolDirectory
        .childDirectory('patrol_build')
        .childFile('bundled_test.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync(contents);

    return bundledTestFile.absolute;
  }

  /// Input:
  ///
  /// ```dart
  /// [
  ///   'integration_test/permissions/permissions_location_test.dart',
  ///   'integration_test/example_test.dart',
  /// ]
  /// ```
  /// Output:
  /// ```dart
  /// '''
  /// import 'permissions/permissions_location_test.dart' as permissions_location_test;
  /// import 'example_test.dart' as example_test;
  /// '''
  /// ```
  @visibleForTesting
  String generateImports(List<String> testFilePaths) {
    final imports = <String>[];
    for (final testFilePath in testFilePaths) {
      final testFileName = testFilePath.split('/').last;
      final testName = testFileName.split('.').first;
      imports.add("import '$testFilePath' as $testName;");
    }
    return imports.join('\n');
  }

  /// Input:
  ///
  /// ```dart
  /// [
  ///   'integration_test/permissions/permissions_location_test.dart',
  ///   'integration_test/example_test.dart',
  /// ]
  /// ```
  ///
  /// Output:
  ///
  /// ```dart
  /// '''
  /// group('permissions.permissions_location_test', permissions_location_test.main);
  /// group('example_test', example_test.main);
  /// '''
  /// ```
  @visibleForTesting
  String generateGroupsCode(List<String> testFilePaths) {
    final groups = <String>[];
    for (final testFilePath in testFilePaths) {
      final testFileName = testFilePath.split('/').last;
      final testName = testFileName.split('.').first;
      groups.add("group('$testName', $testName.main);");
    }
    return groups.join('\n');
  }
}
