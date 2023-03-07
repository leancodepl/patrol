import 'dart:async';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/features/devices/device.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/run_commons/dart_defines_reader.dart';
import 'package:patrol_cli/src/features/run_commons/test_finder.dart';
import 'package:patrol_cli/src/features/run_commons/test_runner.dart';
import 'package:patrol_cli/src/features/test/pubspec_reader.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

class DevelopCommand extends PatrolCommand {
  DevelopCommand({
    required DeviceFinder deviceFinder,
    required TestFinder testFinder,
    required TestRunner testRunner,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _deviceFinder = deviceFinder,
        _testFinder = testFinder,
        _testRunner = testRunner,
        _dartDefinesReader = dartDefinesReader,
        _pubspecReader = pubspecReader,
        _androidTestBackend = androidTestBackend,
        _iosTestBackend = iosTestBackend,
        _logger = logger {
    _testRunner.disposedBy(parentDisposeScope);

    usesTargetOption();
    usesDeviceOption();
    usesFlavorOption();
    usesDartDefineOption();
    usesLabelOption();
    usesWaitOption();

    usesUninstallOption();

    usesAndroidOptions();
    usesIOSOptions();
  }

  final DeviceFinder _deviceFinder;
  final TestFinder _testFinder;
  final TestRunner _testRunner;
  final DartDefinesReader _dartDefinesReader;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  final IOSTestBackend _iosTestBackend;

  final Logger _logger;

  @override
  String get name => 'develop';

  @override
  String get description => 'Develop integration tests with Hot Restart.';

  @override
  bool get hidden => true;

  @override
  Future<int> run() async {
    final targetArg = stringsArg('target');
    final target = _testFinder.findTest(targetArg.first);
    _logger.detail('Received test target: $target');

    final config = _pubspecReader.read();
    final androidFlavor = stringArg('flavor') ?? config.android.flavor;
    final iosFlavor = stringArg('flavor') ?? config.ios.flavor;
    if (androidFlavor != null) {
      _logger.detail('Received Android flavor: $androidFlavor');
    }
    if (iosFlavor != null) {
      _logger.detail('Received iOS flavor: $iosFlavor');
    }

    final devices = await _deviceFinder.find(stringsArg('device'));
    final device = devices.single;
    _logger.detail('Received device: ${device.resolvedName}');

    final packageName = stringArg('package-name') ?? config.android.packageName;
    final bundleId = stringArg('bundle-id') ?? config.ios.bundleId;

    final displayLabel = boolArg('label') ?? true;
    final uninstall = boolArg('uninstall') ?? true;

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_WAIT': defaultWait.toString(),
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_APP_BUNDLE_ID': bundleId,
      'PATROL_ANDROID_APP_NAME': config.android.appName,
      'PATROL_IOS_APP_NAME': config.ios.appName,
      if (displayLabel) 'PATROL_TEST_LABEL': basename(target),
      // develop-specific
      ...{
        'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE': 'false',
        'PATROL_HOT_RESTART': 'true',
      },
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

    final androidOpts = AndroidAppOptions(
      target: target,
      flavor: androidFlavor,
      dartDefines: dartDefines,
      packageName: packageName,
    );

    final iosOpts = IOSAppOptions(
      target: target,
      flavor: iosFlavor,
      dartDefines: dartDefines,
      bundleId: bundleId,
      scheme: stringArg('scheme') ?? defaultScheme,
      xcconfigFile: stringArg('xcconfig') ?? defaultXCConfigFile,
      configuration: !(argResults?.wasParsed('configuration') ?? false) &&
              (argResults?.wasParsed('flavor') ?? false)
          ? 'Debug-${argResults!['flavor']}'
          : stringArg('configuration') ?? defaultConfiguration,
      simulator: !device.real,
    );

    await _build(androidOpts, iosOpts, device: device);
    await _execute(androidOpts, iosOpts, uninstall: uninstall, device: device);

    return 0; // for now, all exit codes are 0
  }

  Future<void> _build(
    AndroidAppOptions android,
    IOSAppOptions ios, {
    required Device device,
  }) async {
    Future<void> Function() buildAction;
    switch (device.targetPlatform) {
      case TargetPlatform.android:
        buildAction = () => _androidTestBackend.build(android);
        break;
      case TargetPlatform.iOS:
        buildAction = () => _iosTestBackend.build(ios);
    }

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

  Future<void> _execute(
    AndroidAppOptions android,
    IOSAppOptions ios, {
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
        break;
      case TargetPlatform.iOS:
        action = () async => _iosTestBackend.execute(ios, device);
        final bundle = ios.bundleId;
        if (bundle != null && uninstall) {
          finalizer = () => _iosTestBackend.uninstall(bundle, device);
        }
    }

    try {
      // TODO: Extract "attach" and "logs" to a separate FlutterTool class
      _enableInteractiveMode();
      final logsProces = LoggingLocalProcessManager(logger: _logger);
      unawaited(() async {
        final process = await logsProces.start(
          ['flutter', '--no-version-check', 'logs', '--device-id', device.id],
        );
        _logger.info('Waiting for app to connect for logs...');
        process
          ..listenStdOut((l) => _logger.info('\t: $l'))
          ..listenStdErr((l) => _logger.err('\t$l'));
      }());

      final attachProces = LoggingLocalProcessManager(logger: _logger);
      unawaited(() async {
        final process = await attachProces.start(
          // FIXME: hardcoded android
          android.toFlutterAttachInvocation(),
        );
        _logger.info('Waiting for app to connect for Hot Restart...');
        process
          ..listenStdOut((l) => _logger.detail('\t: $l'))
          ..listenStdErr((l) => _logger.err('\t$l'));
        stdin.listen((event) {
          final char = String.fromCharCode(event.first);
          if (char == 'r' || char == 'R') {
            _logger.success('Hot Restart in progress...');
            process.stdin.add(event);
          }

          if (char == 'q' || char == 'Q') {
            _logger.success('Quitting APP...');
            process.stdin.add(event);
          }
        });
      }());
      await action();
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      rethrow;
    } finally {
      await finalizer?.call();
    }
  }
}

void _enableInteractiveMode() {
  // Prevents keystrokes from being printed automatically. Needs to be
  // disabled for lineMode to be disabled too.
  stdin.echoMode = false;

  // Causes the stdin stream to provide the input as soon as it arrives (one
  // key press at a time).
  stdin.lineMode = false;
}
