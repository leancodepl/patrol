import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:patrol_cli/src/base/logger.dart';

class TestBundler {
  TestBundler({required Directory projectRoot, required Logger logger})
    : _projectRoot = projectRoot,
      _fs = projectRoot.fileSystem,
      _logger = logger;

  static const _devtoolsRootDirectories = {
    'lib',
    'bin',
    'integration_test',
    'test',
    'benchmark',
    'example',
  };
  static const _devtoolsEntrypointDirectory = 'integration_test';
  static const _devtoolsEntrypointFileName = 'patrol_test_bundle.dart';

  final Directory _projectRoot;
  final FileSystem _fs;
  final Logger _logger;

  /// Creates an entrypoint for use with `patrol test` and `patrol build`.
  void createTestBundle(
    String testDirectory,
    List<String> testFilePaths,
    String? tags,
    String? excludeTags, {
    bool web = false,
  }) {
    if (testFilePaths.isEmpty) {
      throw ArgumentError('testFilePaths must not be empty');
    }

    final contents =
        '''
// GENERATED CODE - DO NOT MODIFY BY HAND AND DO NOT COMMIT TO VERSION CONTROL
// ignore_for_file: type=lint, invalid_use_of_internal_member

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:test_api/src/backend/invoker.dart';

// START: GENERATED TEST IMPORTS
${generateImports(testDirectory, testFilePaths, web: web)}
// END: GENERATED TEST IMPORTS

Future<void> main() async {
  // This is the entrypoint of the bundled Dart test.
  //
  // Its responsibilities are:
  //  * Running a special Dart test that runs before all the other tests and
  //    explores the hierarchy of groups and tests.
  //  * Hosting a PatrolAppService, which the native side of Patrol uses to get
  //    the Dart tests, and to request execution of a specific Dart test.
  //
  // When running on Android, the Android Test Orchestrator, before running the
  // tests, makes an initial run to gather the tests that it will later run. The
  // native side of Patrol (specifically: PatrolJUnitRunner class) is hooked
  // into the Android Test Orchestrator lifecycle and knows when that initial
  // run happens. When it does, PatrolJUnitRunner makes an RPC call to
  // PatrolAppService and asks it for Dart tests.
  //
  // When running on iOS, the native side of Patrol (specifically: the
  // PATROL_INTEGRATION_TEST_IOS_RUNNER macro) makes an initial run to gather
  // the tests that it will later run (same as the Android). During that initial
  // run, it makes an RPC call to PatrolAppService and asks it for Dart tests.
  //
  // Once the native runner has the list of Dart tests, it dynamically creates
  // native test cases from them. On Android, this is done using the
  // Parametrized JUnit runner. On iOS, new test case methods are swizzled into
  // the RunnerUITests class, taking advantage of the very dynamic nature of
  // Objective-C runtime.
  //
  // Execution of these dynamically created native test cases is then fully
  // managed by the underlying native test framework (JUnit on Android, XCTest
  // on iOS). The native test cases do only one thing - request execution of the
  // Dart test (out of which they had been created) and wait for it to complete.
  // The result of running the Dart test is the result of the native test case.

  final platformAutomator = PlatformAutomator(
    config: PlatformAutomatorConfig.defaultConfig(),
  );
  await platformAutomator.initialize();
  final binding = PatrolBinding.ensureInitialized(platformAutomator);
  final testExplorationCompleter = Completer<DartGroupEntry>();

  // A special test to explore the hierarchy of groups and tests. This is a hack
  // around https://github.com/dart-lang/test/issues/1998.
  //
  // This test must be the first to run. If not, the native side likely won't
  // receive any tests, and everything will fall apart.
  test('patrol_test_explorer', () {
    // Maybe somewhat counterintuitively, this callback runs *after* the calls
    // to group() below.
    final topLevelGroup = Invoker.current!.liveTest.groups.first;
    final dartTestGroup = createDartTestGroup(
      topLevelGroup,
      tags: ${tags != null ? "'$tags'" : null},
      excludeTags: ${excludeTags != null ? "'$excludeTags'" : null},
    );
    testExplorationCompleter.complete(dartTestGroup);
    print('patrol_test_explorer: obtained Dart-side test hierarchy:');
    reportGroupStructure(dartTestGroup);
  });

// START: GENERATED TEST GROUPS
${generateGroupsCode(testDirectory, testFilePaths).split('\n').map((e) => '  $e').join('\n')}
// END: GENERATED TEST GROUPS

  final dartTestGroup = await testExplorationCompleter.future;
  final appService = PatrolAppService(topLevelDartTestGroup: dartTestGroup);
  binding.patrolAppService = appService;
  await runAppService(appService);

  // Until now, the native test runner was waiting for us, the Dart side, to
  // come alive. Now that we did, let's tell it that we're ready to be asked
  // about Dart tests.
  await platformAutomator.markPatrolAppServiceReady();

  await appService.testExecutionCompleted;
}
''';

    // This file must not end with "_test.dart", otherwise it'll be picked up
    // when finding tests to bundle.
    final bundle = getBundledTestFile(testDirectory, web: web)
      ..createSync(recursive: true)
      ..writeAsStringSync(contents);

    _logger.detail(
      'Generated entrypoint ${bundle.path} with ${testFilePaths.length} bundled test(s)',
    );
  }

  // This file must not end with "_test.dart", otherwise it'll be picked up
  // when finding tests to bundle.
  File getBundledTestFile(String testDirectory, {bool web = false}) => web
      ? _projectRoot.childFile('test_bundle.dart')
      : _projectRoot
            .childDirectory(testDirectory)
            .childFile('test_bundle.dart');

  File getEntrypointFile(String testDirectory) {
    if (_shouldUseEntrypointProxy(testDirectory)) {
      return _projectRoot
          .childDirectory(_devtoolsEntrypointDirectory)
          .childFile(_devtoolsEntrypointFileName);
    }
    return getBundledTestFile(testDirectory);
  }

  void ensureEntrypoint(String testDirectory) {
    if (_shouldUseEntrypointProxy(testDirectory)) {
      _createEntrypointProxyIfNeeded(testDirectory);
    }
  }

  void deleteEntrypointProxy(String testDirectory) {
    if (!_shouldUseEntrypointProxy(testDirectory)) {
      return;
    }

    final proxyFile = getEntrypointFile(testDirectory);
    if (proxyFile.existsSync()) {
      proxyFile.deleteSync();
    }

    final proxyDir = proxyFile.parent;
    if (proxyDir.existsSync() && proxyDir.listSync().isEmpty) {
      proxyDir.deleteSync();
    }
  }

  /// Creates an entrypoint for use with `patrol develop`.
  void createDevelopTestBundle(String testDirectory, String testFilePath) {
    final contents =
        '''
// ignore_for_file: type=lint, invalid_use_of_internal_member

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

// START: GENERATED TEST IMPORTS
${generateImports(testDirectory, [testFilePath])}
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
${generateGroupsCode(testDirectory, [testFilePath]).split('\n').map((e) => '  $e').join('\n')}
  // END: GENERATED TEST GROUPS
}
''';

    final bundle = getBundledTestFile(testDirectory)
      ..createSync(recursive: true)
      ..writeAsStringSync(contents);

    /// Related with [https://github.com/flutter/devtools/issues/9667].
    /// Patrol devtools extension is not found when the test is moved to `patrol_test/`.
    /// This is a workaround to create a proxy entrypoint to make the devtools extension work.
    _createEntrypointProxyIfNeeded(testDirectory);

    _logger.detail('Generated entrypoint ${bundle.path} for development');
  }

  /// Input:
  ///
  /// ```dart
  /// [
  ///   'patrol_test/example_test.dart',
  ///   'patrol_test/permissions/permissions_location_test.dart',
  ///   '/Users/charlie/awesome_app/integration_test/app_test.dart',
  /// ]
  /// ```
  /// Output:
  /// ```dart
  /// '''
  /// import 'example_test.dart' as example_test;
  /// import 'permissions/permissions_location_test.dart' as permissions__permissions_location_test;
  /// import '../integration_test/app_test.dart' as integration_test__app_test;
  /// '''
  /// ```
  @visibleForTesting
  String generateImports(
    String testDirectory,
    List<String> testFilePaths, {
    bool web = false,
  }) {
    final imports = <String>[];
    for (final testFilePath in testFilePaths) {
      final importPath = _createImportPath(
        testDirectory,
        testFilePath,
        web: web,
      );
      final testName = _createTestName(testDirectory, testFilePath);
      imports.add("import '$importPath' as $testName;");
    }

    return imports.join('\n');
  }

  /// Input:
  ///
  /// ```dart
  /// [
  ///   'patrol_test/permissions/permissions_location_test.dart',
  ///   'patrol_test/example_test.dart',
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
  String generateGroupsCode(String testDirectory, List<String> testFilePaths) {
    final groups = <String>[];
    for (final testFilePath in testFilePaths) {
      final testName = _createTestName(testDirectory, testFilePath);
      final groupName = testName.replaceAll('__', '.');
      final testEntrypoint = '$testName.main';
      groups.add("group('$groupName', $testEntrypoint);");
    }
    return groups.join('\n');
  }

  /// Computes the path used in the generated `import` directive for
  /// [testFilePath], relative to the directory the bundle file lives in.
  ///
  /// Using a path relative to the bundle keeps the import valid regardless of
  /// where the test file is located - in particular when it lives outside the
  /// configured [testDirectory] (e.g. a target under `integration_test/` while
  /// `test_directory` is `patrol_test`). In that case the result is a path such
  /// as `../integration_test/example_test.dart`.
  String _createImportPath(
    String testDirectory,
    String testFilePath, {
    required bool web,
  }) {
    final bundleDirectory = getBundledTestFile(
      testDirectory,
      web: web,
    ).parent.absolute.path;

    final relativeTestFilePath = _fs.path.relative(
      testFilePath,
      from: bundleDirectory,
    );

    // Dart source code uses forward slashes regardless of the host platform.
    return relativeTestFilePath.replaceAll(_fs.path.separator, '/');
  }

  /// Builds a valid Dart identifier used as the import alias (and, after
  /// replacing `__` with `.`, the group name) for [testFilePath].
  ///
  /// The name is derived from the path of the test file relative to the
  /// configured [testDirectory]. Any character that is not allowed in a Dart
  /// identifier (e.g. the hyphen in `acme-corp`, or the dots introduced by a
  /// `..` segment when the test lives outside [testDirectory]) is replaced with
  /// an underscore so the generated bundle always compiles.
  String _createTestName(String testDirectory, String testFilePath) {
    final testDirectoryPath = _projectRoot
        .childDirectory(testDirectory)
        .absolute
        .path;

    var name = _fs.path
        .relative(testFilePath, from: testDirectoryPath)
        .replaceAll(_fs.path.separator, '/');

    if (name.endsWith('.dart')) {
      name = name.substring(0, name.length - '.dart'.length);
    }

    // Drop leading `../` segments (present when the test lives outside the
    // test directory) so the alias stays readable instead of starting with a
    // run of underscores.
    while (name.startsWith('../')) {
      name = name.substring('../'.length);
    }

    name = name.replaceAll('/', '__').replaceAll(RegExp('[^a-zA-Z0-9_]'), '_');

    // A Dart identifier must not start with a digit.
    if (name.isNotEmpty && RegExp('[0-9]').hasMatch(name[0])) {
      name = '_$name';
    }

    return name;
  }

  bool _shouldUseEntrypointProxy(String testDirectory) {
    return !_devtoolsRootDirectories.contains(testDirectory);
  }

  void _createEntrypointProxyIfNeeded(String testDirectory) {
    if (!_shouldUseEntrypointProxy(testDirectory)) {
      return;
    }

    final proxyFile = getEntrypointFile(testDirectory);
    final targetFile = getBundledTestFile(testDirectory);
    final relativeTargetPath = _fs.path
        .relative(targetFile.path, from: proxyFile.parent.path)
        .replaceAll(_fs.path.separator, '/');

    proxyFile
      ..createSync(recursive: true)
      ..writeAsStringSync('''
// GENERATED CODE - DO NOT MODIFY BY HAND AND DO NOT COMMIT TO VERSION CONTROL
// ignore_for_file: type=lint

import '$relativeTargetPath' as bundle;

Future<void> main() => bundle.main();
''');
  }
}
