import 'dart:io' show Platform;

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' show Context;
import 'package:patrol_cli/src/runner/patrol_command_runner.dart';

/// The workspace root directories the MCP client has advertised (via the
/// `roots` capability), as filesystem paths, or an empty list when the client
/// provides none.
typedef RootsReader = Future<List<String>> Function();

/// A project and, when the caller named a test file, that file's path relative
/// to it — which is not the path the caller gave when the file was named
/// against a workspace root above the project.
typedef ResolvedProject = ({String root, String? testFile});

/// Resolves the Flutter project directory the MCP server operates on.
///
/// A globally-installed server is pointed at a project through one of several
/// signals. They are tried in precedence order — **explicit user config wins
/// over client-automatic signals** — and the first that leads to a
/// `pubspec.yaml` (walking upward) is used:
///
///   1. A `projectRoot` on the request, then `--project-root` and `PROJECT_ROOT` — explicit overrides,
///      needed for clients with weak signals.
///   2. Client `roots` — the workspace root(s) the editor advertises.
///   3. `CLAUDE_PROJECT_DIR` env — set by Claude Code/Desktop for stdio servers.
///   4. The current working directory.
///
/// Within each signal, a test file resolved against it wins over walking up, so
/// an app in a subdirectory is reached from a repository root.
///
/// An explicit root (the request's, `--project-root` or `PROJECT_ROOT`) that
/// leads to no project fails the resolution; the other signals are skipped when
/// they lead to none. A test file whose project is outside the request's
/// `projectRoot` fails it too.
///
/// The result is cached until a caller names a different root, or until a test
/// file turns out not to belong to it.
class ProjectResolver {
  ProjectResolver({
    required this._readRoots,
    String? projectRootOverride,
    Map<String, String>? environment,
    String Function()? currentDirectory,
    FileSystem fileSystem = const LocalFileSystem(),
  }) : _fs = fileSystem,
       _env = environment ?? Platform.environment,
       _currentDirectory =
           currentDirectory ?? (() => fileSystem.currentDirectory.path) {
    // Configured paths are pinned to the directory the server started in.
    // Resolving a project enters it, and a relative path read afterwards would
    // point somewhere else — or nowhere.
    final start = _startDirectory = _currentDirectory();
    String? pin(String? value) => value == null || value.trim().isEmpty
        ? null
        : _path.normalize(_path.join(start, value));
    _projectRootOverride = pin(projectRootOverride);
    _envProjectRoot = pin(_env['PROJECT_ROOT']);
    _envClaudeProjectDir = pin(_env['CLAUDE_PROJECT_DIR']);
  }

  final RootsReader _readRoots;
  final FileSystem _fs;

  /// Paths follow [_fs]'s style, which need not be the host's.
  Context get _path => _fs.path;

  /// From `--project-root`; takes precedence over every other signal.
  late final String? _projectRootOverride;
  late final String? _envProjectRoot;
  late final String? _envClaudeProjectDir;

  /// The working directory the client started the server in.
  late final String _startDirectory;
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
  /// Pass `remember: false` to answer without moving the cache — a caller that
  /// only wants to know where a request points, not to go there.
  Future<ResolvedProject> resolve({
    String? testFile,
    String? requestedRoot,
    bool remember = true,
  }) async {
    // A root resolved without a test file can be a repository root above the
    // package, so a test file that does not sit in it is resolved again.
    if (_cached case final cached?
        when requestedRoot == null &&
            (testFile == null || _ownsTestFile(cached, testFile))) {
      return (root: cached, testFile: _relativeTestFile(cached, testFile));
    }
    final attempts = <String>[];
    final requested = requestedRoot == null
        ? null
        : _path.normalize(_path.join(_startDirectory, requestedRoot));

    // 1. What the caller named for this request, then the server's own flags.
    var hit = _trySignal('projectRoot', requested, testFile, attempts);
    if (requested != null && hit != null && testFile != null) {
      _requireInside(requested, hit, testFile);
    }
    hit ??= _trySignal(
      '--project-root',
      _projectRootOverride,
      testFile,
      attempts,
    );
    hit ??= _trySignal('PROJECT_ROOT', _envProjectRoot, testFile, attempts);
    if (hit == null && attempts.isNotEmpty) {
      throw ProjectResolutionException(attempts);
    }
    // 2. Client-advertised workspace roots (only read if not already resolved).
    hit ??= await _tryRoots(testFile, attempts);
    // 3. Claude sets this for stdio servers.
    hit ??= _trySignal(
      'CLAUDE_PROJECT_DIR',
      _envClaudeProjectDir,
      testFile,
      attempts,
    );
    // 4. Working directory the client launched us in.
    hit ??= _trySignal('cwd', _startDirectory, testFile, attempts);

    if (hit == null) {
      throw ProjectResolutionException(attempts);
    }
    final root = _path.canonicalize(hit);
    if (remember) {
      _cached = root;
    }
    return (
      root: root,
      testFile: _relativeTestFile(
        root,
        testFile,
        searchIn: requested == null ? null : [requested],
      ),
    );
  }

  /// [testFile] as [root] sees it: a caller naming a file against a workspace
  /// root above the project gives a path the project itself cannot open.
  ///
  /// A file not under [root] is looked up in [searchIn], every signal's
  /// directory by default. A requested root is the only place its file may be.
  String? _relativeTestFile(
    String root,
    String? testFile, {
    List<String>? searchIn,
  }) {
    if (testFile == null || testFile.trim().isEmpty) {
      return testFile;
    }
    if (_path.isAbsolute(testFile)) {
      return _path.relative(testFile, from: root);
    }
    if (_exists(_path.join(root, testFile))) {
      return testFile;
    }
    for (final dir in searchIn ?? _signalDirectories()) {
      final candidate = _path.join(dir, testFile);
      if (_exists(candidate)) {
        return _path.relative(_path.canonicalize(candidate), from: root);
      }
    }
    return testFile;
  }

  Iterable<String> _signalDirectories() => [
    ?_projectRootOverride,
    ?_envProjectRoot,
    ?_envClaudeProjectDir,
    ...?_lastRoots,
    _startDirectory,
  ];

  /// Records [dir] as a tried signal and returns the project it leads to, or
  /// `null` if [dir] is empty or leads nowhere.
  ///
  /// [testFile] resolved against [dir] is preferred: a repository root can carry
  /// a workspace `pubspec.yaml`, and the test file sits in the package that owns
  /// it.
  String? _trySignal(
    String label,
    String? dir,
    String? testFile,
    List<String> attempts,
  ) {
    if (dir == null || dir.trim().isEmpty) {
      return null;
    }
    attempts.add('$label=$dir');
    return _fromTestFile(dir, testFile) ?? _findPubspecDir(dir);
  }

  /// Throws when [project], which owns [testFile], is neither the project
  /// [requestedRoot] leads to nor inside [requestedRoot].
  void _requireInside(String requestedRoot, String project, String testFile) {
    final root = _path.canonicalize(requestedRoot);
    final owner = _path.canonicalize(project);
    final rootProject = _findPubspecDir(requestedRoot);
    if (_path.equals(owner, root) ||
        _path.isWithin(root, owner) ||
        (rootProject != null &&
            _path.equals(owner, _path.canonicalize(rootProject)))) {
      return;
    }
    throw ProjectResolutionException.outsideRoot(
      testFile: testFile,
      project: owner,
      requestedRoot: root,
    );
  }

  /// Whether [testFile] belongs to the project at [root] itself.
  bool _ownsTestFile(String root, String testFile) {
    final owner = _fromTestFile(root, testFile);
    return owner != null && _path.equals(_path.canonicalize(owner), root);
  }

  /// The project owning [testFile], a test file or a directory of them, when
  /// it exists under [dir].
  String? _fromTestFile(String dir, String? testFile) {
    if (testFile == null || testFile.trim().isEmpty) {
      return null;
    }
    final candidate = _path.join(dir, testFile);
    if (_fs.directory(candidate).existsSync()) {
      return _findPubspecDir(candidate);
    }
    if (!_fs.file(candidate).existsSync()) {
      return null;
    }
    return _findPubspecDir(_path.dirname(candidate));
  }

  bool _exists(String path) =>
      _fs.file(path).existsSync() || _fs.directory(path).existsSync();

  /// The roots the client last advertised, kept for turning a workspace-relative
  /// test file into one the project can open.
  List<String>? _lastRoots;

  Future<String?> _tryRoots(String? testFile, List<String> attempts) async {
    _lastRoots = await _safeReadRoots();
    for (final root in _lastRoots!) {
      if (_trySignal('root', root, testFile, attempts) case final hit?) {
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

  /// The nearest ancestor of [start] holding a `pubspec.yaml`, or null when
  /// [start] does not exist or nothing above it does.
  String? _findPubspecDir(String start) {
    final dir = _fs.directory(_path.absolute(start));
    if (!dir.existsSync()) {
      return null;
    }
    return findRootDirectory(_fs, start: dir)?.path;
  }
}

/// Thrown when [ProjectResolver] cannot locate a Flutter project from any signal.
class ProjectResolutionException implements Exception {
  ProjectResolutionException(this.attempts) : _message = null;

  /// The request named a `projectRoot` and a test file of another project.
  ProjectResolutionException.outsideRoot({
    required String testFile,
    required String project,
    required String requestedRoot,
  }) : attempts = ['projectRoot=$requestedRoot'],
       _message =
           'Test file $testFile belongs to the project at $project, which is '
           'outside projectRoot $requestedRoot. Name a test file inside '
           'projectRoot, or leave projectRoot out.';

  final String? _message;

  /// The signals that were tried, in order, as `label=value`.
  final List<String> attempts;

  @override
  String toString() {
    if (_message case final message?) {
      return message;
    }
    final tried = attempts.isEmpty
        ? 'nothing (no project signals were available)'
        : attempts.join(', ');
    return 'Could not locate a Flutter project: no pubspec.yaml found from any '
        'signal. Tried, in order: $tried. Pass --project-root with the project '
        'directory, or open it as a workspace root in your editor.';
  }
}
