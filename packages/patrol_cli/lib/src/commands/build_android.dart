import 'dart:async';

import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_paths.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/dart_define_utils.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';

class BuildAndroidCommand extends PatrolCommand {
  BuildAndroidCommand({
    required TestFinderFactory testFinderFactory,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required Analytics analytics,
    required Logger logger,
    required CompatibilityChecker compatibilityChecker,
  }) : _testFinderFactory = testFinderFactory,
       _testBundler = testBundler,
       _dartDefinesReader = dartDefinesReader,
       _pubspecReader = pubspecReader,
       _androidTestBackend = androidTestBackend,
       _analytics = analytics,
       _logger = logger,
       _compatibilityChecker = compatibilityChecker {
    usesTargetOption();
    usesBuildModeOption();
    usesFlavorOption();
    usesDartDefineOption();
    usesDartDefineFromFileOption();
    usesLabelOption();
    usesPortOptions();
    usesTagsOption();
    usesExcludeTagsOption();
    usesCheckCompatibilityOption();

    usesUninstallOption();
    usesBuildNameOption();
    usesBuildNumberOption();

    usesAndroidOptions();
  }

  final TestFinderFactory _testFinderFactory;
  final TestBundler _testBundler;
  final DartDefinesReader _dartDefinesReader;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  final CompatibilityChecker _compatibilityChecker;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'android';

  @override
  String? get docsName => 'build';

  @override
  String get description => 'Build app for integration testing on Android.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(
        FlutterVersion.fromCLI(flutterCommand),
        'build_android',
      ),
    );

    final config = _pubspecReader.read();
    final testDirectory = config.testDirectory;
    final testFileSuffix = config.testFileSuffix;

    // Check compatibility between CLI and package versions
    if (boolArg('check-compatibility')) {
      final patrolVersion = _pubspecReader.getPatrolVersion();
      await _compatibilityChecker.checkVersionsCompatibilityForBuild(
        patrolVersion: patrolVersion,
      );
    }

    final testFinder = _testFinderFactory.create(testDirectory);

    final target = stringsArg('target');
    final targets = target.isNotEmpty
        ? testFinder.findTests(target, testFileSuffix)
        : testFinder.findAllTests(
            excludes: stringsArg('exclude').toSet(),
            testFileSuffix: testFileSuffix,
          );

    _logger.detail('Received ${targets.length} test target(s)');
    for (final t in targets) {
      _logger.detail('Received test target: $t');
    }

    final tags = stringArg('tags');
    final excludeTags = stringArg('exclude-tags');
    if (tags != null) {
      _logger.detail('Received tag(s): $tags');
    }
    if (excludeTags != null) {
      _logger.detail('Received exclude tag(s): $excludeTags');
    }
    final entrypoint = _testBundler.getBundledTestFile(testDirectory);
    if (boolArg('generate-bundle')) {
      _testBundler.createTestBundle(testDirectory, targets, tags, excludeTags);
    }

    final flavor = stringArg('flavor') ?? config.android.flavor;
    if (flavor != null) {
      _logger.detail('Received Android flavor: $flavor');
    }

    final buildName = stringArg('build-name');
    if (buildName != null) {
      _logger.detail('Received build name: $buildName');
    }

    final buildNumber = stringArg('build-number');
    if (buildNumber != null) {
      _logger.detail('Received build number: $buildNumber');
    }

    final packageName = stringArg('package-name') ?? config.android.packageName;

    final displayLabel = boolArg('label');
    final uninstall = boolArg('uninstall');

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_WAIT': defaultWait.toString(),
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_ANDROID_APP_NAME': config.android.appName,
      'PATROL_TEST_LABEL_ENABLED': displayLabel.toString(),
      'PATROL_TEST_DIRECTORY': config.testDirectory,
      'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE': 'false',
    }.withNullsRemoved();

    final dartDefines = {...customDartDefines, ...internalDartDefines};
    _logger.detail(
      'Received ${dartDefines.length} --dart-define(s) '
      '(${customDartDefines.length} custom, ${internalDartDefines.length} internal)',
    );
    for (final dartDefine in customDartDefines.entries) {
      _logger.detail('Received custom --dart-define: ${dartDefine.key}');
    }
    for (final dartDefine in internalDartDefines.entries) {
      _logger.detail(
        'Received internal --dart-define: ${dartDefine.key}=${dartDefine.value}',
      );
    }

    final dartDefineFromFilePaths = stringsArg('dart-define-from-file');

    final mergedDartDefines = mergeDartDefines(
      dartDefineFromFilePaths,
      dartDefines,
      _dartDefinesReader,
    );

    final flutterOpts = FlutterAppOptions(
      command: flutterCommand,
      target: entrypoint.path,
      flavor: flavor,
      buildMode: buildMode,
      dartDefines: mergedDartDefines,
      dartDefineFromFilePaths: dartDefineFromFilePaths,
      buildName: buildName,
      buildNumber: buildNumber,
    );

    final androidOpts = AndroidAppOptions(
      flutter: flutterOpts,
      packageName: packageName,
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
      uninstall: uninstall,
    );

    try {
      await _androidTestBackend.build(androidOpts);
      printApkPaths(flavor: flavor, buildMode: buildMode.androidName);
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      rethrow;
    }

    return 0;
  }

  /// Prints the paths to the APKs for the app under test and the test instrumentation app.
  ///
  /// [flavor] is the flavor of the app under test.
  /// [buildMode] is the build mode of the app under test.
  void printApkPaths({String? flavor, required String buildMode}) {
    final appApkPath = AndroidPaths.appApkPath(
      flavor: flavor,
      buildMode: buildMode,
    );
    final testApkPath = AndroidPaths.testApkPath(
      flavor: flavor,
      buildMode: buildMode,
    );

    _logger
      ..info('$appApkPath (app under test)')
      ..info('$testApkPath (test instrumentation app)');
  }
}
