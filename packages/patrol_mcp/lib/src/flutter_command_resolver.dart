import 'dart:io' as io;

import 'package:path/path.dart' as p;
import 'package:patrol_cli/patrol_cli.dart' show FlutterCommand;

/// Outcome of resolving which Flutter command MCP-driven `patrol develop`
/// sessions should use.
class FlutterCommandResolution {
  const FlutterCommandResolution({
    required this.command,
    required this.reason,
    this.isWarning = false,
  });

  /// The command to pass through to `patrol_cli`, or `null` to let it use its
  /// default (`flutter`). A `--flutter-command` in `PATROL_FLAGS` still
  /// overrides this downstream.
  final FlutterCommand? command;

  /// Human-readable explanation of the choice, for logging.
  final String reason;

  /// Whether [reason] describes a fallback the user probably wants to fix
  /// (e.g. an FVM pin without `fvm` on PATH).
  final bool isWarning;
}

/// Resolves the Flutter command for MCP-driven develop sessions.
///
/// Order, highest priority first:
/// 1. `--flutter-command` in `PATROL_FLAGS` — handled downstream by
///    `DevelopOptions.parseArgs`, not here.
/// 2. `PATROL_FLUTTER_COMMAND` env var — the explicit escape hatch;
///    auto-detection never overrides it.
/// 3. FVM auto-detection: if the project (or an ancestor) is FVM-pinned, use
///    the `.fvm/flutter_sdk` symlink, else `fvm flutter`.
/// 4. Fallback: `null`, so `patrol_cli` uses `flutter`.
///
/// The filesystem and PATH lookups are injectable so the logic is unit-testable.
class FlutterCommandResolver {
  FlutterCommandResolver({
    Map<String, String>? environment,
    bool Function(String path)? pathExists,
    bool Function()? isFvmInstalled,
    bool Function()? isFlutterInstalled,
  }) : _env = environment ?? io.Platform.environment,
       _pathExists = pathExists ?? _defaultPathExists {
    _isFvmInstalled =
        isFvmInstalled ?? () => _exeOnPath(_env, _pathExists, 'fvm');
    _isFlutterInstalled =
        isFlutterInstalled ?? () => _exeOnPath(_env, _pathExists, 'flutter');
  }

  final Map<String, String> _env;
  final bool Function(String path) _pathExists;
  late final bool Function() _isFvmInstalled;
  late final bool Function() _isFlutterInstalled;

  FlutterCommandResolution resolve({required String projectRoot}) {
    // (2) Explicit env var wins over auto-detection.
    final envCmd = _env['PATROL_FLUTTER_COMMAND'];
    if (envCmd != null && envCmd.isNotEmpty) {
      return FlutterCommandResolution(
        command: FlutterCommand.parse(envCmd),
        reason: 'from PATROL_FLUTTER_COMMAND',
      );
    }

    // (3) FVM auto-detection.
    final pinDir = _findFvmPin(projectRoot);
    if (pinDir != null) {
      // Prefer the `.fvm/flutter_sdk` symlink -- runs the pinned SDK directly,
      // without needing `fvm` on PATH.
      final sdkFlutter = _fvmSdkExecutable(pinDir);
      if (sdkFlutter != null) {
        return FlutterCommandResolution(
          command: FlutterCommand(sdkFlutter),
          reason: 'auto-detected FVM SDK at $pinDir/.fvm/flutter_sdk',
        );
      }
      // Symlink not materialized (e.g. fresh clone); let `fvm` resolve it.
      if (_isFvmInstalled()) {
        return FlutterCommandResolution(
          command: FlutterCommand.parse('fvm flutter'),
          reason: 'auto-detected FVM pin in $pinDir; using `fvm flutter`',
        );
      }
      return FlutterCommandResolution(
        command: null,
        reason:
            'FVM pin found in $pinDir but no .fvm/flutter_sdk and `fvm` not on '
            'PATH; using `flutter`',
        isWarning: true,
      );
    }

    // (3b) No pin, but `flutter` is absent while `fvm` is present: use
    // `fvm flutter` so fvm-only setups keep working. A usable `flutter` is
    // left untouched.
    if (!_isFlutterInstalled() && _isFvmInstalled()) {
      return FlutterCommandResolution(
        command: FlutterCommand.parse('fvm flutter'),
        reason: 'no FVM pin and `flutter` not on PATH; using `fvm flutter`',
      );
    }

    // (4) Default.
    return const FlutterCommandResolution(
      command: null,
      reason: 'using `flutter`',
    );
  }

  /// Walks up from [projectRoot] looking for an FVM pin (`.fvmrc` or
  /// `.fvm/fvm_config.json`). Bounded: stops at a repository boundary (a `.git`
  /// entry) or the filesystem root, so the search never escapes the project.
  String? _findFvmPin(String projectRoot) {
    var dir = p.canonicalize(projectRoot);
    while (true) {
      if (_pathExists(p.join(dir, '.fvmrc')) ||
          _pathExists(p.join(dir, '.fvm', 'fvm_config.json'))) {
        return dir;
      }
      if (_pathExists(p.join(dir, '.git'))) {
        return null;
      }
      final parent = p.dirname(dir);
      if (parent == dir) {
        return null; // reached the filesystem root
      }
      dir = parent;
    }
  }

  /// The pinned SDK's `flutter` via the `.fvm/flutter_sdk` symlink, or `null`
  /// if it isn't materialized (a dangling link resolves to a missing binary).
  String? _fvmSdkExecutable(String pinDir) {
    final binName = io.Platform.isWindows ? 'flutter.bat' : 'flutter';
    final path = p.join(pinDir, '.fvm', 'flutter_sdk', 'bin', binName);
    return _pathExists(path) ? path : null;
  }

  static bool _defaultPathExists(String path) =>
      io.File(path).existsSync() || io.Directory(path).existsSync();

  /// Whether an executable named [base] is resolvable on PATH. Handles the
  /// Windows `.bat`/`.exe`/`.cmd` wrappers rather than looking for a bare file.
  static bool _exeOnPath(
    Map<String, String> env,
    bool Function(String path) pathExists,
    String base,
  ) {
    final pathVar = env['PATH'] ?? env['Path'] ?? env['path'];
    if (pathVar == null || pathVar.isEmpty) {
      return false;
    }
    final names = io.Platform.isWindows
        ? ['$base.bat', '$base.exe', '$base.cmd', base]
        : [base];
    for (final dir in pathVar.split(io.Platform.isWindows ? ';' : ':')) {
      if (dir.isEmpty) {
        continue;
      }
      for (final name in names) {
        if (pathExists(p.join(dir, name))) {
          return true;
        }
      }
    }
    return false;
  }
}
