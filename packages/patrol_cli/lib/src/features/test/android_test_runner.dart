import 'dart:convert' show base64Encode, utf8;
import 'dart:io' show systemEncoding;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/features/test/test_runner.dart';
import 'package:process/process.dart';

class AndroidTestRunner extends TestRunner {
  AndroidTestRunner({
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
  Future<void> run(AppOptions options) async {
    final targetName = basename(options.target);
    final task = _logger.task('Building apk for $targetName');

    _fs.currentDirectory = './android';

    final process = await _processManager.start(
      translate(options),
      runInShell: true,
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
      task.complete('Built apk for $targetName');
    } else {
      task.fail('Failed to build apk for $targetName');
    }
  }

  /// Translates [AppOptions] into a proper Gradle invocation.
  @visibleForTesting
  static List<String> translate(AppOptions appOptions) {
    final cmd = <String>['./gradlew'];

    // Add Gradle task
    var flavor = appOptions.flavor ?? '';
    if (flavor.isNotEmpty) {
      flavor = flavor[0].toUpperCase() + flavor.substring(1);
    }
    final gradleTask = ':app:connected${flavor}DebugAndroidTest';
    cmd.add(gradleTask);

    // Add Dart test target
    final target = '-Ptarget=${appOptions.target}';
    cmd.add(target);

    // Add Dart defines encoded in base64
    final dartDefinesString = StringBuffer();
    for (var i = 0; i < appOptions.dartDefines.length; i++) {
      final entry = appOptions.dartDefines.entries.toList()[i];
      dartDefinesString.write('${entry.key}=${entry.value}');
      if (i != appOptions.dartDefines.length - 1) {
        dartDefinesString.write(',');
      }
    }

    final dartDefines = utf8.encode(dartDefinesString.toString());
    cmd.add('-Pdart-defines="${base64Encode(dartDefines)}"');

    return cmd;
  }
}
