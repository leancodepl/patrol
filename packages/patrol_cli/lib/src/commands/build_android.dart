import 'dart:async';

import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';

class BuildAndroidCommand extends PatrolCommand {
  BuildAndroidCommand({
    required TestFinder testFinder,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required Analytics analytics,
    required Logger logger,
  })  : _testFinder = testFinder,
        _testBundler = testBundler,
        _dartDefinesReader = dartDefinesReader,
        _pubspecReader = pubspecReader,
        _androidTestBackend = androidTestBackend,
        _analytics = analytics,
        _logger = logger {
    usesTargetOption();
    usesBuildModeOption();
    usesFlavorOption();
    usesDartDefineOption();
    usesLabelOption();
    usesWaitOption();

    usesAndroidOptions();
  }

  final TestFinder _testFinder;
  final TestBundler _testBundler;
  final DartDefinesReader _dartDefinesReader;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;

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
    unawaited(_analytics.sendCommand('build_android'));

    final target = stringsArg('target');
    final targets = target.isNotEmpty
        ? _testFinder.findTests(target)
        : _testFinder.findAllTests(excludes: stringsArg('exclude').toSet());

    _logger.detail('Received ${targets.length} test target(s)');
    for (final t in targets) {
      _logger.detail('Received test target: $t');
    }

    final entrypoint = _testBundler.bundledTestFile;
    if (boolArg('generate-bundle')) {
      _testBundler.createTestBundle(targets);
    }

    final config = _pubspecReader.read();
    final flavor = stringArg('flavor') ?? config.android.flavor;
    if (flavor != null) {
      _logger.detail('Received Android flavor: $flavor');
    }

    final packageName = stringArg('package-name') ?? config.android.packageName;

    final displayLabel = boolArg('label');

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_WAIT': defaultWait.toString(),
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_ANDROID_APP_NAME': config.android.appName,
      'PATROL_TEST_LABEL_ENABLED': displayLabel.toString(),
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

    final flutterOpts = FlutterAppOptions(
      target: entrypoint.path,
      flavor: flavor,
      buildMode: buildMode,
      dartDefines: dartDefines,
    );
    final androidOpts = AndroidAppOptions(
      flutter: flutterOpts,
      packageName: packageName,
    );

    try {
      await _androidTestBackend.build(androidOpts);
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
