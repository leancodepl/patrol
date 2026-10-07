import 'dart:async';

import 'package:path/path.dart' show dirname, relative;
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/linux/linux_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';

class BuildLinuxCommand extends PatrolCommand {
  BuildLinuxCommand({
    required TestFinderFactory testFinderFactory,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required LinuxTestBackend linuxTestBackend,
    required Analytics analytics,
    required Logger logger,
    required CompatibilityChecker compatibilityChecker,
  }) : _testFinderFactory = testFinderFactory,
       _testBundler = testBundler,
       _dartDefinesReader = dartDefinesReader,
       _pubspecReader = pubspecReader,
       _linuxTestBackend = linuxTestBackend,
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
  }

  final TestFinderFactory _testFinderFactory;
  final TestBundler _testBundler;
  final DartDefinesReader _dartDefinesReader;
  final PubspecReader _pubspecReader;
  final LinuxTestBackend _linuxTestBackend;
  final CompatibilityChecker _compatibilityChecker;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'linux';

  @override
  String? get docsName => 'build';

  @override
  String get description => 'Build app for integration testing on Linux.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(
        FlutterVersion.fromCLI(flutterCommand),
        'build_linux',
      ),
    );

    final config = _pubspecReader.read();
    final testDirectory = config.testDirectory;
    final testFileSuffix = config.testFileSuffix;

    if (boolArg('check-compatibility')) {
      final patrolVersion = _pubspecReader.getPatrolVersion();
      await _compatibilityChecker.checkVersionsCompatibilityForBuild(
        patrolVersion: patrolVersion,
      );
    }

    final testFinder = _testFinderFactory.create(testDirectory);
    final excludes = stringsArg('exclude').toSet();

    final target = stringsArg('target');
    final targets = target.isNotEmpty
        ? testFinder.findTests(target, testFileSuffix, excludes)
        : testFinder.findAllTests(
            excludes: excludes,
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
    if (boolArg('generate-bundle')) {
      _testBundler.createTestBundle(testDirectory, targets, tags, excludeTags);
    }
    final entrypoint = _testBundler.getBundledTestFile(testDirectory);

    // Linux has no pubspec config, so the flavor comes only from --flavor.
    final flavor = stringArg('flavor');
    if (flavor != null) {
      _logger.detail('Received Linux flavor: $flavor');
    }

    final buildName = stringArg('build-name');
    if (buildName != null) {
      _logger.detail('Received build name: $buildName');
    }

    final buildNumber = stringArg('build-number');
    if (buildNumber != null) {
      _logger.detail('Received build number: $buildNumber');
    }

    final displayLabel = boolArg('label');

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_WAIT': defaultWait.toString(),
      'PATROL_TEST_LABEL_ENABLED': displayLabel.toString(),
      'PATROL_TEST_DIRECTORY': config.testDirectory,
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

    final flutterOpts = FlutterAppOptions(
      command: flutterCommand,
      target: entrypoint.path,
      flavor: flavor,
      buildMode: buildMode,
      dartDefines: dartDefines,
      dartDefineFromFilePaths: stringsArg('dart-define-from-file'),
      buildName: buildName,
      buildNumber: buildNumber,
    );

    final linuxOpts = LinuxAppOptions(
      flutter: flutterOpts,
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
    );

    try {
      await _linuxTestBackend.build(linuxOpts);

      final binaryPath = await _linuxTestBackend.resolveBinaryPath(linuxOpts);
      final bundlePath = relative(dirname(binaryPath));
      _logger.info('$bundlePath (app bundle)');
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      rethrow;
    }

    return 0;
  }
}
