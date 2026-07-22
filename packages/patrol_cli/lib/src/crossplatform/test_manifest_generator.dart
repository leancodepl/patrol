import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
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
    return manifestFile.absolute.path;
  }
}
