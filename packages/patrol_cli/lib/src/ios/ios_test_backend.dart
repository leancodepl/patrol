import 'dart:convert';
import 'dart:io' show Process;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_deploy.dart';
import 'package:process/process.dart';

enum BuildMode {
  debug('Debug'),
  profile('Profile'),
  release('Release');

  const BuildMode(this.name);

  /// Creates a [BuildMode] from a string. Throws [StateError] if [name] isn't a
  /// valid value.
  factory BuildMode.fromName(String name) {
    return values.firstWhere((value) => value.name == name);
  }

  static const defaultScheme = 'Runner';
  final String name;

  String createScheme(String? flavor) {
    if (flavor == null) {
      return BuildMode.defaultScheme;
    }
    return flavor;
  }

  String createConfiguration(String? flavor) {
    if (flavor == null) {
      return name;
    }
    return '$name-$flavor';
  }
}

class IOSTestBackend {
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

  Future<void> build(IOSAppOptions options) async {
    await _disposeScope.run((scope) async {
      final subject = options.description;
      final task = _logger.task('Building $subject');

      Process process;

      // flutter build ios --config-only

      var flutterBuildKilled = false;
      process = await _processManager.start(
        options.toFlutterBuildInvocation(options.flutter.buildMode),
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
        options.buildForTestingInvocation(),
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

  /// Executes the tests of the given [options] on the given [device].
  ///
  /// [build] must be called before this method.
  ///
  /// If [interruptible] is true, then no exception is thrown on SIGINT. This is
  /// used for Hot Restart.
  Future<void> execute(
    IOSAppOptions options,
    Device device, {
    bool interruptible = false,
  }) async {
    await _disposeScope.run((scope) async {
      final subject = '${options.description} on ${device.description}';
      final task = _logger.task('Running $subject');

      Process? iosDeployProcess;
      if (device.real) {
        _logger.detail('Executing on physical iOS device using ios-deploy...');
        iosDeployProcess = await _iosDeploy.installAndLaunch(device.id);
      }

      final sdkVersion = await _sdkVersion(device.real);
      final process = await _processManager.start(
        options.testWithoutBuildingInvocation(
          device,
          xcTestRunPath:
              await _xcTestRunPath(device.real, options.scheme, sdkVersion),
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
      } else if (exitCode != 0 && interruptible) {
        task.complete('App shut down on request');
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

  Future<void> uninstall(String appId, Device device) async {
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
    } else {
      // uninstall from iOS simulator
      await _processManager.run(
        ['xcrun', 'simctl', 'uninstall', device.id, appId],
        runInShell: true,
      );
    }

    final testApp = '$appId.RunnerUITests.xctrunner';
    if (device.real) {
      // uninstall from iOS device
      await _processManager.run(
        [
          'ideviceinstaller',
          ...['--udid', device.id],
          ...['--uninstall', testApp],
        ],
        runInShell: true,
      );
    } else {
      // uninstall from iOS simulator
      // TODO: Doesn't work when flavor is not null
      await _processManager.run(
        ['xcrun', 'simctl', 'uninstall', device.id, testApp],
        runInShell: true,
      );
    }
  }

  Future<String> _xcTestRunPath(
    bool real,
    String scheme,
    String sdkVersion,
  ) async {
    final Glob glob;
    if (real) {
      glob = Glob('${scheme}_iphoneos$sdkVersion-*.xctestrun');
    } else {
      glob = Glob('${scheme}_iphonesimulator$sdkVersion-*.xctestrun');
    }

    const suffix = 'build/ios_integ/Build/Products';
    final root = join(_fs.currentDirectory.absolute.path, suffix);
    _logger.detail('Looking for .xctestrun matching ${glob.pattern} at $root');
    final files = await glob.listFileSystem(_fs, root: root).toList();
    if (files.isEmpty) {
      final cause = 'No .xctestrun file was found at $root';
      throwToolExit(cause);
    }

    _logger
        .detail('Found ${files.length} match(es), the first one will be used');
    for (final file in files) {
      _logger.detail('Found ${file.absolute.path}');
    }

    return files.first.absolute.path;
  }

  Future<String> _sdkVersion(bool real) async {
    // See the versions yourself: $ xcodebuild -showsdks -json | jq ".[] |
    // {sdkVersion, platform}"

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
