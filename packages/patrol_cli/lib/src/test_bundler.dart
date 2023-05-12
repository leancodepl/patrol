import 'package:file/file.dart';
import 'package:meta/meta.dart';

class TestBundler {
  TestBundler({required Directory projectRoot})
      : _projectRoot = projectRoot,
        _fs = projectRoot.fileSystem;

  final Directory _projectRoot;
  final FileSystem _fs;

  File createBundledTest(List<String> testFilePaths) {
    if (testFilePaths.isEmpty) {
      throw ArgumentError('testFilePaths must not be empty');
    }

    final contents = '''
// ignore_for_file: invalid_use_of_internal_member,
// depend_on_referenced_packages, directives_ordering

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
  // When running on Android, the Android Test Orchestrator, before running the
  // tests, makes an initial run to gather the tests that it will later run. The
  // native side of Patrol (specifically: PatrolJUnitRunner class) is hooked
  // into the Android Test Orchestrator lifecycle and knows when that initial
  // run happens. When it does, PatrolJUnitRunner makes an RPC call to
  // PatrolAppService and asks it for the list of Dart tests.
  //
  // When running on iOS, the native side of Patrol (specifically: the
  // PATROL_INTEGRATION_TEST_IOS_RUNNER macro) makes an RPC call to
  // PatrolAppSevice and asks it for the list of Dart tests.
  //
  // Once the native runner have the list of Dart tests, it dynamically creates
  // native test method from them. On Android, this is done using Parametrized
  // JUnit runner. On iOS, new test case methods are swizzled taking advantage
  // of the very dynamic nature of Objective-C runtime.
  //
  // These Dart tests are later called by the single JUnit test that is
  // parametrized with the gathered Dart tests.

  final testExplorationCompleter = Completer<DartTestGroup>();

  // A special test to expore the hierarchy of groups and tests. This test must
  // be the first to run. If not, the native side won't any tests.
  // See also: https://github.com/dart-lang/test/issues/1998
  test('patrol_test_explorer', () {
    final topLevelGroup = Invoker.current!.liveTest.groups.first;
    final dartTestGroup = createDartTestGroup(topLevelGroup);
    testExplorationCompleter.complete(dartTestGroup);
  });

  // START: GENERATED CODE
  ${generateGroupsCode(testFilePaths)}
  // END: GENERATED CODE

  final dartTestGroup = await testExplorationCompleter.future;
  final appService = PatrolAppService(topLevelDartTestGroup: dartTestGroup);
  binding.patrolAppService = appService;
  await runAppService(appService);

  // Until now, the native test runner was waiting for us, the Dart side, to
  // come alive. Now that we did, let's tell it that we're ready to be asked
  // about Dart tests.
  await nativeAutomator.markPatrolAppServiceReady();

  await appService.testExecutionCompleted;
}
''';

    // This file must not end with "_test.dart", otherwise it'll be picked up
    // when finding tests to bundle.
    final bundledTestFile = _projectRoot
        .childDirectory('integration_test')
        .childFile('test_bundle.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync(contents);

    return bundledTestFile.absolute;
  }

  /// Input:
  ///
  /// ```dart
  /// [
  ///   'integration_test/example_test.dart',
  ///   'integration_test/permissions/permissions_location_test.dart',
  ///   '/Users/charlie/awesome_app/integration_test/app_test.dart',
  /// ]
  /// ```
  /// Output:
  /// ```dart
  /// '''
  /// import 'example_test.dart' as example_test;
  /// import 'permissions/permissions_location_test.dart' as permissions__permissions_location_test;
  /// import 'integration_test/app_test.dart' as app_test;
  /// '''
  /// ```
  @visibleForTesting
  String generateImports(List<String> testFilePaths) {
    final imports = <String>[];
    for (final testFilePath in testFilePaths) {
      final relativeTestFilePath = _normalizeTestPath(testFilePath);
      final testName = _createTestName(relativeTestFilePath);
      imports.add("import '$relativeTestFilePath' as $testName;\n");
    }

    return imports.join();
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
      final relativeTestFilePath = _normalizeTestPath(testFilePath);
      final testName = _createTestName(relativeTestFilePath);
      final groupName = testName.replaceAll('__', '.');
      final testEntrypoint = '$testName.main';
      groups.add("group('$groupName', $testEntrypoint);\n");
    }
    return groups.join();
  }

  /// Normalizes [testFilePath] so that it always starts with
  /// 'integration_test'.
  String _normalizeTestPath(String testFilePath) {
    var relativeTestFilePath = testFilePath.replaceAll(
      _projectRoot.childDirectory('integration_test').absolute.path,
      '',
    );

    if (relativeTestFilePath.startsWith('integration_test')) {
      relativeTestFilePath = relativeTestFilePath.replaceFirst(
        'integration_test',
        '',
      );
    }

    if (relativeTestFilePath.startsWith(_fs.path.separator)) {
      relativeTestFilePath = relativeTestFilePath.substring(1);
    }

    // Dart source code uses forward slash.
    return relativeTestFilePath.replaceAll(_fs.path.separator, '/');
  }

  String _createTestName(String relativeTestFilePath) {
    var testName = relativeTestFilePath
        .replaceFirst('integration_test${_fs.path.separator}', '')
        .replaceAll('/', '__');

    testName = testName.substring(0, testName.length - 5);
    return testName;
  }
}
