import 'dart:async';

import 'package:file/file.dart';
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/compatibility_checker.dart';
import 'package:patrol_cli/src/coverage/coverage_collector.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';

class TestCommand extends PatrolCommand {
  TestCommand({
    required DeviceFinder deviceFinder,
    required TestFinder testFinder,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required CompatibilityChecker compatibilityChecker,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required MacOSTestBackend macOSTestBackend,
    required Directory packageDirectory,
    required Analytics analytics,
    required Logger logger,
  })  : _deviceFinder = deviceFinder,
        _testBundler = testBundler,
        _testFinder = testFinder,
        _dartDefinesReader = dartDefinesReader,
        _compatibilityChecker = compatibilityChecker,
        _pubspecReader = pubspecReader,
        _androidTestBackend = androidTestBackend,
        _iosTestBackend = iosTestBackend,
        _macosTestBackend = macOSTestBackend,
        _packageDirectory = packageDirectory,
        _analytics = analytics,
        _logger = logger {
    usesTargetOption();
    usesDeviceOption();
    usesBuildModeOption();
    usesFlavorOption();
    usesDartDefineOption();
    usesLabelOption();
    usesWaitOption();
    usesPortOptions();
    _usesCoverageOption();

    usesUninstallOption();

    usesAndroidOptions();
    usesIOSOptions();
  }

  final DeviceFinder _deviceFinder;
  final TestFinder _testFinder;
  final TestBundler _testBundler;
  final DartDefinesReader _dartDefinesReader;
  final CompatibilityChecker _compatibilityChecker;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  final IOSTestBackend _iosTestBackend;
  final MacOSTestBackend _macosTestBackend;
  final Directory _packageDirectory;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'test';

  @override
  String get description => 'Run integration tests.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(
        FlutterVersion.fromCLI(flutterCommand),
        name,
      ),
    );

    await _compatibilityChecker.checkVersionsCompatibility(
      flutterCommand: flutterCommand,
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

    final entrypoint = _testBundler.bundledTestFile;
    if (boolArg('generate-bundle')) {
      _testBundler.createTestBundle(targets);
    }

    final androidFlavor = stringArg('flavor') ?? config.android.flavor;
    final iosFlavor = stringArg('flavor') ?? config.ios.flavor;
    final macosFlavor = stringArg('flavor') ?? config.macos.flavor;
    if (androidFlavor != null) {
      _logger.detail('Received Android flavor: $androidFlavor');
    }
    if (iosFlavor != null) {
      _logger.detail('Received iOS flavor: $iosFlavor');
    }
    if (macosFlavor != null) {
      _logger.detail('Received macOS flavor: $macosFlavor');
    }

    final devices = await _deviceFinder.find(
      stringsArg('device'),
      flutterCommand: flutterCommand,
    );
    _logger.detail('Received ${devices.length} device(s) to run on');
    for (final device in devices) {
      _logger.detail('Received device: ${device.resolvedName}');
    }

    if (devices.length > 1) {
      // TODO: Throw an error when running on more than 1 device
      _logger.warn('''
Running on multiple devices is deprecated and will be removed in the future.
See https://github.com/leancodepl/patrol/issues/1316 to learn more.
''');
    }

    final device = devices.single;

    final packageName = stringArg('package-name') ?? config.android.packageName;
    final bundleId = stringArg('bundle-id') ?? config.ios.bundleId;
    final macosBundleId = stringArg('bundle-id') ?? config.macos.bundleId;

    final wait = intArg('wait') ?? defaultWait;
    final displayLabel = boolArg('label');
    final uninstall = boolArg('uninstall');

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_WAIT': wait.toString(),
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_APP_BUNDLE_ID': bundleId,
      'PATROL_MACOS_APP_BUNDLE_ID': macosBundleId,
      'PATROL_ANDROID_APP_NAME': config.android.appName,
      'PATROL_IOS_APP_NAME': config.ios.appName,
      'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE': 'false',
      'PATROL_TEST_LABEL_ENABLED': displayLabel.toString(),
      'PATROL_TEST_SERVER_PORT': super.testServerPort.toString(),
      'PATROL_APP_SERVER_PORT': super.appServerPort.toString(),
      'COVERAGE_ENABLED': shouldGenerateCoverage.toString(),
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
      flavor: androidFlavor,
      buildMode: buildMode,
      dartDefines: dartDefines,
    );

    final androidOpts = AndroidAppOptions(
      flutter: flutterOpts,
      packageName: packageName,
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
    );

    final iosOpts = IOSAppOptions(
      flutter: flutterOpts,
      bundleId: bundleId,
      scheme: buildMode.createScheme(iosFlavor),
      configuration: buildMode.createConfiguration(iosFlavor),
      simulator: !device.real,
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
    );

    final macosOpts = MacOSAppOptions(
      flutter: flutterOpts,
      scheme: buildMode.createScheme(macosFlavor),
      configuration: buildMode.createConfiguration(macosFlavor),
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
    );

    await _build(androidOpts, iosOpts, macosOpts, device);
    await _preExecute(androidOpts, iosOpts, macosOpts, device, uninstall);

    if (shouldGenerateCoverage) {
      await runCodeCoverage(
        flutterPackageName: config.flutterPackageName,
        flutterPackageDirectory: _packageDirectory,
        platform: device.targetPlatform,
        logger: _logger,
      );
    }

    final allPassed = await _execute(
      flutterOpts,
      androidOpts,
      iosOpts,
      macosOpts,
      uninstall: uninstall,
      device: device,
    );

    return allPassed ? 0 : 1;
  }

  /// Uninstall the apps before running the tests.
  Future<void> _preExecute(
    AndroidAppOptions androidOpts,
    IOSAppOptions iosOpts,
    MacOSAppOptions macosOpts,
    Device device,
    bool uninstall,
  ) async {
    if (!uninstall) {
      return;
    }
    _logger.detail('Will uninstall apps before running tests');

    late Future<void> Function()? action;
    switch (device.targetPlatform) {
      case TargetPlatform.android:
        final packageName = androidOpts.packageName;
        if (packageName != null) {
          action = () => _androidTestBackend.uninstall(packageName, device);
        }
      case TargetPlatform.iOS:
        final bundleId = iosOpts.bundleId;
        if (bundleId != null) {
          action = () => _iosTestBackend.uninstall(
                appId: bundleId,
                flavor: iosOpts.flutter.flavor,
                device: device,
              );
        }
      case TargetPlatform.macOS:
    }

    try {
      await action?.call();
    } catch (_) {
      // ignore any failures, we don't care
    }
  }

  Future<void> _build(
    AndroidAppOptions androidOpts,
    IOSAppOptions iosOpts,
    MacOSAppOptions macosOpts,
    Device device,
  ) async {
    final buildAction = switch (device.targetPlatform) {
      TargetPlatform.android => () => _androidTestBackend.build(androidOpts),
      TargetPlatform.macOS => () => _macosTestBackend.build(macosOpts),
      TargetPlatform.iOS => () => _iosTestBackend.build(iosOpts),
    };

    try {
      await buildAction();
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      rethrow;
    }
  }

  Future<bool> _execute(
    FlutterAppOptions flutterOpts,
    AndroidAppOptions android,
    IOSAppOptions ios,
    MacOSAppOptions macos, {
    required bool uninstall,
    required Device device,
  }) async {
    Future<void> Function() action;
    Future<void> Function()? finalizer;

    switch (device.targetPlatform) {
      case TargetPlatform.android:
        action = () => _androidTestBackend.execute(android, device);
        final package = android.packageName;
        if (package != null && uninstall) {
          finalizer = () => _androidTestBackend.uninstall(package, device);
        }
      case TargetPlatform.macOS:
        action = () async => _macosTestBackend.execute(macos, device);
      case TargetPlatform.iOS:
        action = () async => _iosTestBackend.execute(ios, device);
        final bundleId = ios.bundleId;
        if (bundleId != null && uninstall) {
          finalizer = () => _iosTestBackend.uninstall(
                appId: bundleId,
                flavor: ios.flutter.flavor,
                device: device,
              );
        }
    }

    var allPassed = true;
    try {
      await action();
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      allPassed = false;
    } finally {
      try {
        await finalizer?.call();
      } catch (err) {
        _logger.err('Failed to call finalizer: $err');
        rethrow;
      }
    }

    return allPassed;
  }

  void _usesCoverageOption() {
    argParser.addFlag(
      'coverage',
      help: 'Generate coverage.',
    );
  }

  bool get shouldGenerateCoverage => boolArg('coverage');
}
