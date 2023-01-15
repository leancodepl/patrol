import 'dart:io' show systemEncoding;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';
import 'package:patrol_cli/src/features/test/test_runner.dart';
import 'package:process/process.dart';

class IOSTestRunner extends TestRunner {
  IOSTestRunner({
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
  Future<void> run(AppOptions options, Device device) async {
    final targetName = basename(options.target);
    final task = _logger
        .task('Building app for $targetName and running it on ${device.id}');

    final process = await _processManager.start(
      translateXcodebuild(options, device),
      runInShell: true,
      workingDirectory: _fs.currentDirectory.childDirectory('ios').path,
    );

    process.stdout.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      _logger.detail('\t$msg');
    }).disposedBy(_disposeScope);

    process.stderr.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      _logger.err('\t$msg');
    }).disposedBy(_disposeScope);

    final exitCode = await process.exitCode;

    if (exitCode == 0) {
      task.complete('Built and ran apk for $targetName on ${device.id}');
    } else {
      task.fail('Failed to build apk for $targetName and run ');
    }
  }

  @visibleForTesting
  static List<String> translateFlutterBuild(AppOptions appOptions) {
    final cmd = [
      ...['flutter', 'build', 'ios'],
      ...['--config-only', '--no-codesign', '--debug'],
      if (appOptions.flavor != null) ...['--flavor', appOptions.flavor!],
      ...['--target', appOptions.target],
      '--dart-define',
      for (final dartDefine in appOptions.dartDefines.entries) ...[
        '--dart-define',
        '${dartDefine.key}=${dartDefine.value}',
      ],
      // TODO: Add support for test label
    ];

    return cmd;
  }

  /// Translates [AppOptions] into a proper Gradle invocation.
  @visibleForTesting
  static List<String> translateXcodebuild(
    AppOptions appOptions,
    Device device,
  ) {
    final cmd = [
      ...['xcodebuild', 'test'],
      ...['-workspace', 'Runner.xcworkspace'],
      ...['-scheme', 'Runner'],
      // TODO: Add support for flavors
      ...['-xcconfig', 'Flutter/Debug.xcconfig'],
      ...['-configuration', 'Debug'],
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
