import 'dart:async';

import 'package:file/file.dart';
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/web/web_artifact.dart';
import 'package:patrol_cli/src/web/web_static_server.dart';
import 'package:patrol_cli/src/web/web_test_backend.dart';

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
///
/// On web there is no device and no native runner: `--input` points at a
/// directory from `patrol build web`, which this command serves and drives with
/// the Playwright runner shipped inside it. Nothing there needs Flutter.
class TestWithoutBuildingCommand extends PatrolCommand {
  TestWithoutBuildingCommand({
    required DeviceFinder deviceFinder,
    required TestBundler testBundler,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required WebTestBackend webTestBackend,
    required FileSystem fs,
    required Analytics analytics,
    required Logger logger,
  }) : _deviceFinder = deviceFinder,
       _testBundler = testBundler,
       _pubspecReader = pubspecReader,
       _androidTestBackend = androidTestBackend,
       _iosTestBackend = iosTestBackend,
       _webTestBackend = webTestBackend,
       _fs = fs,
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

    usesAndroidOptions();
    usesWeb();
    argParser
      ..addOption(
        'input',
        help:
            'Directory produced by `patrol build web`. Runs that artifact '
            'instead of anything installed on a device.',
        valueHelp: 'build/patrol-web',
      )
      ..addOption(
        'base-url',
        help:
            'Serve the app yourself and point Patrol at it, instead of letting '
            '`--input` serve it. Requires --input for the runner.',
        valueHelp: 'http://localhost:8080',
      )
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
  final WebTestBackend _webTestBackend;
  final FileSystem _fs;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'test-without-building';

  @override
  String get description =>
      'Run already-built integration tests, without rebuilding them.';

  @override
  Future<int> run() async {
    final flutterVersion = FlutterVersion.tryFromCLI(flutterCommand);
    if (flutterVersion != null) {
      unawaited(
        _analytics.sendCommand(flutterVersion, 'test_without_building'),
      );
    }

    final input = stringArg('input');
    if (input != null) {
      return _runPrebuiltWeb(input);
    }
    if (stringArg('base-url') != null) {
      _logger.err('--base-url only applies to a web artifact. Pass --input.');
      return 1;
    }

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

  /// Runs a directory built by `patrol build web`.
  Future<int> _runPrebuiltWeb(String input) async {
    if (stringArg('flavor') != null) {
      _logger.err('Flavors are not supported on web. Remove --flavor.');
      return 1;
    }

    final artifact = WebArtifact.at(input, fs: _fs);
    final problem = artifact.problem;
    if (problem != null) {
      _logger
        ..err(problem)
        ..err('Build one with: patrol build web --output $input');
      return 1;
    }

    final options = WebAppOptions(
      // Nothing is compiled here; these only satisfy the shared options type.
      flutter: FlutterAppOptions(
        command: flutterCommand,
        target: '',
        flavor: null,
        buildMode: buildMode,
        dartDefines: const {},
        dartDefineFromFilePaths: const [],
        buildName: null,
        buildNumber: null,
      ),
      resultsDir: stringArg('web-results-dir'),
      reportDir: stringArg('web-report-dir'),
      retries: intArg('web-retries'),
      video: stringArg('web-video'),
      timeout: intArg('web-timeout'),
      workers: intArg('web-workers'),
      reporter: stringArg('web-reporter'),
      locale: stringArg('web-locale'),
      timezone: stringArg('web-timezone'),
      colorScheme: stringArg('web-color-scheme'),
      geolocation: stringArg('web-geolocation'),
      permissions: stringArg('web-permissions'),
      userAgent: stringArg('web-user-agent'),
      viewport: stringArg('web-viewport'),
      globalTimeout: intArg('web-global-timeout'),
      shard: stringArg('web-shard'),
      headless: optionalBoolArg('web-headless'),
      webPort: intArg('web-port'),
      browserArgs: stringArg('web-browser-args'),
      channel: stringArg('web-channel'),
      executablePath: stringArg('web-executable-path'),
      slowMo: intArg('web-slow-mo'),
      chromiumSandbox: optionalBoolArg('web-chromium-sandbox'),
      downloadsPath: stringArg('web-downloads-path'),
      ignoreDefaultArgs: stringArg('web-ignore-default-args'),
      proxy: stringArg('web-proxy'),
      browserTimeout: intArg('web-browser-timeout'),
      tracesDir: stringArg('web-traces-dir'),
      bypassCsp: optionalBoolArg('web-bypass-csp'),
      ignoreHttpsErrors: optionalBoolArg('web-ignore-https-errors'),
      offline: optionalBoolArg('web-offline'),
      httpCredentials: stringArg('web-http-credentials'),
      extraHttpHeaders: stringArg('web-extra-http-headers'),
      screenshot: stringArg('web-screenshot'),
      trace: stringArg('web-trace'),
      storageState: stringArg('web-storage-state'),
      acceptDownloads: optionalBoolArg('web-accept-downloads'),
    );

    final externalBaseUrl = stringArg('base-url');
    final server = externalBaseUrl != null
        ? null
        : await WebStaticServer.serve(
            artifact.appDir,
            port: options.webPort,
            logger: _logger,
          );

    if (server != null) {
      _logger.info('Serving ${artifact.appDir.path} at ${server.baseUrl}');
    }

    try {
      await _webTestBackend.executePrebuilt(
        options,
        baseUrl: externalBaseUrl ?? server!.baseUrl,
        runnerPath: artifact.runnerDir.absolute.path,
        showFlutterLogs: boolArg('show-flutter-logs'),
        hideTestSteps: boolArg('hide-test-steps'),
        clearTestSteps: boolArg('clear-test-steps'),
      );
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      return 1;
    } finally {
      await server?.close();
    }

    return 0;
  }
}
