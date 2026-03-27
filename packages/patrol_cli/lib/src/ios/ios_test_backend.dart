import 'dart:convert';
import 'dart:io' show Process;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

enum BuildMode {
  debug,
  profile,
  release;

  static const _defaultScheme = 'Runner';

  /// Name of this build mode in the Xcode Build Configuration format.
  ///
  /// Flutter build mode name starts with with a lowercase letter, for example
  /// `debug` or `release`.
  ///
  /// Xcode Build Configuration names starts with an uppercase letter, for
  /// example 'Debug' or 'Release'.
  String get xcodeName => name.replaceFirst(name[0], name[0].toUpperCase());

  // It's the same as xcodeName, but let's keep it for clarity.
  /// Name of this build mode as a part of Gradle task name.
  String get androidName => xcodeName;

  String createScheme(String? flavor) {
    if (flavor == null) {
      return _defaultScheme;
    }
    return flavor;
  }

  String createConfiguration(String? flavor) {
    if (flavor == null) {
      return xcodeName;
    }
    return '$xcodeName-$flavor';
  }
}

class IOSTestBackend {
  IOSTestBackend({
    required ProcessManager processManager,
    required Platform platform,
    required FileSystem fs,
    required Directory rootDirectory,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  }) : _processManager = processManager,
       _platform = platform,
       _fs = fs,
       _rootDirectory = rootDirectory,
       _disposeScope = DisposeScope(),
       _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  static const _xcodebuildInterrupted = -15;

  final ProcessManager _processManager;
  final Platform _platform;
  final FileSystem _fs;
  final Directory _rootDirectory;
  final DisposeScope _disposeScope;
  final Logger _logger;

  Future<void> build(IOSAppOptions options) async {
    await _disposeScope.run((scope) async {
      final subject = options.description;
      final task = _logger.task(
        'Building $subject (${options.flutter.buildMode.name})',
      );

      Process process;

      final isRealDevice = !options.simulator;
      final isReleaseMode = options.flutter.buildMode == BuildMode.release;
      if (isRealDevice && !isReleaseMode) {
        throwToolExit(
          'Running on physical iOS devices is possible only in release mode',
        );
      }

      // flutter build ios --config-only

      var flutterBuildKilled = false;
      process = await _processManager.start(
        options.toFlutterBuildInvocation(options.flutter.buildMode),
        runInShell: true,
      );
      scope.addDispose(() {
        process.kill();
        flutterBuildKilled = true; // `flutter build` has exit code 0 on SIGINT
      });
      process.listenStdOut((l) => _logger.info('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);
      var exitCode = await process.exitCode;
      final flutterCommand = options.flutter.command;
      if (exitCode != 0) {
        final cause = '`$flutterCommand build ios` exited with code $exitCode';
        task.fail('Failed to build $subject ($cause)');
        throwToolExit(cause);
      } else if (flutterBuildKilled) {
        final cause = '`$flutterCommand build ios` was interrupted';
        task.fail('Failed to build $subject ($cause)');
        throwToolInterrupted(cause);
      }

      // xcodebuild build-for-testing

      process =
          await _processManager.start(
              options.buildForTestingInvocation(),
              runInShell: true,
              workingDirectory: _rootDirectory.childDirectory('ios').path,
            )
            ..disposedBy(scope);
      process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);
      exitCode = await process.exitCode;
      if (exitCode == 0) {
        task.complete('Completed building $subject');
        await _patchXcTestRunDyldPath(
          scheme: options.scheme,
          real: !options.simulator,
        );
        if (!options.simulator) {
          await _preparePhysicalDeviceXcode26Runtime();
        }
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
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
    void Function(Entry entry)? onLogEntry,
  }) async {
    await _disposeScope.run((scope) async {
      final patrolLogCommand = device.real
          ? ['idevicesyslog']
          : ['log', 'stream'];

      // Read patrol logs from log stream
      final processLogs =
          await _processManager.start(patrolLogCommand, runInShell: true)
            ..disposedBy(scope);

      final reportPath = resultBundlePath(
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      final patrolLogReader =
          PatrolLogReader(
              listenStdOut: processLogs.listenStdOut,
              scope: scope,
              log: _logger.info,
              reportPath: reportPath,
              showFlutterLogs: showFlutterLogs,
              hideTestSteps: hideTestSteps,
              clearTestSteps: clearTestSteps,
              onLogEntry: onLogEntry,
            )
            ..listen()
            ..startTimer();

      final subject = '${options.description} on ${device.description}';
      final task = _logger.task('Running $subject');

      final sdkVersion = await getSdkVersion(real: device.real);
      final process =
          await _processManager.start(
              options.testWithoutBuildingInvocation(
                device,
                xcTestRunPath: await xcTestRunPath(
                  real: device.real,
                  scheme: options.scheme,
                  sdkVersion: sdkVersion,
                ),
                resultBundlePath: reportPath,
              ),
              runInShell: true,
              environment: {
                ..._platform.environment,
                'TEST_RUNNER_PATROL_TEST_PORT': options.testServerPort
                    .toString(),
                'TEST_RUNNER_PATROL_APP_PORT': options.appServerPort.toString(),
              },
              workingDirectory: _rootDirectory.childDirectory('ios').path,
            )
            ..disposedBy(_disposeScope);
      process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.detail('\t$l')).disposedBy(scope);

      final exitCode = await process.exitCode;
      patrolLogReader.stopTimer();
      processLogs.kill();

      // Don't print the summary in develop
      if (!interruptible) {
        _logger.info(patrolLogReader.summary);
      }

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

  /// Uninstalls the app under test and the test runner from [device].
  ///
  /// [flavor] is required to infer the test runner bundle ID.
  Future<void> uninstall({
    required String appId,
    required String? flavor,
    required Device device,
  }) async {
    if (device.real) {
      // uninstall from iOS device
      await _processManager.run([
        'ideviceinstaller',
        ...['--udid', device.id],
        ...['--uninstall', appId],
      ], runInShell: true);
    } else {
      // uninstall from iOS simulator
      await _processManager.run([
        'xcrun',
        'simctl',
        'uninstall',
        device.id,
        appId,
      ], runInShell: true);
    }

    // See rationale: https://github.com/leancodepl/patrol/issues/1094
    final appIdWithoutFlavor = stripFlavorFromAppId(appId, flavor);
    final testApp = '$appIdWithoutFlavor.RunnerUITests.xctrunner';

    if (device.real) {
      // uninstall from iOS device
      await _processManager.run([
        'ideviceinstaller',
        ...['--udid', device.id],
        ...['--uninstall', testApp],
      ], runInShell: true);
    } else {
      // uninstall from iOS simulator
      await _processManager.run([
        'xcrun',
        'simctl',
        'uninstall',
        device.id,
        testApp,
      ], runInShell: true);
    }
  }

  /// Removes [flavor] from the end of [appId].
  ///
  /// Assumes that [appId] and [flavor] are separated by a dot.
  @visibleForTesting
  String stripFlavorFromAppId(String appId, String? flavor) {
    if (flavor == null) {
      return appId;
    }

    final idx = appId.indexOf('.$flavor');

    if (idx == -1) {
      return appId;
    }

    return appId.substring(0, idx);
  }

  /// Xcode 26+ ships `_Testing_Foundation.framework` under
  /// `__PLATFORMS__/.../Frameworks`. Ensure xctestrun contains
  /// `DYLD_FRAMEWORK_PATH` for simulator and device runs.
  Future<void> _patchXcTestRunDyldPath({
    required String scheme,
    required bool real,
  }) async {
    final sdkVersion = await getSdkVersion(real: real);
    final plist = await xcTestRunPath(
      real: real,
      scheme: scheme,
      sdkVersion: sdkVersion,
    );

    final platformDir = real ? 'iPhoneOS' : 'iPhoneSimulator';
    final addition =
        '__PLATFORMS__/$platformDir.platform/Developer/Library/Frameworks';

    // v1 (flat) and v2 (TestConfigurations) xctestrun formats
    const keys = [
      ':RunnerUITests:UITargetAppEnvironmentVariables:DYLD_FRAMEWORK_PATH',
      ':TestConfigurations:0:TestTargets:0:UITargetAppEnvironmentVariables:DYLD_FRAMEWORK_PATH',
    ];

    for (final key in keys) {
      final read = await _processManager.run([
        '/usr/libexec/PlistBuddy',
        '-c',
        'Print $key',
        plist,
      ]);
      if (read.exitCode != 0) {
        final add = await _processManager.run([
          '/usr/libexec/PlistBuddy',
          '-c',
          'Add $key string $addition',
          plist,
        ]);
        if (add.exitCode == 0) {
          _logger.detail(
            'Added DYLD_FRAMEWORK_PATH to xctestrun for Xcode 26+',
          );
          return;
        }
        continue;
      }

      final current = read.stdOut.trim();
      if (current.contains('__PLATFORMS__')) {
        return;
      }

      await _processManager.run([
        '/usr/libexec/PlistBuddy',
        '-c',
        'Set $key $current:$addition',
        plist,
      ]);
      _logger.detail('Patched xctestrun DYLD_FRAMEWORK_PATH for Xcode 26+');
      return;
    }
  }

  Future<void> _preparePhysicalDeviceXcode26Runtime() async {
    final appDir = join(
      _rootDirectory.absolute.path,
      'build/ios_integ/Build/Products/Release-iphoneos/Runner.app',
    );
    final frameworksDir = join(appDir, 'Frameworks');
    final artifacts = <Map<String, String>>[
      {
        'name': '_Testing_Foundation.framework',
        'source': join(
          '/Applications/Xcode.app/Contents/Developer/Platforms',
          'iPhoneOS.platform/Developer/Library/Frameworks',
          '_Testing_Foundation.framework',
        ),
      },
      {
        'name': 'lib_TestingInterop.dylib',
        'source': join(
          '/Applications/Xcode.app/Contents/Developer/Platforms',
          'iPhoneOS.platform/Developer/usr/lib',
          'lib_TestingInterop.dylib',
        ),
      },
    ];

    var copiedAny = false;
    for (final artifact in artifacts) {
      final source = artifact['source']!;
      final name = artifact['name']!;
      final destination = join(frameworksDir, name);
      final isFramework = name.endsWith('.framework');
      final existsInSdk = isFramework
          ? _fs.directory(source).existsSync()
          : _fs.file(source).existsSync();
      final existsInApp = isFramework
          ? _fs.directory(destination).existsSync()
          : _fs.file(destination).existsSync();
      if (!existsInSdk || existsInApp) {
        continue;
      }

      final copy = await _processManager.run(
        isFramework
            ? ['cp', '-R', source, frameworksDir]
            : ['cp', source, frameworksDir],
      );
      if (copy.exitCode != 0) {
        _logger.err('Failed to copy $name: ${copy.stdErr}');
        return;
      }
      copiedAny = true;
    }

    if (!copiedAny) {
      return;
    }

    var result = await _processManager.run([
      'codesign',
      '-d',
      '--verbose=2',
      appDir,
    ]);
    final identityMatch = RegExp(
      r'^Authority=(.+)$',
      multiLine: true,
    ).firstMatch(result.stdErr);
    if (identityMatch == null) {
      _logger.err('Failed to determine signing identity for Runner.app');
      return;
    }
    final identity = identityMatch.group(1)!;

    for (final artifact in artifacts) {
      final destination = join(frameworksDir, artifact['name']);
      final sign = await _processManager.run([
        'codesign',
        '--force',
        '--sign',
        identity,
        destination,
      ]);
      if (sign.exitCode != 0) {
        _logger.err('Failed to sign ${artifact['name']}: ${sign.stdErr}');
        return;
      }
    }

    final profilePath = join(appDir, 'embedded.mobileprovision');
    final profilePlist = join(
      _rootDirectory.absolute.path,
      'build/ios_integ/Build/Products/Release-iphoneos/_patrol_profile.plist',
    );
    final entitlementsPath = join(
      _rootDirectory.absolute.path,
      'build/ios_integ/Build/Products/Release-iphoneos/_patrol_entitlements.plist',
    );

    result = await _processManager.run([
      'security',
      'cms',
      '-D',
      '-i',
      profilePath,
    ]);
    if (result.exitCode != 0 || result.stdOut.isEmpty) {
      _logger.err('Failed to decode provisioning profile: ${result.stdErr}');
      return;
    }
    _fs.file(profilePlist).writeAsStringSync(result.stdOut);

    result = await _processManager.run([
      '/usr/libexec/PlistBuddy',
      '-x',
      '-c',
      'Print :Entitlements',
      profilePlist,
    ]);
    if (result.exitCode != 0 || result.stdOut.isEmpty) {
      _logger.err('Failed to extract profile entitlements: ${result.stdErr}');
      return;
    }
    _fs.file(entitlementsPath).writeAsStringSync(result.stdOut);

    result = await _processManager.run([
      'codesign',
      '--force',
      '--sign',
      identity,
      '--entitlements',
      entitlementsPath,
      appDir,
    ]);
    if (result.exitCode != 0) {
      _logger.err('Failed to re-sign Runner.app: ${result.stdErr}');
      return;
    }
  }

  // TODO: The path should be joined using platform-specific separator.
  // https://github.com/leancodepl/patrol/issues/1980
  Future<String> xcTestRunPath({
    required bool real,
    required String scheme,
    required String sdkVersion,
    bool absolutePath = true,
  }) async {
    final targetPlatform = real ? 'iphoneos' : 'iphonesimulator';
    final glob = Glob('${scheme}_*$targetPlatform$sdkVersion*.xctestrun');

    var root = 'build/ios_integ/Build/Products';
    if (absolutePath) {
      root = '${_rootDirectory.absolute.path}/$root';
    }
    _logger.detail('Looking for .xctestrun matching ${glob.pattern} at $root');
    final files = await glob.listFileSystem(_fs, root: root).toList();
    if (files.isEmpty) {
      final cause = 'No .xctestrun file was found at $root';
      throwToolExit(cause);
    }

    _logger.detail(
      'Found ${files.length} match(es), the first one will be used',
    );
    for (final file in files) {
      _logger.detail('Found ${file.absolute.path}');
    }

    if (absolutePath) {
      return files.first.absolute.path;
    }
    return files.first.path;
  }

  /// [timestamp] (milliseconds since UNIX epoch) is required for the generation
  /// of unique path for the results bundle.
  String resultBundlePath({required int timestamp}) {
    return _fs
        .file(
          join(_rootDirectory.path, 'build', 'ios_results_$timestamp.xcresult'),
        )
        .absolute
        .path;
  }

  Future<String> getSdkVersion({required bool real}) async {
    // See the versions yourself:
    //
    // $ xcodebuild -showsdks -json | jq '.[] | {sdkVersion, platform} | select(.platform=="iphoneos")'
    // $ xcodebuild -showsdks -json | jq '.[] | {sdkVersion, platform} | select(.platform=="iphonesimulator")'

    final processResult = await _processManager.run([
      'xcodebuild',
      '-showsdks',
      '-json',
    ], runInShell: true);

    String? sdkVersion;
    String? platform;
    final jsonOutput = jsonDecode(processResult.stdOut) as List<dynamic>;
    for (final sdkJson in jsonOutput) {
      final sdk = sdkJson as Map<String, dynamic>;
      if (real && sdk['platform'] == 'iphoneos') {
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

  Future<String> getInstalledAppsEnvVariable(String deviceId) async {
    final processResult = await _processManager.run([
      'xcrun',
      'simctl',
      'listapps',
      deviceId,
    ], runInShell: true);

    const lineSplitter = LineSplitter();
    final ids = lineSplitter
        .convert(processResult.stdOut)
        .where((line) => line.contains('CFBundleIdentifier ='))
        .map((e) => e.substring(e.indexOf('"') + 1, e.lastIndexOf('"')))
        .toList();

    return jsonEncode(ids);
  }
}
