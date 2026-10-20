import 'dart:io';

import 'package:path/path.dart' as p;

/// Returns the workspace root directories the MCP client has advertised (via the
/// `roots` capability), or an empty list if the client provides none. Returning
/// filesystem paths (not `file://` URIs) keeps [ProjectResolver] free of any MCP
/// dependency so it stays easy to unit-test.
typedef RootsReader = Future<List<String>> Function();

/// Resolves the Flutter project directory the MCP server operates on.
///
/// A globally-installed server is pointed at a project through one of several
/// signals. They are tried in precedence order — **explicit user config wins
/// over client-automatic signals** — and the first that leads to a
/// `pubspec.yaml` (walking upward) is used:
///
///   1. `--project-root`, then the `PROJECT_ROOT` env — explicit overrides,
///      needed for subdir apps and clients with weak signals.
///   2. Client `roots` — the workspace root(s) the editor advertises.
///   3. `CLAUDE_PROJECT_DIR` env — set by Claude Code/Desktop for stdio servers.
///   4. The current working directory.
///
/// The result is cached: resolution happens once per server lifetime (most
/// clients spawn a separate server per window, so a single resolve is enough).
class ProjectResolver {
  ProjectResolver({
    required RootsReader readRoots,
    String? projectRootOverride,
    Map<String, String>? environment,
    String Function()? currentDirectory,
  }) : _readRoots = readRoots,
       _projectRootOverride = projectRootOverride,
       _env = environment ?? Platform.environment,
       _currentDirectory = currentDirectory ?? (() => Directory.current.path);

  final RootsReader _readRoots;

  /// From `--project-root`; takes precedence over every other signal.
  final String? _projectRootOverride;
  final Map<String, String> _env;
  final String Function() _currentDirectory;

  String? _cached;

  /// Resolves (and caches) the absolute project root, or throws
  /// [ProjectResolutionException] if no `pubspec.yaml` can be found from any
  /// signal.
  ///
  /// Signals are evaluated in precedence order and short-circuit on the first
  /// hit — so an explicit `PROJECT_ROOT` avoids an unnecessary `roots` round-trip
  /// to the client.
  Future<String> resolve() async {
    if (_cached case final cached?) {
      return cached;
    }
    final attempts = <String>[];

    // 1. Explicit overrides win over client-automatic signals.
    var hit = _tryDir('--project-root', _projectRootOverride, attempts);
    hit ??= _tryDir('PROJECT_ROOT', _env['PROJECT_ROOT'], attempts);
    // 2. Client-advertised workspace roots (only read if not already resolved).
    hit ??= await _tryRoots(attempts);
    // 3. Claude sets this for stdio servers.
    hit ??= _tryDir('CLAUDE_PROJECT_DIR', _env['CLAUDE_PROJECT_DIR'], attempts);
    // 4. Working directory the client launched us in.
    hit ??= _tryDir('cwd', _currentDirectory(), attempts);

    if (hit == null) {
      throw ProjectResolutionException(attempts);
    }
    return _cached = p.canonicalize(hit);
  }

  /// Records [dir] as a tried signal and returns its project root (walking up to
  /// a `pubspec.yaml`), or `null` if [dir] is empty or has no pubspec.
  String? _tryDir(String label, String? dir, List<String> attempts) {
    if (dir == null || dir.trim().isEmpty) {
      return null;
    }
    attempts.add('$label=$dir');
    return _findPubspecDir(dir);
  }

  Future<String?> _tryRoots(List<String> attempts) async {
    for (final root in await _safeReadRoots()) {
      if (_tryDir('root', root, attempts) case final hit?) {
        return hit;
      }
    }
    return null;
  }

  Future<List<String>> _safeReadRoots() async {
    try {
      return await _readRoots();
    } catch (_) {
      // A client that declares `roots` but fails to answer shouldn't block
      // resolution — fall through to the remaining signals.
      return const [];
    }
  }

  /// Walks up from [start] to the nearest ancestor containing `pubspec.yaml`,
  /// or returns `null` if none exists (or [start] doesn't exist).
  String? _findPubspecDir(String start) {
    var dir = Directory(p.absolute(start));
    if (!dir.existsSync()) {
      return null;
    }
    while (true) {
      if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
        return dir.path;
      }
      final parent = dir.parent;
      if (p.equals(parent.path, dir.path)) {
        return null; // Reached the filesystem root.
      }
      dir = parent;
    }
  }
}

/// Thrown when [ProjectResolver] cannot locate a Flutter project from any signal.
class ProjectResolutionException implements Exception {
  ProjectResolutionException(this.attempts);

  /// The signals that were tried, in order (e.g. `PROJECT_ROOT=./app`, `cwd=/x`).
  final List<String> attempts;

  @override
  String toString() {
    final tried = attempts.isEmpty
        ? 'nothing (no project signals were available)'
        : attempts.join(', ');
    return 'Could not locate a Flutter project: no pubspec.yaml found from any '
        'signal. Tried, in order: $tried. Set PROJECT_ROOT to your project '
        'directory, or open the project as a workspace root in your editor.';
  }
}
