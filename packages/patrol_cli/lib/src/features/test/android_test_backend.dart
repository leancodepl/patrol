import 'dart:convert' show base64Encode, utf8;
import 'dart:io' show Process;

import 'package:adb/adb.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/common/extensions/process.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';
import 'package:patrol_cli/src/features/test/test_backend.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

class AndroidAppOptions extends AppOptions {
  const AndroidAppOptions({
    required super.target,
    required super.flavor,
    required super.dartDefines,
  });

  @override
  String get description => 'apk with entrypoint ${basename(target)}';

  List<String> toGradleAssembleInvocation({required bool isWindows}) {
    return _toGradleInvocation(
      isWindows: isWindows,
      task: 'assemble${_effectiveFlavor}Debug',
    );
  }

  List<String> toGradleAssembleTestInvocation({required bool isWindows}) {
    return _toGradleInvocation(
      isWindows: isWindows,
      task: 'assemble${_effectiveFlavor}DebugAndroidTest',
    );
  }

  List<String> toGradleConnectedTestInvocation({required bool isWindows}) {
    return _toGradleInvocation(
      isWindows: isWindows,
      task: 'connected${_effectiveFlavor}DebugAndroidTest',
    );
  }

  String get _effectiveFlavor {
    var flavor = this.flavor ?? '';
    if (flavor.isNotEmpty) {
      flavor = flavor[0].toUpperCase() + flavor.substring(1);
    }
    return flavor;
  }

  /// Translates these options into a proper Gradle invocation.
  List<String> _toGradleInvocation({
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
    cmd.add(':app:$task');

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
class AndroidTestBackend extends TestBackend {
  AndroidTestBackend({
    required Adb adb,
    required ProcessManager processManager,
    required Platform platform,
    required FileSystem fs,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _adb = adb,
        _processManager = processManager,
        _fs = fs,
        _platform = platform,
        _disposeScope = DisposeScope(),
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final Adb _adb;
  final ProcessManager _processManager;
  final Platform _platform;
  final FileSystem _fs;
  final DisposeScope _disposeScope;
  final Logger _logger;

  static const _interrupted = 130;

  @override
  Future<void> build(AndroidAppOptions options, Device device) async {
    await _disposeScope.run((scope) async {
      final subject = options.description;
      final task = _logger.task('Building $subject');

      Process process;
      int exitCode;

      // :app:assembleDebug

      process = await _processManager.start(
        options.toGradleAssembleInvocation(isWindows: _platform.isWindows),
        runInShell: true,
        workingDirectory: _fs.currentDirectory.childDirectory('android').path,
      )
        ..disposedBy(scope);
      process.listenStdOut((l) => _logger.detail('\t: $l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);
      exitCode = await process.exitCode;
      if (exitCode == _interrupted) {
        const cause = 'Gradle build interrupted';
        task.fail('Failed to build $subject ($cause)');
        throw Exception(cause);
      } else if (exitCode != 0) {
        final cause = 'Gradle build failed with code $exitCode';
        task.fail('Failed to build $subject ($cause)');
        throw Exception(cause);
      }

      // :app:assembleDebugAndroidTest

      process = await _processManager.start(
        options.toGradleAssembleTestInvocation(isWindows: _platform.isWindows),
        runInShell: true,
        workingDirectory: _fs.currentDirectory.childDirectory('android').path,
      )
        ..disposedBy(scope);
      process.listenStdOut((l) => _logger.detail('\t: $l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);
      exitCode = await process.exitCode;
      if (exitCode == 0) {
        task.complete('Completed building $subject');
      } else if (exitCode == _interrupted) {
        const cause = 'Gradle build interrupted';
        task.fail('Failed to build $subject ($cause)');
        throw Exception(cause);
      } else {
        final cause = 'Gradle build failed with code $exitCode';
        task.fail('Failed to build $subject ($cause)');
        throw Exception(cause);
      }
    });
  }

  @override
  Future<void> execute(AndroidAppOptions options, Device device) async {
    await _disposeScope.run((scope) async {
      final subject = '${options.description} on ${device.description}';
      final task = _logger.task('Executing tests of $subject');

      final process = await _processManager.start(
        options.toGradleConnectedTestInvocation(isWindows: _platform.isWindows),
        runInShell: true,
        environment: {
          'ANDROID_SERIAL': device.id,
        },
        workingDirectory: _fs.currentDirectory.childDirectory('android').path,
      )
        ..disposedBy(scope);
      process.listenStdOut((l) => _logger.detail('\t: $l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);

      final exitCode = await process.exitCode;
      if (exitCode == 0) {
        task.complete('Completed executing $subject');
      } else if (exitCode == _interrupted) {
        const cause = 'Gradle test execution interrupted';
        task.fail('Failed to execute tests of $subject ($cause)');
        throw Exception(cause);
      } else {
        final cause = 'Gradle test execution failed with code $exitCode';
        task.fail('Failed to execute tests of $subject ($cause)');
        throw Exception(cause);
      }
    });
  }

  @override
  Future<void> uninstall(String appId, Device device) async {
    _logger.detail('Uninstalling $appId from ${device.name}');
    await _adb.uninstall(appId, device: device.id);
    _logger.detail('Uninstalling $appId.test from ${device.name}');
    await _adb.uninstall('$appId.test', device: device.id);
  }
}
