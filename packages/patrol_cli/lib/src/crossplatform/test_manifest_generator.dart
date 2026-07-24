import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest.dart';
import 'package:process/process.dart';

/// Discovers Dart tests at build time by running a host `flutter test` in
/// discovery mode (`PATROL_TEST_DISCOVERY`) and serializing the Dart test tree
/// to a manifest JSON.
///
/// This step is platform-agnostic: the same manifest is consumed by the
/// per-platform codegen (iOS XCTest via `XcodeTestCodegen`, Android JUnit via
/// `AndroidTestCodegen`) so that generated native test names stay byte-identical
/// to what runtime discovery would produce.
class TestManifestGenerator {
  TestManifestGenerator({
    required ProcessManager processManager,
    required Directory rootDirectory,
    required Logger logger,
  }) : _processManager = processManager,
       _rootDirectory = rootDirectory,
       _logger = logger;

  final ProcessManager _processManager;
  final Directory _rootDirectory;
  final Logger _logger;

  /// Runs the bundle on the host in discovery mode and returns the absolute
  /// path to the generated manifest, or `null` if discovery failed.
  ///
  /// Failures are intentionally non-fatal: the caller can fall back to the
  /// native runtime discovery when the manifest is absent.
  Future<String?> generate(FlutterAppOptions flutter, DisposeScope scope) async {
    final manifestFile = _rootDirectory
        .childDirectory('build')
        .childDirectory('patrol')
        .childFile('patrol_test_manifest.json');
    manifestFile.parent.createSync(recursive: true);
    if (manifestFile.existsSync()) {
      manifestFile.deleteSync();
    }

    final task = _logger.task('Discovering Dart tests at build time');
    final process =
        await _processManager.start(
            flutter.toFlutterTestDiscoveryInvocation(
              manifestOutputPath: manifestFile.absolute.path,
            ),
            runInShell: true,
            workingDirectory: _rootDirectory.path,
          )
          ..disposedBy(scope);
    process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
    process.listenStdErr((l) => _logger.detail('\t$l')).disposedBy(scope);
    final exitCode = await process.exitCode;

    if (exitCode != 0 || !manifestFile.existsSync()) {
      task.fail(
        'Build-time test discovery failed (exit code $exitCode); the native '
        'side will fall back to runtime discovery',
      );
      return null;
    }

    task.complete('Discovered Dart tests → ${manifestFile.path}');
    _reportDiscoveredTests(manifestFile, flutter);
    return manifestFile.absolute.path;
  }

  /// Prints a human-readable summary of the discovered tests on the visible
  /// (non-verbose) channel: how many were found, grouped by the source file they
  /// live in, with skipped tests flagged. Best-effort - any parsing issue is
  /// swallowed so it can never fail the build.
  void _reportDiscoveredTests(File manifestFile, FlutterAppOptions flutter) {
    final TestManifest manifest;
    try {
      manifest = TestManifest.parse(manifestFile.readAsStringSync());
    } on Object {
      return;
    }

    final tests = manifest.tests;
    if (tests.isEmpty) {
      _logger.info('No Dart tests discovered.');
      return;
    }

    // Group tests by their source file, preserving discovery order.
    final byFile = <String, List<DiscoveredTest>>{};
    for (final test in tests) {
      byFile.putIfAbsent(test.topLevelGroup, () => []).add(test);
    }

    final skippedTotal = tests.where((t) => t.skip).length;
    final buffer = StringBuffer()
      ..writeln(
        'Discovered ${tests.length} Dart test(s)'
        '${skippedTotal > 0 ? ' ($skippedTotal skipped)' : ''} '
        'in ${byFile.length} file(s):',
      );

    for (final entry in byFile.entries) {
      final file = _sourceFileFor(entry.key, flutter.target);
      final skippedInFile = entry.value.where((t) => t.skip).length;
      buffer
        ..writeln()
        ..writeln(
          '  $file  (${entry.value.length} test(s)'
          '${skippedInFile > 0 ? ', $skippedInFile skipped' : ''})',
        );
      for (final test in entry.value) {
        buffer.writeln('    • ${test.dartName}${test.skip ? '  [skip]' : ''}');
      }
    }

    _logger.info(buffer.toString());
  }

  /// Reconstructs the source file path a top-level group came from. The bundler
  /// derives the group name from the file's path relative to the test directory
  /// (`generateGroupsCode`: `/` → `__` → `.`), so this reverses it: `.` → `/`
  /// plus the `.dart` extension, under the test directory (the directory of the
  /// bundle [target]). Falls back to the raw group name if the reconstructed
  /// file does not exist on disk.
  String _sourceFileFor(String topLevelGroup, String target) {
    if (topLevelGroup.isEmpty) {
      return '(top-level)';
    }
    final path = _rootDirectory.fileSystem.path;
    final testDir = path.dirname(target);
    final relative = '${topLevelGroup.replaceAll('.', '/')}.dart';
    final candidate = path.join(testDir, relative);
    if (_rootDirectory.childFile(candidate).existsSync()) {
      return candidate;
    }
    return topLevelGroup;
  }
}
