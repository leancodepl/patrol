// TODO: Supports only Android at the moment.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart';
import 'package:patrol_cli/src/commands/test_command.dart';
import 'package:patrol_cli/src/common/extensions/core.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/common/staged_command.dart';
import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:patrol_cli/src/features/devices/device.dart';
import 'package:patrol_cli/src/features/run_commons/dart_defines_reader.dart';
import 'package:patrol_cli/src/features/run_commons/test_finder.dart';
import 'package:patrol_cli/src/features/run_commons/test_runner.dart';
import 'package:patrol_cli/src/features/test/android_test_backend.dart';
import 'package:patrol_cli/src/features/test/ios_test_backend.dart';
import 'package:patrol_cli/src/features/test/pubspec_reader.dart';

part 'develop_command.freezed.dart';

@freezed
// FIXME: works only on Android
class DevelopCommandConfig with _$DevelopCommandConfig {
  const factory DevelopCommandConfig({
    required String target,
    required Map<String, String> dartDefines,
    required bool displayLabel,
    // Android-only options
    required String? packageName,
    required String? androidFlavor,
    // iOS-only options
    required String? bundleId,
    required String? iosFlavor,
    required String scheme,
    required String xcconfigFile,
    required String configuration,
  }) = _DevelopCommandConfig;
}

const _failureMessage =
    'See the logs above to learn what happened. Also consider running with '
    "--verbose. If the logs still aren't useful, then it's a bug - please "
    'report it.';

class DevelopCommand extends StagedCommand<DevelopCommandConfig> {
  DevelopCommand({
    required TestFinder testFinder,
    required TestRunner testRunner,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required Logger logger,
  })  : _testFinder = testFinder,
        _testRunner = testRunner,
        _dartDefinesReader = dartDefinesReader,
        _pubspecReader = pubspecReader,
        _androidTestBackend = androidTestBackend,
        _iosTestBackend = iosTestBackend,
        _logger = logger {
    argParser
      ..addOption(
        'target',
        abbr: 't',
        help: 'Integration test to set as entrypoint.',
        valueHelp: 'integration_test/app_test.dart',
        mandatory: true,
      )
      ..addOption(
        'flavor',
        help: 'Flavor of the app to run.',
      )
      ..addMultiOption(
        'dart-define',
        aliases: ['dart-defines'],
        help: 'Additional key-value pairs that will be available to the app '
            'under test.',
        valueHelp: 'KEY=VALUE',
      )
      ..addOption(
        'wait',
        help: 'Seconds to wait after the test fails or succeeds.',
        defaultsTo: '0',
      )
      ..addFlag(
        'label',
        help: 'Display the label over the application under test.',
        defaultsTo: true,
      )
      // Android-only options
      ..addOption(
        'package-name',
        help: 'Package name of the Android app under test.',
        valueHelp: 'pl.leancode.awesomeapp',
      )
      // iOS-only options
      ..addOption(
        'bundle-id',
        help: 'Bundle identifier of the iOS app under test.',
        valueHelp: 'pl.leancode.AwesomeApp',
      )
      ..addOption(
        'scheme',
        help: '(iOS only) Xcode scheme to use',
        defaultsTo: _defaultScheme,
      )
      ..addOption(
        'xcconfig',
        help: '(iOS only) Xcode .xcconfig file to use',
        defaultsTo: _defaultXCConfigFile,
      )
      ..addOption(
        'configuration',
        help: '(iOS only) Xcode configuration to use',
        defaultsTo: _defaultConfiguration,
      );
  }

  static const _defaultScheme = 'Runner';
  static const _defaultXCConfigFile = 'Flutter/Debug.xcconfig';
  static const _defaultConfiguration = 'Debug';

  final TestFinder _testFinder;
  final TestRunner _testRunner;
  final DartDefinesReader _dartDefinesReader;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  // ignore: unused_field
  final IOSTestBackend _iosTestBackend;

  final Logger _logger;

  bool verbose = false;

  @override
  String get name => 'build';

  @override
  String get description => 'Build app with integration test as entrypoint.';

  @override
  bool get hidden => true;

  @override
  Future<DevelopCommandConfig> configure() async {
    final targetArg = argResults?['target'] as String?;
    if (targetArg == null) {
      throwToolExit('Missing required option: --target');
    }

    final target = _testFinder.findTest(targetArg);
    _logger.detail('Received test target: $target');

    final pubspecConfig = _pubspecReader.read();

    String? androidFlavor;
    String? iosFlavor;
    if (argResults?['flavor'] is String) {
      androidFlavor = argResults?['flavor'] as String;
      iosFlavor = argResults?['flavor'] as String;
    } else {
      androidFlavor = pubspecConfig.android.flavor;
      iosFlavor = pubspecConfig.ios.flavor;
    }
    if (androidFlavor != null) {
      _logger.detail('Received Android flavor: $androidFlavor');
    }
    if (iosFlavor != null) {
      _logger.detail('Received iOS flavor: $iosFlavor');
    }

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(
        args: argResults?['dart-define'] as List<String>? ?? [],
      ),
    };

    var packageName = argResults?['package-name'] as String?;
    packageName ??= pubspecConfig.android.packageName;

    var bundleId = argResults?['bundle-id'] as String?;
    bundleId ??= pubspecConfig.ios.bundleId;

    final dynamic wait = argResults?['wait'];
    if (wait != null && int.tryParse(wait as String) == null) {
      throw const FormatException('`wait` argument is not an int');
    }

    final displayLabel = argResults?['label'] as bool?;

    final internalDartDefines = {
      'PATROL_WAIT': wait as String? ?? '0',
      'PATROL_VERBOSE': '$verbose',
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_APP_BUNDLE_ID': bundleId,
      'PATROL_ANDROID_APP_NAME': pubspecConfig.android.appName,
      'PATROL_IOS_APP_NAME': pubspecConfig.ios.appName,
    }.withNullsRemoved();

    final effectiveDartDefines = {...customDartDefines, ...internalDartDefines};
    for (final dartDefine in customDartDefines.entries) {
      _logger.detail('Received custom --dart-define: ${dartDefine.key}');
    }
    for (final dartDefine in internalDartDefines.entries) {
      _logger.detail(
        'Received internal --dart-define: ${dartDefine.key}=${dartDefine.value}',
      );
    }

    return DevelopCommandConfig(
      target: target,
      dartDefines: effectiveDartDefines,
      displayLabel: displayLabel ?? true,
      // Android-specific options
      packageName: packageName,
      androidFlavor: androidFlavor,
      // iOS-specific options
      bundleId: bundleId,
      iosFlavor: iosFlavor,
      scheme: argResults?['scheme'] as String? ?? _defaultScheme,
      xcconfigFile: argResults?['xcconfig'] as String? ?? _defaultXCConfigFile,
      configuration: !(argResults?.wasParsed('configuration') ?? false) &&
              (argResults?.wasParsed('flavor') ?? false)
          ? 'Debug-${argResults!['flavor']}'
          : argResults?['configuration'] as String? ?? _defaultConfiguration,
    );
  }

  @override
  Future<int> execute(DevelopCommandConfig config) async {
    config.devices.forEach(_testRunner.addDevice);
    _testRunner
      ..repeats = config.repeat
      ..builder = _builderFor(config)
      ..executor = _executorFor(config);

    final results = await _testRunner.run();

    try {
      await action();
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(_failureMessage);
      rethrow;
    }

    return 0;
  }

  Future<void> Function(String, Device) _builderFor(TestCommandConfig config) {
    return (target, device) async {
      Future<void> Function() action;

      switch (device.targetPlatform) {
        case TargetPlatform.android:
          final options = AndroidAppOptions(
            target: target,
            flavor: config.androidFlavor,
            dartDefines: {
              ...config.dartDefines,
              if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
            },
          );
          action = () => _androidTestBackend.build(options);
          break;
        case TargetPlatform.iOS:
          final options = IOSAppOptions(
            target: target,
            flavor: config.iosFlavor,
            dartDefines: {
              ...config.dartDefines,
              if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
            },
            scheme: config.scheme,
            xcconfigFile: config.xcconfigFile,
            configuration: config.configuration,
            simulator: !device.real,
          );
          action = () => _iosTestBackend.build(options);
      }

      try {
        await action();
      } catch (err, st) {
        _logger
          ..err('$err')
          ..detail('$st')
          ..err(_failureMessage);
        rethrow;
      }
    };
  }

  Future<void> Function(String, Device) _executorFor(TestCommandConfig config) {
    return (target, device) async {
      Future<void> Function() action;
      Future<void> Function()? finalizer;

      switch (device.targetPlatform) {
        case TargetPlatform.android:
          final options = AndroidAppOptions(
            target: target,
            flavor: config.androidFlavor,
            dartDefines: {
              ...config.dartDefines,
              if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
            },
          );
          action = () => _androidTestBackend.execute(options, device);
          final package = config.packageName;
          if (package != null && config.uninstall) {
            finalizer = () => _androidTestBackend.uninstall(package, device);
          }
          break;
        case TargetPlatform.iOS:
          final options = IOSAppOptions(
            target: target,
            flavor: config.iosFlavor,
            dartDefines: {
              ...config.dartDefines,
              if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
            },
            scheme: config.scheme,
            xcconfigFile: config.xcconfigFile,
            configuration: config.configuration,
            simulator: !device.real,
          );
          action = () async => _iosTestBackend.execute(options, device);
          final bundle = config.bundleId;
          if (bundle != null && config.uninstall) {
            finalizer = () => _iosTestBackend.uninstall(bundle, device);
          }
      }

      try {
        await action();
      } catch (err, st) {
        _logger
          ..err('$err')
          ..detail('$st')
          ..err(_failureMessage);
        rethrow;
      } finally {
        await finalizer?.call();
      }
    };
  }
}
