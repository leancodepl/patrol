import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:vm_service/vm_service.dart' as vms;
import 'package:vm_service/vm_service_io.dart' as vms;

/// Collects Dart line coverage from inside the running app and writes one
/// cumulative LCOV file per app process into a directory the patrol native
/// runner picks up after every test (it appends it to JaCoCo's `coverage.ec` so
/// BrowserStack's coverage endpoint returns a merged report).
///
/// The VM service reports coverage cumulatively per isolate, so each snapshot
/// is a superset of the previous one. We overwrite one file per process rather
/// than emitting one file per test: keeping every per-test snapshot would
/// duplicate earlier coverage in every later record and grow the appended
/// payload roughly quadratically, risking BrowserStack's coverage size limit on
/// large suites. A restarted process (test orchestrator on, or the app
/// relaunching mid-suite) starts a fresh isolate, so it gets its own file.
///
/// Activated by `--dart-define=PATROL_BS_COVERAGE=true`. Optional
/// `--dart-define=PATROL_BS_COVERAGE_PACKAGES=foo,bar` restricts collection
/// to a comma-separated set of package regexps (matched against the package
/// name from `package_config.json`). Defaults to including everything except
/// `dart:`/`package:flutter/`/`package:flutter_test/`/`package:patrol`.
class BrowserStackCoverage {
  BrowserStackCoverage._();

  /// Whether the BS coverage hook is enabled. Wired via `--dart-define`.
  static const enabled = bool.fromEnvironment('PATROL_BS_COVERAGE');

  static const _packagesEnv = String.fromEnvironment(
    'PATROL_BS_COVERAGE_PACKAGES',
  );

  /// Whether to force-compile not-yet-compiled functions when collecting
  /// coverage. `true` reports every line (including never-executed ones) but is
  /// far slower on large apps; `false` (the default) reports only what the VM
  /// has already compiled, which is the right, cheaper choice for "what did the
  /// suite exercise". Wired via `--dart-define=PATROL_BS_COVERAGE_FORCE_COMPILE`.
  static const _forceCompile = bool.fromEnvironment(
    'PATROL_BS_COVERAGE_FORCE_COMPILE',
  );

  /// Package-name regexps from [_packagesEnv], compiled once (this is consulted
  /// for every source range in every report).
  static final List<RegExp> _packagePatterns = _packagesEnv
      .split(',')
      .where((s) => s.isNotEmpty)
      .map(RegExp.new)
      .toList();

  /// Matches any character that makes a pattern a real regexp rather than a
  /// plain literal.
  static final _regexpMeta = RegExp(r'[\\$.|?*+()\[\]{}]');

  /// Library URI prefixes handed to the VM's own `libraryFilters`, so that
  /// force-compilation and report generation never touch the Flutter framework
  /// or the SDK in the first place. Only plain anchored prefixes such as
  /// `^package:my_app/` can be pushed down; if any pattern uses real regexp
  /// syntax we send nothing and fall back to filtering after the fact, because
  /// a partial filter set would silently drop the other patterns' coverage.
  static final List<String> _libraryFilters = _deriveLibraryFilters();

  static List<String> _deriveLibraryFilters() {
    final patterns = _packagesEnv.split(',').where((s) => s.isNotEmpty);
    final filters = <String>[];
    for (final pattern in patterns) {
      if (!pattern.startsWith('^')) {
        return const [];
      }
      final literal = pattern.substring(1);
      if (literal.isEmpty || _regexpMeta.hasMatch(literal)) {
        return const [];
      }
      filters.add(literal);
    }
    return filters;
  }

  /// Libraries already force-compiled in this process, per isolate. Passing
  /// them back to the VM is what keeps repeat collections cheap: the first call
  /// in a process pays the compile, the rest skip it. Without this every test
  /// re-pays it, which is what made `forceCompile` unaffordable on large apps.
  static final Map<String, Set<String>> _compiledLibraries = {};

  /// Names this process's file so a restarted process can't overwrite the
  /// previous one's snapshot. `pid` alone could be reused within a session.
  static final _runId = '${DateTime.now().millisecondsSinceEpoch}_$pid';

  static var _forceCompileWarned = false;
  static String? _cachedDir;
  static vms.VmService? _service;
  static Future<vms.VmService>? _serviceFuture;

  /// Connects (or returns the cached connection) to this app's VM service. The
  /// service URL is exposed by the SDK; tests always run in debug-mode binaries
  /// so it's available.
  static Future<vms.VmService> _connect() {
    return _serviceFuture ??= () async {
      final info = await Service.getInfo();
      var uri = info.serverUri;
      if (uri == null) {
        throw StateError(
          'VM service URI unavailable. Patrol BS coverage requires the app to '
          'be built in debug mode (which patrol does by default).',
        );
      }
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        uri = uri.replace(
          scheme: uri.scheme == 'https' ? 'wss' : 'ws',
          path: '${uri.path.endsWith('/') ? uri.path : '${uri.path}/'}ws',
        );
      }
      _service = await vms.vmServiceConnectUri(uri.toString());
      return _service!;
    }();
  }

  /// Records that the named test finished by capturing a coverage snapshot
  /// from every running isolate and writing it as LCOV, overwriting the single
  /// cumulative file from earlier tests. Safe to call when [enabled] is false
  /// (no-op). Errors are swallowed and logged.
  static Future<void> recordTestCompleted({
    required String testName,
    required String testFilePath,
    required bool passed,
  }) async {
    if (!enabled) {
      return;
    }
    if (!Platform.isAndroid) {
      return;
    }

    _warnAboutForceCompileOnce();

    try {
      final outDir = await _resolveOutputDir();
      if (outDir == null) {
        return;
      }

      final service = await _connect();
      final vm = await service.getVM();
      final hitMap = <String, Map<int, int>>{};

      for (final isolateRef in vm.isolates ?? const <vms.IsolateRef>[]) {
        final id = isolateRef.id;
        if (id == null) {
          continue;
        }
        try {
          final alreadyCompiled = _compiledLibraries[id];
          final report = await service.getSourceReport(
            id,
            const ['Coverage'],
            forceCompile: _forceCompile,
            reportLines: true,
            libraryFilters: _libraryFilters.isEmpty ? null : _libraryFilters,
            librariesAlreadyCompiled:
                _forceCompile &&
                    alreadyCompiled != null &&
                    alreadyCompiled.isNotEmpty
                ? alreadyCompiled.toList()
                : null,
          );
          _mergeReport(report, hitMap);
          if (_forceCompile) {
            // Recomputed every time rather than cached once, so libraries
            // loaded later (deferred imports) still get compiled once.
            _compiledLibraries[id] = await _collectedLibrariesOf(service, id);
          }
        } catch (_) {
          // Isolate may have gone away mid-collection; ignore.
        }
      }

      if (hitMap.isEmpty) {
        return;
      }

      final lcov = _formatLcov(testName: testName, hitMap: hitMap);
      // One file per process, overwritten each test: VM coverage accumulates
      // per isolate, so the latest snapshot already contains every prior test
      // run in this process.
      final file = File('$outDir/coverage_$_runId.lcov');
      await file.writeAsString(lcov, flush: true);
      // ignore: avoid_print -- coverage diagnostics go through stdout/logcat.
      print(
        'BrowserStackCoverage: wrote ${file.path} '
        '(${hitMap.length} files, passed=$passed)',
      );
    } catch (err, st) {
      // ignore: avoid_print -- coverage failure must not fail the test.
      print('BrowserStackCoverage: failed to record $testName: $err\n$st');
    }
  }

  /// `forceCompile: true` recompiles every function in scope on each call. In
  /// a fresh process that is the whole package graph, so under the Android test
  /// orchestrator - one process per test - nothing is ever reused and the cost
  /// is paid in full for every test. Measured at ~90s/test on a 2.7k-file app,
  /// which overruns BrowserStack's session cap well before a large suite ends.
  /// Warn once so the run's logs say why it is slow.
  static void _warnAboutForceCompileOnce() {
    if (!_forceCompile || _forceCompileWarned) {
      return;
    }
    _forceCompileWarned = true;
    // ignore: avoid_print -- coverage diagnostics go through stdout/logcat.
    print(
      'BrowserStackCoverage: PATROL_BS_COVERAGE_FORCE_COMPILE=true recompiles '
      'the whole package graph on every collection. Under the Android test '
      'orchestrator each test is a fresh process, so this cost is paid per '
      'test and large suites will hit the device-farm session limit. Prefer '
      'useOrchestrator:false for force-compile runs, and narrow the scope with '
      'PATROL_BS_COVERAGE_PACKAGES.',
    );
  }

  /// The in-scope libraries currently loaded in [isolateId] — i.e. the ones a
  /// `forceCompile` pass has just compiled.
  static Future<Set<String>> _collectedLibrariesOf(
    vms.VmService service,
    String isolateId,
  ) async {
    final isolate = await service.getIsolate(isolateId);
    final libraries = isolate.libraries ?? const <vms.LibraryRef>[];
    return {
      for (final library in libraries)
        if (library.uri case final uri?)
          if (_shouldInclude(uri)) uri,
    };
  }

  static void _mergeReport(
    vms.SourceReport report,
    Map<String, Map<int, int>> hitMap,
  ) {
    final scripts = report.scripts ?? const <vms.ScriptRef>[];
    for (final range in report.ranges ?? const <vms.SourceReportRange>[]) {
      final coverage = range.coverage;
      if (coverage == null) {
        continue;
      }
      final scriptIndex = range.scriptIndex;
      if (scriptIndex == null) {
        continue;
      }
      if (scriptIndex < 0 || scriptIndex >= scripts.length) {
        continue;
      }
      final uriStr = scripts[scriptIndex].uri;
      if (uriStr == null) {
        continue;
      }
      if (!_shouldInclude(uriStr)) {
        continue;
      }

      final perFile = hitMap.putIfAbsent(uriStr, () => <int, int>{});
      for (final hit in coverage.hits ?? const <int>[]) {
        perFile[hit] = (perFile[hit] ?? 0) + 1;
      }
      for (final miss in coverage.misses ?? const <int>[]) {
        perFile.putIfAbsent(miss, () => 0);
      }
    }
  }

  static bool _shouldInclude(String uri) {
    if (_packagePatterns.isNotEmpty) {
      return _packagePatterns.any((p) => p.hasMatch(uri));
    }
    // Default: skip SDK/flutter framework noise.
    if (uri.startsWith('dart:')) {
      return false;
    }
    if (uri.startsWith('package:flutter/')) {
      return false;
    }
    if (uri.startsWith('package:flutter_test/')) {
      return false;
    }
    if (uri.startsWith('package:patrol/')) {
      return false;
    }
    if (uri.startsWith('package:patrol_finders/')) {
      return false;
    }
    return true;
  }

  static String _formatLcov({
    required String testName,
    required Map<String, Map<int, int>> hitMap,
  }) {
    final buf = StringBuffer();
    final sortedFiles = hitMap.keys.toList()..sort();
    for (final file in sortedFiles) {
      final lines = hitMap[file]!;
      final sortedLines = lines.keys.toList()..sort();
      buf
        ..writeln('TN:$testName')
        ..writeln('SF:$file');
      var hit = 0;
      for (final line in sortedLines) {
        final count = lines[line]!;
        buf.writeln('DA:$line,$count');
        if (count > 0) {
          hit++;
        }
      }
      buf
        ..writeln('LF:${sortedLines.length}')
        ..writeln('LH:$hit')
        ..writeln('end_of_record');
    }
    return buf.toString();
  }

  static Future<String?> _resolveOutputDir() async {
    if (_cachedDir != null) {
      return _cachedDir;
    }
    try {
      // path_provider is auto-registered in any host app that depends on it
      // directly (or transitively via flutter plugins); on Android it returns
      // `Context.filesDir`, which is the same path the patrol native test
      // runner reads from at instrumentation shutdown.
      final dir = await getApplicationSupportDirectory();
      final coverageDir = Directory('${dir.path}/patrol_coverage');
      if (!coverageDir.existsSync()) {
        coverageDir.createSync(recursive: true);
      }
      _cachedDir = coverageDir.path;
      return _cachedDir;
    } catch (err) {
      // ignore: avoid_print -- coverage diagnostics must not fail the test.
      print(
        'BrowserStackCoverage: getApplicationSupportDirectory failed: $err',
      );
      return null;
    }
  }
}
