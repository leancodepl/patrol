import 'dart:convert' show base64Encode, utf8;

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

// TODO: Consider extending from a (hypotehtical) common `AppOptions` class
class AndroidAppOptions extends AppOptions {
  const AndroidAppOptions({
    required super.target,
    required super.flavor,
    required super.dartDefines,
  });

  @override
  String get desc => 'apk with entrypoint ${basename(target)}';

  List<String> toGradleAssembleInvocation({required bool isWindows}) {
    final flavor = _effectiveFlavor(this.flavor);
    return _toGradleInvocation(
      isWindows: isWindows,
      task: 'assemble${flavor}Debug',
    );
  }

  List<String> toGradleAssembleTestInvocation({required bool isWindows}) {
    final flavor = _effectiveFlavor(this.flavor);
    return _toGradleInvocation(
      isWindows: isWindows,
      task: 'assemble${flavor}DebugAndroidTest',
    );
  }

  List<String> toGradleConnectedTestInvocation({required bool isWindows}) {
    final flavor = _effectiveFlavor(this.flavor);
    return _toGradleInvocation(
      isWindows: isWindows,
      task: 'connected${flavor}DebugAndroidTest',
    );
  }

  String _effectiveFlavor(String? flavor) {
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

  @override
  Future<void> build(AndroidAppOptions options, Device device) async {
    final subject = options.desc;
    final task = _logger.task('Building $subject');

    final process = await _processManager.start(
      options.toGradleAssembleTestInvocation(isWindows: _platform.isWindows),
      runInShell: true,
      workingDirectory: _fs.currentDirectory.childDirectory('android').path,
    )
      ..disposedBy(_disposeScope);

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

  @override
  Future<void> execute(AndroidAppOptions options, Device device) async {
    final subject = '${options.desc} on ${device.description}';
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
    _logger.detail('Uninstalling $packageName from ${device.name}');
    await _adb.uninstall(packageName, device: device.id);
    _logger.detail('Uninstalling $packageName.test from ${device.name}');
    await _adb.uninstall('$packageName.test', device: device.id);
  }
}
