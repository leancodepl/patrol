import 'dart:io' as io;

import 'package:dispose_scope/dispose_scope.dart' hide ProcessDisposed;
import 'package:file/file.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart' show BuildMode;
import 'package:patrol_cli/src/windows/windows_app_options.dart';
import 'package:process/process.dart';

/// Builds and executes Patrol tests on Windows via the automator sidecar.
class WindowsTestBackend {
  /// Creates a [WindowsTestBackend].
  WindowsTestBackend({
    required this._processManager,
    required this._fs,
    required this._rootDirectory,
    required DisposeScope parentDisposeScope,
    required this._logger,
  }) : _disposeScope = DisposeScope() {
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
      process.disposedByTree(scope, onKill: () => flutterBuildKilled = true);
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

      // Launch the EXE directly and kill its process tree on dispose so the
      // Flutter app the runner spawned does not outlive Ctrl+C.
      final process =
          await _processManager.start([
              runnerPath,
              '--app',
              appPath,
              '--test-port',
              options.testServerPort.toString(),
              '--app-port',
              options.appServerPort.toString(),
            ], workingDirectory: _rootDirectory.path)
            ..disposedByTree(scope);

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
    // Flutter writes: build/windows/<arch>/runner/<Mode>/<BINARY_NAME>.exe
    final buildRoot = _rootDirectory
        .childDirectory('build')
        .childDirectory('windows');

    final hostArch = io.Platform.version.contains('arm64') ? 'arm64' : 'x64';
    final otherArch = hostArch == 'arm64' ? 'x64' : 'arm64';

    // Prefer the host architecture so a stale cross-arch build is not picked.
    final candidates = <Directory>[
      buildRoot.childDirectory(hostArch).childDirectory('runner'),
      buildRoot.childDirectory(otherArch).childDirectory('runner'),
      buildRoot.childDirectory('runner'),
    ];

    final modeName = switch (buildMode) {
      BuildMode.debug => 'Debug',
      BuildMode.profile => 'Profile',
      BuildMode.release => 'Release',
    };

    final preferred = _readWindowsBinaryName()?.toLowerCase();

    for (final runnerDir in candidates) {
      final modeDir = runnerDir.childDirectory(modeName);
      if (!modeDir.existsSync()) {
        continue;
      }
      final exes = modeDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.exe'))
          .toList();
      if (exes.isEmpty) {
        continue;
      }
      if (preferred != null) {
        final match = exes.where(
          (f) => p.basenameWithoutExtension(f.path).toLowerCase() == preferred,
        );
        if (match.isNotEmpty) {
          return match.first.absolute.path;
        }
      }
      final withoutHelper = exes.where(
        (f) => !p.basename(f.path).toLowerCase().endsWith('_helper.exe'),
      );
      return (withoutHelper.isNotEmpty ? withoutHelper.first : exes.first)
          .absolute
          .path;
    }

    throwToolExit(
      'Could not find built Windows app exe under ${buildRoot.path}',
    );
  }

  String? _readWindowsBinaryName() {
    final cmake = _rootDirectory
        .childDirectory('windows')
        .childFile('CMakeLists.txt');
    if (!cmake.existsSync()) {
      return null;
    }
    return RegExp(
      r'''set\s*\(\s*BINARY_NAME\s+"([^"]+)"\s*\)''',
      caseSensitive: false,
    ).firstMatch(cmake.readAsStringSync())?.group(1)?.trim();
  }

  Future<String> _ensureRunnerBuilt(DisposeScope scope) async {
    final runnerDir = await _resolveRunnerDirectory();
    final buildDir = _fs.directory(p.join(runnerDir, 'build'));
    final task = _logger.task('Building patrol_windows_runner');

    Future<void> runCmake(List<String> args, {required String label}) async {
      var killed = false;
      final process = await _processManager.start(
        args,
        runInShell: true,
        workingDirectory: runnerDir,
      );
      process.disposedByTree(scope, onKill: () => killed = true);
      process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        final cause = killed
            ? '`$label` was interrupted'
            : '`$label` exited with code $exitCode';
        task.fail(cause);
        if (killed) {
          throwToolInterrupted(cause);
        }
        throwToolExit(cause);
      }
    }

    // Configure when there is no usable cache. A failed configure can still
    // leave CMakeCache.txt behind, so also require a finished generate step.
    final cache = buildDir.childFile('CMakeCache.txt');
    final generated = buildDir.childFile('cmake_install.cmake');
    final needsConfigure = !cache.existsSync() || !generated.existsSync();
    if (needsConfigure) {
      if (buildDir.existsSync()) {
        buildDir.deleteSync(recursive: true);
      }
      try {
        await runCmake([
          'cmake',
          '-S',
          runnerDir,
          '-B',
          buildDir.path,
          // No -G: CMake picks the newest Visual Studio (2022 or 2026).
          '-A',
          'x64',
        ], label: 'cmake configure');
      } catch (_) {
        if (buildDir.existsSync()) {
          buildDir.deleteSync(recursive: true);
        }
        rethrow;
      }
    }

    await runCmake([
      'cmake',
      '--build',
      buildDir.path,
      '--config',
      'Release',
    ], label: 'cmake --build');

    task.complete('Built patrol_windows_runner');

    final exeCandidates = <File>[
      buildDir.childDirectory('bin').childFile('patrol_windows_runner.exe'),
      buildDir.childDirectory('Release').childFile('patrol_windows_runner.exe'),
      buildDir
          .childDirectory('bin')
          .childDirectory('Release')
          .childFile('patrol_windows_runner.exe'),
    ];
    for (final exe in exeCandidates) {
      if (exe.existsSync()) {
        return exe.absolute.path;
      }
    }

    throwToolExit(
      'Built runner not found under ${buildDir.path} '
      '(expected bin/patrol_windows_runner.exe).\n'
      'Ensure CMake and the MSVC "Desktop development with C++" workload '
      'are installed (same toolchain as Flutter Windows).',
    );
  }

  /// Resolves `packages/patrol/windows_runner` the same way web resolves
  /// `web_runner`: via the app's package_config → installed `patrol` root.
  Future<String> _resolveRunnerDirectory() async {
    final packageConfig = await findPackageConfig(
      io.Directory(_rootDirectory.path),
    );
    if (packageConfig == null) {
      throwToolExit(
        'Package configuration not found under ${_rootDirectory.path}.\n'
        'Please run "dart pub get" (or "flutter pub get") first.',
      );
    }

    final patrolPackage = packageConfig['patrol'];
    if (patrolPackage == null) {
      throwToolExit(
        'patrol package not found in package configuration.\n'
        'Please ensure patrol is a dependency and run "dart pub get".',
      );
    }

    final runnerDir = p.join(patrolPackage.root.toFilePath(), 'windows_runner');
    final cmake = _fs.directory(runnerDir).childFile('CMakeLists.txt');

    if (!cmake.existsSync()) {
      throwToolExit(
        'windows_runner not found at: ${cmake.path}\n'
        'This should ship with the patrol package (like web_runner).\n'
        'Please ensure patrol is properly installed.',
      );
    }

    return _fs.directory(runnerDir).absolute.path;
  }
}
