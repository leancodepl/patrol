import 'dart:async';

import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';

class BuildIOSCommand extends PatrolCommand {
  BuildIOSCommand({
    required TestFinder testFinder,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required IOSTestBackend iosTestBackend,
    required Analytics analytics,
    required Logger logger,
  })  : _testFinder = testFinder,
        _testBundler = testBundler,
        _dartDefinesReader = dartDefinesReader,
        _pubspecReader = pubspecReader,
        _iosTestBackend = iosTestBackend,
        _analytics = analytics,
        _logger = logger {
    usesTargetOption();
    usesBuildModeOption();
    usesFlavorOption();
    usesDartDefineOption();
    usesDartDefineFromFileOption();
    usesLabelOption();
    usesWaitOption();
    usesPortOptions();
    usesTagsOption();
    usesExcludeTagsOption();

    usesIOSOptions();
    argParser.addFlag(
      'simulator',
      help: 'Build for simulator instead of real device.',
    );
  }

  final TestFinder _testFinder;
  final TestBundler _testBundler;
  final DartDefinesReader _dartDefinesReader;
  final PubspecReader _pubspecReader;
  final IOSTestBackend _iosTestBackend;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'ios';

  @override
  String? get docsName => 'build';

  @override
  String get description => 'Build app for integration testing on iOS.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(
        FlutterVersion.fromCLI(flutterCommand),
        'build_ios',
      ),
    );

    final config = _pubspecReader.read();
    final testFileSuffix = config.testFileSuffix;

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

    final flavor = stringArg('flavor') ?? config.ios.flavor;
    if (flavor != null) {
      _logger.detail('Received iOS flavor: $flavor');
    }

    final bundleId = stringArg('bundle-id') ?? config.ios.bundleId;

    final displayLabel = boolArg('label');

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_WAIT': defaultWait.toString(),
      'PATROL_APP_BUNDLE_ID': bundleId,
      'PATROL_IOS_APP_NAME': config.ios.appName,
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
    );

    final iosOpts = IOSAppOptions(
      flutter: flutterOpts,
      scheme: flutterOpts.buildMode.createScheme(flavor),
      configuration: flutterOpts.buildMode.createConfiguration(flavor),
      simulator: boolArg('simulator'),
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
      clearPermissions: boolArg('clear-permissions'),
    );

    try {
      await _iosTestBackend.build(iosOpts);
      _printBinaryPaths(
        simulator: iosOpts.simulator,
        buildMode: flutterOpts.buildMode.xcodeName,
      );
      await _printXcTestRunPath(
        simulator: iosOpts.simulator,
        scheme: iosOpts.scheme,
      );
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      rethrow;
    }

    return 0;
  }

  void _printBinaryPaths({required bool simulator, required String buildMode}) {
    // print path for 2 apps that live in build/ios_integ/Build/Products

    final testRoot = join('build', 'ios_integ', 'Build', 'Products');
    final buildDir = simulator
        ? join(testRoot, '$buildMode-iphonesimulator')
        : join(testRoot, '$buildMode-iphoneos');

    final appPath = join(buildDir, 'Runner.app');
    final testAppPath = join(buildDir, 'RunnerUITests-Runner.app');

    _logger
      ..info('$appPath (app under test)')
      ..info('$testAppPath (test instrumentation app)');
  }

  Future<void> _printXcTestRunPath({
    required bool simulator,
    required String scheme,
  }) async {
    final sdkVersion = await _iosTestBackend.getSdkVersion(real: !simulator);
    final xcTestRunPath = await _iosTestBackend.xcTestRunPath(
      real: !simulator,
      scheme: scheme,
      sdkVersion: sdkVersion,
      absolutePath: false,
    );

    _logger.info('$xcTestRunPath (xctestrun file)');
  }
}
