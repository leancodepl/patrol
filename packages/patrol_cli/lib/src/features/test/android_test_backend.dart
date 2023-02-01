import 'dart:convert' show base64Encode, utf8;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/common/extensions/process.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

class AndroidAppOptions {
  const AndroidAppOptions({
    required this.target,
    required this.flavor,
    required this.dartDefines,
  });

  final String target;
  final String? flavor;
  final Map<String, String> dartDefines;

  List<String> toGradleAssembleTestInvocation({required bool isWindows}) {
    return toGradleInvocation(isWindows: isWindows, task: 'assemble');
  }

  List<String> toGradleConnectedTestInvocation({required bool isWindows}) {
    return toGradleInvocation(isWindows: isWindows, task: 'connected');
  }

  /// Translates these options into a proper Gradle invocation.
  @visibleForTesting
  List<String> toGradleInvocation({
    required bool isWindows,
    required String task,
  }) {
    final List<String> cmd;
    if (isWindows) {
      cmd = <String>['gradlew.bat'];
    } else {
      cmd = <String>['./gradlew'];
    }

    // Add Gradle task
    var flavor = this.flavor ?? '';
    if (flavor.isNotEmpty) {
      flavor = flavor[0].toUpperCase() + flavor.substring(1);
    }
    final gradleTask = ':app:$task${flavor}DebugAndroidTest';
    cmd.add(gradleTask);

    // Add Dart test target
    final target = '-Ptarget=${this.target}';
    cmd.add(target);

    // Add Dart defines encoded in base64
    if (dartDefines.isNotEmpty) {
      final dartDefinesString = StringBuffer();
      for (var i = 0; i < this.dartDefines.length; i++) {
        final entry = this.dartDefines.entries.toList()[i];
        dartDefinesString.write('${entry.key}=${entry.value}');
        if (i != this.dartDefines.length - 1) {
          dartDefinesString.write(',');
        }
      }

      final dartDefines = utf8.encode(dartDefinesString.toString());
      cmd.add('-Pdart-defines=${base64Encode(dartDefines)}');
    }

    return cmd;
  }
}

/// Provides functionality to build, install, run, and uninstall Android apps.
///
/// This class must be stateless.
class AndroidTestBackend {
  AndroidTestBackend({
    required ProcessManager processManager,
    required Platform platform,
    required FileSystem fs,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _processManager = processManager,
        _fs = fs,
        _platform = platform,
        _disposeScope = DisposeScope(),
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final ProcessManager _processManager;
  final Platform _platform;
  final FileSystem _fs;
  final DisposeScope _disposeScope;
  final Logger _logger;

  Future<void> build(AndroidAppOptions options) async {
    final targetName = basename(options.target);
    final subject = 'apk with entrypoint $targetName';
    final task = _logger.task('Building $subject');

    final process = await _processManager.start(
      options.toGradleAssembleTestInvocation(isWindows: _platform.isWindows),
      runInShell: true,
      workingDirectory: _fs.currentDirectory.childDirectory('android').path,
    );

    process
        .listenStdOut((line) => _logger.detail('\t: $line'))
        .disposedBy(_disposeScope);
    process
        .listenStdErr((line) => _logger.err('\t$line'))
        .disposedBy(_disposeScope);

    final exitCode = await process.exitCode;

    if (exitCode == 0) {
      task.complete('Built $subject');
    } else {
      task.fail('Failed to build $subject');
      throw Exception('Gradle exited with code $exitCode');
    }
  }

  Future<void> execute(AndroidAppOptions options, Device device) async {
    final targetName = basename(options.target);
    final subject = 'apk with entrypoint $targetName on device ${device.id}';
    final task = _logger.task('Running $subject');

    final process = await _processManager.start(
      options.toGradleConnectedTestInvocation(isWindows: _platform.isWindows),
      runInShell: true,
      environment: {
        'ANDROID_SERIAL': device.id,
      },
      workingDirectory: _fs.currentDirectory.childDirectory('android').path,
    );

    process
        .listenStdOut((line) => _logger.detail('\t: $line'))
        .disposedBy(_disposeScope);
    process
        .listenStdErr((line) => _logger.err('\t$line'))
        .disposedBy(_disposeScope);

    final exitCode = await process.exitCode;

    if (exitCode == 0) {
      task.complete('Ran $subject');
    } else {
      task.fail('Failed to run $subject');
      throw Exception('Gradle exited with code $exitCode');
    }
  }

  Future<void> uninstall({
    required Device device,
    required String packageName,
  }) async {
    _logger.info('Uninstalling $packageName from ${device.name}');
    await _processManager.run([
      'adb',
      '-s',
      device.id,
      'uninstall',
      packageName,
    ]);
  }
}
