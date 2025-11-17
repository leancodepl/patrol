import 'dart:async';

import 'package:meta/meta.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';

class BuildMacOSCommand extends PatrolCommand {
  BuildMacOSCommand({
    required TestFinder testFinder,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required MacOSTestBackend macosTestBackend,
    required Analytics analytics,
    required Logger logger,
    required CompatibilityChecker compatibilityChecker,
  }) : _testFinder = testFinder,
       _testBundler = testBundler,
       _dartDefinesReader = dartDefinesReader,
       _pubspecReader = pubspecReader,
       _macosTestBackend = macosTestBackend,
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
    usesBuildNameOption();
    usesBuildNumberOption();

    usesMacOSOptions();
  }

  final TestFinder _testFinder;
  final TestBundler _testBundler;
  final DartDefinesReader _dartDefinesReader;
  final PubspecReader _pubspecReader;
  final MacOSTestBackend _macosTestBackend;
  final CompatibilityChecker _compatibilityChecker;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'macos';

  @override
  String? get docsName => 'build';

  @override
  String get description => 'Build app for integration testing on MacOS.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(
        FlutterVersion.fromCLI(flutterCommand),
        'build_macos',
      ),
    );

    final config = _pubspecReader.read();
    final testFileSuffix = config.testFileSuffix;

    final latestVersion = await pubUpdater.getLatestVersion('patrol_cli');
    const currentVersion = constants.version;

    await checkForUpdates(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      compatibilityChecker: _compatibilityChecker,
      logger: _logger,
    );

    // Check compatibility between CLI and package versions
    if (boolArg('check-compatibility')) {
      //final patrolVersion = _pubspecReader.getPatrolVersion();
      await _compatibilityChecker.checkVersionsCompatibility(
        flutterCommand: flutterCommand,
        targetPlatform: TargetPlatform.macOS,
        //patrolVersion: patrolVersion,
      );
    }

    final target = stringsArg('target');
    final targets = target.isNotEmpty
        ? _testFinder.findTests(target, testFileSuffix)
        : _testFinder.findAllTests(
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
    final entrypoint = _testBundler.bundledTestFile;
    if (boolArg('generate-bundle')) {
      _testBundler.createTestBundle(targets, tags, excludeTags);
    }

    final flavor = stringArg('flavor') ?? config.macos.flavor;
    if (flavor != null) {
      _logger.detail('Received macOS flavor: $flavor');
    }

    final buildName = stringArg('build-name');
    if (buildName != null) {
      _logger.detail('Received build name: $buildName');
    }

    final buildNumber = stringArg('build-number');
    if (buildNumber != null) {
      _logger.detail('Received build number: $buildNumber');
    }

    final bundleId = stringArg('bundle-id') ?? config.macos.bundleId;

    final displayLabel = boolArg('label');

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_WAIT': defaultWait.toString(),
      'PATROL_MACOS_APP_BUNDLE_ID': bundleId,
      'PATROL_MACOS_APP_NAME': config.macos.appName,
      'PATROL_TEST_LABEL_ENABLED': displayLabel.toString(),
      'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE': 'false',
      'PATROL_TEST_SERVER_PORT': super.testServerPort.toString(),
      'PATROL_APP_SERVER_PORT': super.appServerPort.toString(),
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

    final flutterOpts = FlutterAppOptions(
      command: flutterCommand,
      target: entrypoint.path,
      flavor: flavor,
      buildMode: buildMode,
      dartDefines: dartDefines,
      dartDefineFromFilePaths: dartDefineFromFilePaths,
      buildName: buildName,
      buildNumber: buildNumber,
    );

    final macosOpts = MacOSAppOptions(
      flutter: flutterOpts,
      scheme: flutterOpts.buildMode.createScheme(flavor),
      configuration: flutterOpts.buildMode.createConfiguration(flavor),
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
    );

    try {
      await _macosTestBackend.build(macosOpts);

      printBinaryPaths(buildMode: flutterOpts.buildMode.xcodeName);

      await printXcTestRunPath(scheme: macosOpts.scheme);
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      rethrow;
    }

    return 0;
  }

  @visibleForTesting
  void printBinaryPaths({required String buildMode}) {
    // print path for 2 apps that live in build/macos_integ/Build/Products

    final buildDir = join(
      'build',
      'macos_integ',
      'Build',
      'Products',
      buildMode,
    );

    final appPath = join(buildDir, 'Runner.app');
    final testAppPath = join(buildDir, 'RunnerUITests-Runner.app');

    _logger
      ..info('$appPath (app under test)')
      ..info('$testAppPath (test instrumentation app)');
  }

  @visibleForTesting
  Future<void> printXcTestRunPath({required String scheme}) async {
    final sdkVersion = await _macosTestBackend.getSdkVersion();
    final xcTestRunPath = await _macosTestBackend.xcTestRunPath(
      scheme: scheme,
      sdkVersion: sdkVersion,
      absolutePath: false,
    );

    _logger.info('$xcTestRunPath (xctestrun file)');
  }
}
