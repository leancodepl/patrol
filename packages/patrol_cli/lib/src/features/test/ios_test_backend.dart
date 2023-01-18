import 'dart:io' show systemEncoding;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';
import 'package:process/process.dart';

class IOSAppOptions {
  const IOSAppOptions({
    required this.target,
    required this.flavor,
    required this.dartDefines,
    required this.scheme,
    required this.xcconfigFile,
    required this.configuration,
  });

  final String target;
  final String? flavor;
  final Map<String, String> dartDefines;
  final String scheme;
  final String xcconfigFile;
  final String configuration;

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

  /// Translates these options into a proper xcodebuild invocation.
  List<String> toXcodebuildInvocation(Device device) {
    final cmd = [
      ...['xcodebuild', 'test'],
      ...['-workspace', 'Runner.xcworkspace'],
      ...['-scheme', scheme],
      ...['-xcconfig', xcconfigFile],
      ...['-configuration', configuration],
      ...['-sdk', if (device.real) 'iphoneos' else 'iphonesimulator'],
      ...[
        '-destination',
        'platform=${device.real ? 'iOS' : 'iOS Simulator'},name=${device.name}',
      ],
      r'OTHER_SWIFT_FLAGS=$(inherited) -D PATROL_ENABLED',
    ];

    return cmd;
  }
}

class IOSTestBackend {
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

  Future<void> run({
    required Device device,
    required IOSAppOptions options,
  }) async {
    final targetName = basename(options.target);
    final task = _logger
        .task('Building app for $targetName and running it on ${device.id}');

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
      task.fail('Failed to run `flutter build` for $targetName');
      throw Exception('flutter build exited with code $exitCode');
    }

    final xcodebuildProcess = await _processManager.start(
      options.toXcodebuildInvocation(device),
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
      task.complete('Built and ran apk for $targetName on ${device.id}');
    } else {
      task.fail('Failed to build apk for $targetName and run ');
      throw Exception('xcodebuild exited with code $exitCode');
    }
  }
}
