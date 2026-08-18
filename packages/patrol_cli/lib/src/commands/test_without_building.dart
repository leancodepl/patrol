import 'dart:async';

import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';

/// Runs tests that were already built, without rebuilding anything.
///
/// This is the counterpart of `patrol build`: it reuses that build's artifacts
/// and only asks the native runner to execute tests. It exists as its own
/// command rather than a flag on `patrol test` because it is a different
/// operation - nothing is bundled, built or reinstalled - so the flags that
/// shape a build (`--target`, `--tags`, `--dart-define`, ...) simply don't apply
/// here and aren't accepted.
///
/// Requires build-time test discovery: the tests are selected natively, which is
/// only possible because `patrol build --emit-test-manifest` generated a real
/// native test per Dart test.
class TestWithoutBuildingCommand extends PatrolCommand {
  TestWithoutBuildingCommand({
    required DeviceFinder deviceFinder,
    required TestBundler testBundler,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required Analytics analytics,
    required Logger logger,
  }) : _deviceFinder = deviceFinder,
       _testBundler = testBundler,
       _pubspecReader = pubspecReader,
       _androidTestBackend = androidTestBackend,
       _iosTestBackend = iosTestBackend,
       _analytics = analytics,
       _logger = logger {
    // Only options that affect *running* prebuilt artifacts: which device, which
    // artifacts (build mode + flavor), which tests, and how results are shown.
    usesDeviceOption();
    usesBuildModeSelectionOption();
    usesFlavorOption();
    usesPortOptions();
    usesOnlyOption();
    usesShowFlutterLogs();
    usesHideTestSteps();
    usesClearTestSteps();
    usesHtmlReportOptions();

    usesAndroidOptions();
    argParser
      ..addOption(
        'bundle-id',
        help: 'Bundle identifier of the iOS app under test.',
        valueHelp: 'pl.leancode.AwesomeApp',
      )
      ..addOption(
        'ios',
        help:
            'Pass iOS version. If empty, `latest` will be used. This flag only '
            'works with iOS simulator.',
        valueHelp: '17.5',
      );
  }

  final DeviceFinder _deviceFinder;
  final TestBundler _testBundler;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  final IOSTestBackend _iosTestBackend;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'test-without-building';

  @override
  String get description =>
      'Run already-built integration tests, without rebuilding them.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(
        FlutterVersion.fromCLI(flutterCommand),
        'test_without_building',
      ),
    );

    final config = _pubspecReader.read();

    final wantDevices = stringsArg('device');
    final bundledDevice = switch (wantDevices) {
      [final name] => Device.bundledForTest(name),
      _ => null,
    };
    final devices = bundledDevice != null
        ? [bundledDevice]
        : await _deviceFinder.find(wantDevices, flutterCommand: flutterCommand);
    final device = devices.single;

    if (device.targetPlatform != TargetPlatform.android &&
        device.targetPlatform != TargetPlatform.iOS) {
      _logger.err(
        'patrol test-without-building supports Android and iOS only.',
      );
      return 1;
    }

    final onlyTests = stringsArg('only');
    final flavor = switch (device.targetPlatform) {
      TargetPlatform.android => stringArg('flavor') ?? config.android.flavor,
      _ => stringArg('flavor') ?? config.ios.flavor,
    };

    // The entrypoint isn't rebuilt; it only identifies the artifacts to run.
    final entrypoint = _testBundler.getBundledTestFile(config.testDirectory);

    final flutterOpts = FlutterAppOptions(
      command: flutterCommand,
      target: entrypoint.path,
      flavor: flavor,
      buildMode: buildMode,
      dartDefines: const {},
      dartDefineFromFilePaths: const [],
      buildName: null,
      buildNumber: null,
    );

    final showFlutterLogs = boolArg('show-flutter-logs');
    final hideTestSteps = boolArg('hide-test-steps');
    final clearTestSteps = boolArg('clear-test-steps');
    final dashboardConfig = htmlReportConfig(config.testDirectory);

    try {
      switch (device.targetPlatform) {
        case TargetPlatform.android:
          await _androidTestBackend.executeWithoutBuilding(
            AndroidAppOptions(
              flutter: flutterOpts,
              packageName:
                  stringArg('package-name') ?? config.android.packageName,
              appServerPort: super.appServerPort,
              testServerPort: super.testServerPort,
              uninstall: false,
              emitTestManifest: true,
            ),
            device,
            flavor: flavor,
            showFlutterLogs: showFlutterLogs,
            hideTestSteps: hideTestSteps,
            clearTestSteps: clearTestSteps,
            onlyTests: onlyTests,
            dashboardConfig: dashboardConfig,
          );
        case TargetPlatform.iOS:
          await _iosTestBackend.execute(
            IOSAppOptions(
              flutter: flutterOpts,
              bundleId: stringArg('bundle-id') ?? config.ios.bundleId,
              scheme: buildMode.createScheme(flavor),
              configuration: buildMode.createConfiguration(flavor),
              simulator: !device.real,
              osVersion: stringArg('ios') ?? 'latest',
              appServerPort: super.appServerPort,
              testServerPort: super.testServerPort,
              emitTestManifest: true,
            ),
            device,
            showFlutterLogs: showFlutterLogs,
            hideTestSteps: hideTestSteps,
            clearTestSteps: clearTestSteps,
            onlyTests: onlyTests,
            dashboardConfig: dashboardConfig,
          );
        case TargetPlatform.macOS:
        case TargetPlatform.web:
          return 1; // unreachable, guarded above
      }
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      return 1;
    }

    return 0;
  }
}
