import 'dart:convert';
import 'dart:io' show Process;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:path/path.dart' show basename, join;
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';
import 'package:patrol_cli/src/features/test/ios_deploy.dart';
import 'package:patrol_cli/src/features/test/test_backend.dart';
import 'package:process/process.dart';

class IOSAppOptions extends AppOptions {
  const IOSAppOptions({
    required super.target,
    required super.flavor,
    required super.dartDefines,
    required this.scheme,
    required this.xcconfigFile,
    required this.configuration,
  });

  final String scheme;
  final String xcconfigFile;
  final String configuration;

  @override
  String get description => 'app with entrypoint ${basename(target)}';

  /// Translates these options into a proper flutter build invocation, which
  /// runs before xcodebuild and performs configuration.
  List<String> toFlutterBuildInvocation(Device device) {
    final cmd = [
      ...['flutter', 'build', 'ios'],
      '--no-version-check',
      ...[
        '--config-only',
        '--no-codesign',
        '--debug',
        if (!device.real) '--simulator'
      ],
      if (flavor != null) ...['--flavor', flavor!],
      ...['--target', target],
      for (final dartDefine in dartDefines.entries) ...[
        '--dart-define',
        '${dartDefine.key}=${dartDefine.value}',
      ],
    ];

    return cmd;
  }

  /// Translates these options into a proper `xcodebuild build-for-testing`
  /// invocation.
  List<String> buildForTestingInvocation(Device device) {
    final cmd = [
      ...['xcodebuild', 'build-for-testing'],
      ...['-workspace', 'Runner.xcworkspace'],
      ...['-scheme', scheme],
      ...['-xcconfig', xcconfigFile],
      ...['-configuration', configuration],
      ...['-sdk', if (device.real) 'iphoneos' else 'iphonesimulator'],
      ...[
        '-destination',
        'generic/platform=${device.real ? 'iOS' : 'iOS Simulator'}',
      ],
      '-quiet',
      ...['-derivedDataPath', '../build/ios_integ'],
      r'OTHER_SWIFT_FLAGS=$(inherited) -D PATROL_ENABLED',
    ];

    return cmd;
  }

  /// Translates these options into a proper `xcodebuild test-without-building`
  /// invocation.
  List<String> testWithoutBuildingInvocation(
    Device device, {
    required String sdkVersion,
  }) {
    const prefix = '../build/ios_integ/Build/Products';
    final cmd = [
      ...['xcodebuild', 'test-without-building'],
      ...[
        '-xctestrun',
        if (device.real)
          join(prefix, 'Runner_iphoneos$sdkVersion-arm64.xctestrun')
        else
          join(
            prefix,
            'Runner_iphonesimulator$sdkVersion-arm64-x86_64.xctestrun',
          )
      ],
      ...[
        '-destination',
        'platform=${device.real ? 'iOS' : 'iOS Simulator'},name=${device.name}',
      ],
    ];

    return cmd;
  }
}

class IOSTestBackend extends TestBackend {
  IOSTestBackend({
    required ProcessManager processManager,
    required FileSystem fs,
    required IOSDeploy iosDeploy,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _processManager = processManager,
        _fs = fs,
        _iosDeploy = iosDeploy,
        _disposeScope = DisposeScope(),
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  static const _xcodebuildInterrupted = -15;

  final ProcessManager _processManager;
  final FileSystem _fs;
  final IOSDeploy _iosDeploy;
  final DisposeScope _disposeScope;
  final Logger _logger;

  @override
  Future<void> build(IOSAppOptions options, Device device) async {
    await _disposeScope.run((scope) async {
      final subject =
          '${options.description} for ${device.platformDescription}';
      final task = _logger.task('Building $subject');

      Process process;

      // flutter build ios --config-only

      var flutterBuildKilled = false;
      process = await _processManager.start(
        options.toFlutterBuildInvocation(device),
        runInShell: true,
      );
      scope.addDispose(() async {
        process.kill();
        flutterBuildKilled = true; // `flutter build` has exit code 0 on SIGINT
      });
      process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);
      var exitCode = await process.exitCode;
      if (exitCode != 0) {
        final cause = '`flutter build ios` exited with code $exitCode';
        task.fail('Failed to build $subject ($cause)');
        throwToolExit(cause);
      } else if (flutterBuildKilled) {
        const cause = '`flutter build ios` was interrupted';
        task.fail('Failed to build $subject ($cause)');
        throwToolInterrupted(cause);
      }

      // xcodebuild build-for-testing

      process = await _processManager.start(
        options.buildForTestingInvocation(device),
        runInShell: true,
        workingDirectory: _fs.currentDirectory.childDirectory('ios').path,
      )
        ..disposedBy(scope);
      process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);
      exitCode = await process.exitCode;
      if (exitCode == 0) {
        task.complete('Completed building $subject');
      } else if (exitCode == _xcodebuildInterrupted) {
        const cause = 'xcodebuild was interrupted';
        task.fail('Failed to execute tests of $subject ($cause)');
        throwToolInterrupted(cause);
      } else {
        final cause = 'xcodebuild exited with code $exitCode';
        task.fail('Failed to build $subject ($cause)');
        throwToolExit(cause);
      }
    });
  }

  @override
  Future<void> execute(IOSAppOptions options, Device device) async {
    await _disposeScope.run((scope) async {
      final subject = '${options.description} on ${device.description}';
      final task = _logger.task('Running $subject');

      Process? iosDeployProcess;
      if (device.real) {
        _logger.detail('Executing on physical iOS device using ios-deploy...');
        iosDeployProcess = await _iosDeploy.installAndLaunch(device.id);
      }

      final process = await _processManager.start(
        options.testWithoutBuildingInvocation(
          device,
          sdkVersion: await _sdkVersion(device.real),
        ),
        runInShell: true,
        workingDirectory: _fs.currentDirectory.childDirectory('ios').path,
      )
        ..disposedBy(_disposeScope);
      process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);

      final exitCode = await process.exitCode;
      // Tests have finished now, kill the app under test
      iosDeployProcess?.stdin.writeln('kill');
      iosDeployProcess?.kill(); // kill it with fire

      if (exitCode == 0) {
        task.complete('Completed executing $subject');
      } else if (exitCode == _xcodebuildInterrupted) {
        const cause = 'xcodebuild was interrupted';
        task.fail('Failed to execute tests of $subject ($cause)');
        throwToolInterrupted(cause);
      } else {
        final cause = 'xcodebuild exited with code $exitCode';
        task.fail('Failed to execute tests of $subject ($cause)');
        throwToolExit(cause);
      }
    });
  }

  @override
  Future<void> uninstall(String appId, Device device) async {
    _logger.info('Uninstalling $appId from ${device.name}');

    if (device.real) {
      // uninstall from iOS device
      await _processManager.run(
        [
          'ideviceinstaller',
          ...['--udid', device.id],
          ...['--uninstall', appId],
        ],
        runInShell: true,
      );

      await _processManager.run(
        [
          'ideviceinstaller',
          ...['--udid', device.id],
          ...['--uninstall', '$appId.RunnerUITests.xctrunner'],
        ],
        runInShell: true,
      );
    } else {
      // uninstall from iOS simulator
      await _processManager.run(
        [
          'xcrun',
          'simctl',
          'uninstall',
          device.id,
          appId,
        ],
        runInShell: true,
      );
      // uninstall from iOS simulator
      await _processManager.run(
        [
          'xcrun',
          'simctl',
          'uninstall',
          device.id,
          '$appId.RunnerUITests.xctrunner',
        ],
        runInShell: true,
      );
    }
  }

  Future<String> _sdkVersion(bool real) async {
    // See the versions yourself:
    // $ xcodebuild -showsdks -json | jq ".[] | {sdkVersion, platform}"

    final processResult = await _processManager.run(
      ['xcodebuild', '-showsdks', '-json'],
      runInShell: true,
    );

    String? sdkVersion;
    String? platform;
    final jsonOutput = jsonDecode(processResult.stdOut) as List<dynamic>;
    for (final sdkJson in jsonOutput) {
      final sdk = sdkJson as Map<String, dynamic>;
      if (real && sdk['platform'] == 'iphonesimulator') {
        sdkVersion = sdk['sdkVersion'] as String;
        platform = sdk['platform'] as String;
        break;
      }

      if (!real && sdk['platform'] == 'iphonesimulator') {
        sdkVersion = sdk['sdkVersion'] as String;
        platform = sdk['platform'] as String;
        break;
      }
    }

    if (sdkVersion == null) {
      throw Exception('xcodebuild: could not find SDK version');
    }

    _logger.detail('Assuming SDK version $sdkVersion for $platform');
    return sdkVersion;
  }
}
