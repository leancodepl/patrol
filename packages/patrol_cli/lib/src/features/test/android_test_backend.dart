import 'dart:convert' show utf8, base64Encode;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
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

  /// Translates these options into a proper Gradle invocation.
  List<String> toGradleInvocation(Platform platform) {
    final List<String> cmd;
    if (platform.isWindows) {
      cmd = <String>['gradlew.bat'];
    } else {
      cmd = <String>['./gradlew'];
    }

    // Add Gradle task
    var flavor = this.flavor ?? '';
    if (flavor.isNotEmpty) {
      flavor = flavor[0].toUpperCase() + flavor.substring(1);
    }
    final gradleTask = ':app:connected${flavor}DebugAndroidTest';
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

  Future<void> run({
    required Device device,
    required AndroidAppOptions options,
  }) async {
    final targetName = basename(options.target);
    final task = _logger
        .task('Building apk for $targetName and running it on ${device.id}');

    final process = await _processManager.start(
      options.toGradleInvocation(_platform),
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
      task.complete('Built and ran apk for $targetName on ${device.id}');
    } else {
      task.fail(
        'Failed to build and run apk for $targetName and run ${device.id}',
      );
      throw Exception('Gradle exited with code $exitCode');
    }
  }
}
