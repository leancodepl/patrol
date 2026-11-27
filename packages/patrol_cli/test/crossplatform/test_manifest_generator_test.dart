import 'dart:async';
import 'dart:io' show Process, ProcessStartMode;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest_generator.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart' show BuildMode;
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

void main() {
  group('failureExcerpt', () {
    test('starts at the first failed load', () {
      final output = [
        'Resolving dependencies...',
        'Got dependencies!',
        '00:00 +0 -1: loading test_bundle.dart [E]',
        '  Unsupported operation: Unsupported platform',
        '  patrol_test/swipe_test.dart 15:5  main',
      ];

      expect(TestManifestGenerator.failureExcerpt(output), output.sublist(2));
    });

    test('starts at the first compilation error', () {
      final output = [
        'Got dependencies!',
        "app.dart:2:8: Error: Dart library 'dart:ui_web' is not available",
        "import 'dart:ui_web';",
      ];

      expect(TestManifestGenerator.failureExcerpt(output), output.sublist(1));
    });

    test('falls back to the last lines', () {
      final output = [for (var i = 0; i < 50; i++) 'line $i'];

      expect(TestManifestGenerator.failureExcerpt(output, maxLines: 3), [
        'line 47',
        'line 48',
        'line 49',
      ]);
    });

    test('caps the excerpt', () {
      final output = ['x [E]', for (var i = 0; i < 50; i++) 'line $i'];

      expect(TestManifestGenerator.failureExcerpt(output), hasLength(40));
    });
  });

  group('generate', () {
    const manifest =
        '{"group":{"name":"","type":"group","skip":false,"entries":[]}}';
    const flutter = FlutterAppOptions(
      command: FlutterCommand('flutter'),
      target: 'patrol_test/test_bundle.dart',
      buildMode: BuildMode.debug,
      flavor: null,
      buildName: null,
      buildNumber: null,
      dartDefines: {},
      dartDefineFromFilePaths: [],
    );

    late MemoryFileSystem fs;
    late Directory root;
    late DisposeScope scope;

    setUp(() {
      fs = MemoryFileSystem.test();
      root = fs.directory('/app')..createSync();
      scope = DisposeScope();
    });

    tearDown(() => scope.dispose());

    Future<String?> generate({required bool succeeds}) {
      return TestManifestGenerator(
        processManager: _DiscoveryProcessManager(fs, succeeds: succeeds),
        rootDirectory: root,
        logger: _QuietLogger(),
      ).generate(flutter, scope, targetPlatform: TargetPlatform.android);
    }

    test('keeps a copy of the manifest for the platform', () async {
      expect(await generate(succeeds: true), isNotNull);

      final copy = TestManifest.buildFile(root, TargetPlatform.android);
      expect(copy.readAsStringSync(), manifest);
    });

    test('leaves no old platform copy after a failed discovery', () async {
      TestManifest.buildFile(root, TargetPlatform.android)
        ..createSync(recursive: true)
        ..writeAsStringSync(manifest);

      expect(await generate(succeeds: false), isNull);

      expect(
        TestManifest.buildFile(root, TargetPlatform.android).existsSync(),
        isFalse,
      );
    });
  });
}

/// Runs discovery by writing the manifest to the path the CLI passes in.
class _DiscoveryProcessManager extends Fake implements ProcessManager {
  _DiscoveryProcessManager(this._fs, {required this.succeeds});

  final FileSystem _fs;
  final bool succeeds;

  @override
  Future<Process> start(
    List<Object> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    const prefix = 'PATROL_MANIFEST_OUTPUT=';
    final output = command
        .map((arg) => '$arg')
        .firstWhere((arg) => arg.startsWith(prefix))
        .substring(prefix.length);
    if (succeeds) {
      _fs
          .file(output)
          .writeAsStringSync(
            '{"group":{"name":"","type":"group","skip":false,"entries":[]}}',
          );
    }
    return _FinishedProcess(succeeds ? 0 : 1);
  }
}

class _FinishedProcess extends Fake implements Process {
  _FinishedProcess(this._exitCode);

  final int _exitCode;

  @override
  Stream<List<int>> get stdout => const Stream.empty();

  @override
  Stream<List<int>> get stderr => const Stream.empty();

  @override
  Future<int> get exitCode => Future.value(_exitCode);
}

class _QuietLogger extends Fake implements Logger {
  @override
  Level get level => Level.info;

  @override
  void detail(String? message, {String? Function(String?)? style}) {}

  @override
  void info(String? message, {String? Function(String?)? style}) {}

  @override
  void err(String? message, {String? Function(String?)? style}) {}

  @override
  ProgressTask task(String message) => _QuietTask();
}

class _QuietTask extends Fake implements ProgressTask {
  @override
  void complete([String? message]) {}

  @override
  void fail([String? message]) {}
}
