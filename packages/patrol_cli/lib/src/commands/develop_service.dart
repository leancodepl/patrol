import 'dart:async';
import 'dart:io';

import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/dart_define_utils.dart';
import 'package:patrol_cli/src/commands/develop_options.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart' hide BuildMode;
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';
import 'package:patrol_cli/src/web/web_test_backend.dart';
import 'package:patrol_log/patrol_log.dart';

/// Result of a completed test execution within a develop session.
class TestCompletionResult {
  const TestCompletionResult({required this.success, this.error});

  /// Whether the test backend exited successfully (exit code 0).
  final bool success;

  /// The error if the test backend failed, or `null` on success.
  final Object? error;
}

/// Orchestrates a patrol develop session.
///
/// This service contains the core logic previously in [DevelopCommand.run()],
/// extracted so it can be called from both the CLI and the MCP server.
class DevelopService {
  DevelopService({
    required DeviceFinder deviceFinder,
    required TestFinderFactory testFinderFactory,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required CompatibilityChecker compatibilityChecker,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required MacOSTestBackend macosTestBackend,
    required WebTestBackend webTestBackend,
    required FlutterTool flutterTool,
    required Logger logger,
    required Stream<List<int>> stdin,
    this.onTestsCompleted,
    this.onEntry,
  }) : _deviceFinder = deviceFinder,
       _testFinderFactory = testFinderFactory,
       _testBundler = testBundler,
       _dartDefinesReader = dartDefinesReader,
       _compatibilityChecker = compatibilityChecker,
       _pubspecReader = pubspecReader,
       _androidTestBackend = androidTestBackend,
       _iosTestBackend = iosTestBackend,
       _macosTestBackend = macosTestBackend,
       _webTestBackend = webTestBackend,
       _flutterTool = flutterTool,
       _logger = logger,
       _stdin = stdin;

  /// Optional callback invoked when the test backend process finishes,
  /// before [run] itself returns. This allows callers (e.g. MCP) to react
  /// to test completion without waiting for the full develop session
  /// (including flutter attach) to tear down.
  final void Function(TestCompletionResult result)? onTestsCompleted;
  final void Function(Entry entry)? onEntry;

  final DeviceFinder _deviceFinder;
  final TestFinderFactory _testFinderFactory;
  final TestBundler _testBundler;
  final DartDefinesReader _dartDefinesReader;
  final CompatibilityChecker _compatibilityChecker;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  final IOSTestBackend _iosTestBackend;
  final MacOSTestBackend _macosTestBackend;
  final WebTestBackend _webTestBackend;
  final FlutterTool _flutterTool;
  final Logger _logger;
  final Stream<List<int>> _stdin;

  Device? _device;

  /// The device discovered during the last [run] call.
  Device? get device => _device;

  /// Runs the full develop flow: discover device, read config, bundle test,
  /// build, execute, and attach for hot restart.
  Future<void> run(DevelopOptions options) async {
    final config = _pubspecReader.read();
    final testDirectory = config.testDirectory;

    final testFinder = _testFinderFactory.create(testDirectory);
    final target = testFinder.findTest(options.target, config.testFileSuffix);
    _logger.detail('Received test target: $target');

    if (options.buildMode == BuildMode.release) {
      throwToolExit('Cannot use release build mode with develop');
    }

    if (options.generateBundle) {
      _testBundler.createDevelopTestBundle(testDirectory, target);
    }
    _testBundler.ensureEntrypoint(testDirectory);
    final entrypoint = _testBundler.getEntrypointFile(testDirectory);
    final signalSubscriptions = _registerProxyCleanupOnSignals(testDirectory);
    Future<void> cleanupProxy() async {
      _testBundler.deleteEntrypointProxy(testDirectory);
    }

    final androidFlavor = options.flavor ?? config.android.flavor;
    final iosFlavor = options.flavor ?? config.ios.flavor;
    if (androidFlavor != null) {
      _logger.detail('Received Android flavor: $androidFlavor');
    }
    if (iosFlavor != null) {
      _logger.detail('Received iOS flavor: $iosFlavor');
    }

    if (options.buildName != null) {
      _logger.detail('Received build name: ${options.buildName}');
    }
    if (options.buildNumber != null) {
      _logger.detail('Received build number: ${options.buildNumber}');
    }

    final devices = await _deviceFinder.find(
      options.devices,
      flutterCommand: options.flutterCommand,
    );
    final device = devices.single;
    _device = device;

    if (options.checkCompatibility) {
      await _compatibilityChecker.checkVersionsCompatibility(
        flutterCommand: options.flutterCommand,
        targetPlatform: device.targetPlatform,
      );
    }

    // `flutter logs` doesn't work on macOS, so we don't support it for now
    // https://github.com/leancodepl/patrol/issues/1974
    if (device.targetPlatform == TargetPlatform.macOS) {
      throwToolExit('macOS is not supported with develop');
    }

    // Changes applied outside `/lib` directory are not 'hot-restarted'.
    // This is a blocker from applying changes to test code.
    // https://github.com/flutter/flutter/issues/175318
    if (device.targetPlatform == TargetPlatform.web) {
      throwToolExit('Web is not supported with develop');
    }

    _logger.detail('Received device: ${device.name} (${device.id})');

    final packageName = options.packageName ?? config.android.packageName;
    final bundleId = options.bundleId ?? config.ios.bundleId;

    String? iOSInstalledAppsEnvVariable;
    if (device.targetPlatform == TargetPlatform.iOS) {
      iOSInstalledAppsEnvVariable =
          await _iosTestBackend.getInstalledAppsEnvVariable(device.id);
    }

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: options.dartDefines),
    };
    final internalDartDefines = {
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_APP_BUNDLE_ID': bundleId,
      'PATROL_MACOS_APP_BUNDLE_ID': config.macos.bundleId,
      'PATROL_ANDROID_APP_NAME': config.android.appName,
      'PATROL_IOS_APP_NAME': config.ios.appName,
      'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE': 'false',
      'PATROL_TEST_LABEL_ENABLED': options.displayLabel.toString(),
      'PATROL_TEST_DIRECTORY': config.testDirectory,
      // develop-specific
      ...{
        'PATROL_HOT_RESTART': 'true',
        'PATROL_IOS_INSTALLED_APPS': iOSInstalledAppsEnvVariable,
      },
      'PATROL_TEST_SERVER_PORT': options.testServerPort.toString(),
      'PATROL_APP_SERVER_PORT': options.appServerPort.toString(),
    }.withNullsRemoved();

    final dartDefines = {...customDartDefines, ...internalDartDefines};
    _logger.detail(
      'Received ${dartDefines.length} --dart-define(s) '
      '(${customDartDefines.length} custom, '
      '${internalDartDefines.length} internal)',
    );
    for (final dartDefine in customDartDefines.entries) {
      _logger.detail('Received custom --dart-define: ${dartDefine.key}');
    }
    for (final dartDefine in internalDartDefines.entries) {
      _logger.detail(
        'Received internal --dart-define: '
        '${dartDefine.key}=${dartDefine.value}',
      );
    }

    final mergedDartDefines = mergeDartDefines(
      options.dartDefineFromFilePaths,
      dartDefines,
      _dartDefinesReader,
    );

    final flutterOpts = FlutterAppOptions(
      command: options.flutterCommand,
      target: entrypoint.path,
      flavor: androidFlavor,
      buildMode: options.buildMode,
      dartDefines: mergedDartDefines,
      dartDefineFromFilePaths: options.dartDefineFromFilePaths,
      buildName: options.buildName,
      buildNumber: options.buildNumber,
    );

    final androidOpts = AndroidAppOptions(
      flutter: flutterOpts,
      packageName: packageName,
      appServerPort: options.appServerPort,
      testServerPort: options.testServerPort,
      uninstall: options.uninstall,
    );

    final iosOpts = IOSAppOptions(
      flutter: flutterOpts,
      bundleId: bundleId,
      scheme: options.buildMode.createScheme(iosFlavor),
      configuration: options.buildMode.createConfiguration(iosFlavor),
      simulator: !device.real,
      osVersion: options.iosVersion ?? 'latest',
      appServerPort: options.appServerPort,
      testServerPort: options.testServerPort,
    );

    final macosOpts = MacOSAppOptions(
      flutter: flutterOpts,
      scheme: options.buildMode.createScheme(iosFlavor),
      configuration: options.buildMode.createConfiguration(iosFlavor),
      appServerPort: options.appServerPort,
      testServerPort: options.testServerPort,
    );

    final webOpts = WebAppOptions(flutter: flutterOpts);

    try {
      await _build(androidOpts, iosOpts, macosOpts, webOpts, device);
      await _preExecute(androidOpts, iosOpts, device, options.uninstall);
      await _execute(
        flutterOpts,
        androidOpts,
        iosOpts,
        macosOpts,
        webOpts,
        uninstall: options.uninstall,
        device: device,
        openDevtools: options.openDevtools,
        onQuitCleanup: cleanupProxy,
        showFlutterLogs: false,
        hideTestSteps: options.hideTestSteps,
        clearTestSteps: options.clearTestSteps,
      );
    } finally {
      for (final sub in signalSubscriptions) {
        await sub.cancel();
      }
      await cleanupProxy();
    }
  }

  Future<void> _build(
    AndroidAppOptions androidOpts,
    IOSAppOptions iosOpts,
    MacOSAppOptions macosOpts,
    WebAppOptions webOpts,
    Device device,
  ) async {
    final buildAction = switch (device.targetPlatform) {
      TargetPlatform.android => () => _androidTestBackend.build(androidOpts),
      TargetPlatform.iOS => () => _iosTestBackend.build(iosOpts),
      TargetPlatform.macOS => () => _macosTestBackend.build(macosOpts),
      TargetPlatform.web => () => _webTestBackend.buildForDevelop(webOpts),
    };

    try {
      await buildAction();
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(_defaultFailureMessage);
      rethrow;
    }
  }

  Future<void> _preExecute(
    AndroidAppOptions androidOpts,
    IOSAppOptions iosOpts,
    Device device,
    bool uninstall,
  ) async {
    if (!uninstall) {
      return;
    }
    _logger.detail('Will uninstall apps before running tests');

    Future<void> Function()? action;
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
      case TargetPlatform.web:
    }

    try {
      await action?.call();
    } catch (_) {
      // ignore any failures, we don't care
    }
  }

  Future<void> _execute(
    FlutterAppOptions flutterOpts,
    AndroidAppOptions android,
    IOSAppOptions iosOpts,
    MacOSAppOptions macos,
    WebAppOptions web, {
    required bool uninstall,
    required Device device,
    required bool openDevtools,
    required Future<void> Function() onQuitCleanup,
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
  }) async {
    Future<void> Function() action;
    Future<void> Function()? finalizer;
    String? appId;

    switch (device.targetPlatform) {
      case TargetPlatform.android:
        appId = android.packageName;
        action = () => _androidTestBackend.execute(
          android,
          device,
          interruptible: true,
          showFlutterLogs: showFlutterLogs,
          hideTestSteps: hideTestSteps,
          flavor: flutterOpts.flavor,
          clearTestSteps: clearTestSteps,
          onEntry: onEntry,
        );
        final package = android.packageName;
        if (package != null && uninstall) {
          finalizer = () => _androidTestBackend.uninstall(package, device);
        }
      case TargetPlatform.macOS:
        appId = macos.bundleId;
        action = () =>
            _macosTestBackend.execute(macos, device, interruptible: true);
      case TargetPlatform.iOS:
        appId = iosOpts.bundleId;
        action = () => _iosTestBackend.execute(
          iosOpts,
          device,
          interruptible: true,
          showFlutterLogs: showFlutterLogs,
          hideTestSteps: hideTestSteps,
          clearTestSteps: clearTestSteps,
          onEntry: onEntry,
        );
        final bundleId = iosOpts.bundleId;
        if (bundleId != null && uninstall) {
          finalizer = () => _iosTestBackend.uninstall(
            appId: bundleId,
            flavor: iosOpts.flutter.flavor,
            device: device,
          );
        }
      case TargetPlatform.web:
        action = () => _webTestBackend.develop(
          _flutterTool,
          web,
          device,
          showFlutterLogs: showFlutterLogs,
          hideTestSteps: hideTestSteps,
          clearTestSteps: clearTestSteps,
          stdin: _stdin,
        );
    }

    try {
      final future = action();

      if (device.targetPlatform != TargetPlatform.web) {
        await _flutterTool.attachForHotRestart(
          flutterCommand: flutterOpts.command,
          deviceId: device.id,
          target: flutterOpts.target,
          appId: appId,
          dartDefines: flutterOpts.dartDefines,
          openDevtools: openDevtools,
          attachUsingUrl: device.targetPlatform == TargetPlatform.macOS,
          onQuit: onQuitCleanup,
        );
      }

      try {
        await future;
        onTestsCompleted?.call(
          const TestCompletionResult(success: true),
        );
      } catch (err) {
        onTestsCompleted?.call(
          TestCompletionResult(success: false, error: err),
        );
        rethrow;
      }
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(_defaultFailureMessage);
      rethrow;
    } finally {
      try {
        await finalizer?.call();
      } catch (err) {
        _logger.err('Failed to call finalizer: $err');
        rethrow;
      }
    }
  }

  static const _defaultFailureMessage =
      'See the logs above to learn what happened. Also consider running with '
      "--verbose. If the logs still aren't useful, then it's a bug - please "
      'report it.';

  List<StreamSubscription<ProcessSignal>> _registerProxyCleanupOnSignals(
    String testDirectory,
  ) {
    final subscriptions = <StreamSubscription<ProcessSignal>>[];

    void cleanup(ProcessSignal signal) {
      _logger.detail('Received $signal, removing devtools proxy entrypoint');
      _testBundler.deleteEntrypointProxy(testDirectory);
    }

    subscriptions.add(ProcessSignal.sigint.watch().listen(cleanup));
    try {
      subscriptions.add(ProcessSignal.sigterm.watch().listen(cleanup));
    } catch (_) {
      // Some platforms may not support sigterm.
    }

    return subscriptions;
  }
}
