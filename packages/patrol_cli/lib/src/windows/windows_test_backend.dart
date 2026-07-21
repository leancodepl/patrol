import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart' show BuildMode;
import 'package:patrol_cli/src/windows/windows_app_options.dart';
import 'package:process/process.dart';

/// Builds and executes Patrol tests on Windows via the C# sidecar runner.
class WindowsTestBackend {
  /// Creates a [WindowsTestBackend].
  WindowsTestBackend({
    required ProcessManager processManager,
    required FileSystem fs,
    required Directory rootDirectory,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  }) : _processManager = processManager,
       _fs = fs,
       _rootDirectory = rootDirectory,
       _disposeScope = DisposeScope(),
       _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final ProcessManager _processManager;
  final FileSystem _fs;
  final Directory _rootDirectory;
  final DisposeScope _disposeScope;
  final Logger _logger;

  /// Builds the Flutter Windows app with the Patrol test entrypoint.
  Future<void> build(WindowsAppOptions options) async {
    await _disposeScope.run((scope) async {
      final subject = options.description;
      final task = _logger.task(
        'Building $subject (${options.flutter.buildMode.name})',
      );

      var flutterBuildKilled = false;
      final process = await _processManager.start(
        options.toFlutterBuildInvocation(options.flutter.buildMode),
        runInShell: true,
        workingDirectory: _rootDirectory.path,
      );
      scope.addDispose(() {
        process.kill();
        flutterBuildKilled = true;
      });
      process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);

      final exitCode = await process.exitCode;
      final flutterCommand = options.flutter.command;
      if (exitCode != 0) {
        final cause =
            '`$flutterCommand build windows` exited with code $exitCode';
        task.fail('Failed to build $subject ($cause)');
        throwToolExit(cause);
      } else if (flutterBuildKilled) {
        final cause = '`$flutterCommand build windows` was interrupted';
        task.fail('Failed to build $subject ($cause)');
        throwToolInterrupted(cause);
      }

      task.complete('Completed building $subject');
    });
  }

  /// Runs the Windows sidecar against the previously built app.
  Future<void> execute(WindowsAppOptions options, Device device) async {
    await _disposeScope.run((scope) async {
      final subject = '${options.description} on ${device.description}';
      final task = _logger.task('Running $subject');

      final appPath = _resolveBuiltAppPath(options.flutter.buildMode);
      final runnerPath = await _ensureRunnerBuilt(scope);

      final process =
          await _processManager.start(
              [
                runnerPath,
                '--app',
                appPath,
                '--test-port',
                options.testServerPort.toString(),
                '--app-port',
                options.appServerPort.toString(),
              ],
              runInShell: true,
              workingDirectory: _rootDirectory.path,
            )
            ..disposedBy(scope);

      process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);

      final exitCode = await process.exitCode;
      if (exitCode == 0) {
        task.complete('Completed executing $subject');
      } else {
        final cause = 'patrol_windows_runner exited with code $exitCode';
        task.fail('Failed to execute tests of $subject ($cause)');
        throwToolExit(cause);
      }
    });
  }

  String _resolveBuiltAppPath(BuildMode buildMode) {
    // Flutter writes: build/windows/x64/runner/<Mode>/<project>.exe
    final buildRoot = _rootDirectory.childDirectory('build').childDirectory(
      'windows',
    );

    final candidates = <Directory>[
      buildRoot.childDirectory('x64').childDirectory('runner'),
      buildRoot.childDirectory('arm64').childDirectory('runner'),
      buildRoot.childDirectory('runner'),
    ];

    final modeName = switch (buildMode) {
      BuildMode.debug => 'Debug',
      BuildMode.profile => 'Profile',
      BuildMode.release => 'Release',
    };

    for (final runnerDir in candidates) {
      final modeDir = runnerDir.childDirectory(modeName);
      if (!modeDir.existsSync()) {
        continue;
      }
      final exes = modeDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.exe'))
          .where((f) {
            final name = p.basename(f.path).toLowerCase();
            return name != 'flutter_windows.dll' && !name.contains('helper');
          })
          .toList();
      if (exes.isNotEmpty) {
        return exes.first.absolute.path;
      }
    }

    throwToolExit(
      'Could not find built Windows app exe under ${buildRoot.path}',
    );
  }

  Future<String> _ensureRunnerBuilt(DisposeScope scope) async {
    final runnerProject = _resolveRunnerProjectPath();
    final task = _logger.task('Building patrol_windows_runner');

    final process = await _processManager.start(
      [
        'dotnet',
        'build',
        runnerProject,
        '-c',
        'Release',
        '-v',
        'q',
      ],
      runInShell: true,
    );
    process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
    process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      final cause = '`dotnet build` exited with code $exitCode';
      task.fail(cause);
      throwToolExit(cause);
    }
    task.complete('Built patrol_windows_runner');

    final projectDir = _fs.file(runnerProject).parent;
    final exe = projectDir
        .childDirectory('bin')
        .childDirectory('Release')
        .childDirectory('net8.0-windows')
        .childFile('patrol_windows_runner.exe');

    if (!exe.existsSync()) {
      throwToolExit('Built runner not found at ${exe.path}');
    }
    return exe.absolute.path;
  }

  String _resolveRunnerProjectPath() {
    // From an app using path: ../packages/patrol, or from the monorepo itself.
    final fromPackage = _rootDirectory
        .childDirectory('.dart_tool')
        .childDirectory('package_config.json');

    final candidates = <File>[
      _rootDirectory
          .childDirectory('packages')
          .childDirectory('patrol')
          .childDirectory('windows_runner')
          .childFile('Patrol.WindowsRunner.csproj'),
      _rootDirectory.parent
          .childDirectory('patrol')
          .childDirectory('windows_runner')
          .childFile('Patrol.WindowsRunner.csproj'),
      _rootDirectory.parent.parent
          .childDirectory('packages')
          .childDirectory('patrol')
          .childDirectory('windows_runner')
          .childFile('Patrol.WindowsRunner.csproj'),
      // When running inside packages/patrol/example-like layouts:
      _rootDirectory.parent
          .childDirectory('windows_runner')
          .childFile('Patrol.WindowsRunner.csproj'),
    ];

    for (final file in candidates) {
      if (file.existsSync()) {
        return file.absolute.path;
      }
    }

    // Last resort: walk up looking for packages/patrol/windows_runner
    var dir = _rootDirectory;
    for (var i = 0; i < 6; i++) {
      final candidate = dir
          .childDirectory('packages')
          .childDirectory('patrol')
          .childDirectory('windows_runner')
          .childFile('Patrol.WindowsRunner.csproj');
      if (candidate.existsSync()) {
        return candidate.absolute.path;
      }
      if (dir.parent.path == dir.path) {
        break;
      }
      dir = dir.parent;
    }

    throwToolExit(
      'Could not locate packages/patrol/windows_runner/Patrol.WindowsRunner.csproj '
      '(looked from ${_rootDirectory.path}; package_config=${fromPackage.path})',
    );
  }
}
