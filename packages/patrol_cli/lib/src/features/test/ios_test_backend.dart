import 'dart:io' show systemEncoding;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:path/path.dart' show basename, join;
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';
import 'package:patrol_cli/src/features/test/test_backend.dart';
import 'package:process/process.dart';

// TODO: Consider extending from a (hypotehtical) common `AppOptions` class
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
  String get desc => 'app with entrypoint ${basename(target)}';

  /// Translates these options into a proper flutter build invocation, which
  /// runs before xcodebuild and performs configuration.
  List<String> toFlutterBuildInvocation(Device device) {
    final cmd = [
      ...['flutter', 'build', 'ios'],
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
      // TODO: Add support for test label
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
  List<String> testWithoutBuildingInvocation(Device device) {
    const prefix = '../build/ios_integ/Build/Products';
    final cmd = [
      ...['xcodebuild', 'test-without-building'],
      ...[
        '-xctestrun',
        // FIXME: determine the version:
        // xcodebuild -showsdks | grep iphone | awk -F '-sdk' '{print $2}' | xargs
        if (device.real)
          join(prefix, 'Runner_iphoneos16.2-arm64.xctestrun')
        else
          join(prefix, 'Runner_iphonesimulator16.2-arm64-x86_64.xctestrun')
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
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _processManager = processManager,
        _fs = fs,
        _disposeScope = DisposeScope(),
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final ProcessManager _processManager;
  final FileSystem _fs;
  final DisposeScope _disposeScope;
  final Logger _logger;

  @override
  Future<void> build(IOSAppOptions options, Device device) async {
    final subject = '${options.desc} for ${device.platformDescription}';
    final task = _logger.task('Building $subject');

    // flutter build ios --config-only

    final flutterProcess = await _processManager.start(
      options.toFlutterBuildInvocation(device),
      runInShell: true,
    );

    flutterProcess.stdout.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      _logger.detail('\t$msg');
    }).disposedBy(_disposeScope);

    flutterProcess.stderr.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      _logger.err('\t$msg');
    }).disposedBy(_disposeScope);

    var exitCode = await flutterProcess.exitCode;
    if (exitCode != 0) {
      task.fail('Failed to build $subject');
      throw Exception('flutter build exited with code $exitCode');
    }

    // xcodebuild build-for-testing

    final xcodebuildProcess = await _processManager.start(
      options.buildForTestingInvocation(device),
      runInShell: true,
      workingDirectory: _fs.currentDirectory.childDirectory('ios').path,
    );

    xcodebuildProcess.stdout.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      _logger.detail('\t$msg');
    }).disposedBy(_disposeScope);

    xcodebuildProcess.stderr.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      _logger.err('\t$msg');
    }).disposedBy(_disposeScope);

    exitCode = await xcodebuildProcess.exitCode;
    if (exitCode == 0) {
      task.complete('Built $subject');
    } else {
      task.fail('Failed to build $subject');
      throw Exception('xcodebuild exited with code $exitCode');
    }
  }

  @override
  Future<void> execute(IOSAppOptions options, Device device) async {
    final subject = '${options.desc} on ${device.description}';
    final task = _logger.task('Running $subject');

    final xcodebuildProcess = await _processManager.start(
      options.buildForTestingInvocation(device),
      runInShell: true,
      workingDirectory: _fs.currentDirectory.childDirectory('ios').path,
    );

    xcodebuildProcess.stdout.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      _logger.detail('\t$msg');
    }).disposedBy(_disposeScope);

    xcodebuildProcess.stderr.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      _logger.err('\t$msg');
    }).disposedBy(_disposeScope);

    final exitCode = await xcodebuildProcess.exitCode;
    if (exitCode == 0) {
      task.complete('Built $subject');
    } else {
      task.fail('Failed to build $subject');
      throw Exception('xcodebuild exited with code $exitCode');
    }
  }

  Future<void> uninstall({
    required Device device,
    required String bundleId,
  }) async {
    _logger.info('Uninstalling $bundleId from ${device.name}');
    if (device.real) {
      // uninstall from iOS device
      await _processManager.run(
        [
          'ideviceinstaller',
          ...['--udid', device.id],
          ...['--uninstall', bundleId],
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
          bundleId,
        ],
        runInShell: true,
      );
    }
  }
}
