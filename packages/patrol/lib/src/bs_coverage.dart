import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:vm_service/vm_service.dart' as vms;
import 'package:vm_service/vm_service_io.dart' as vms;

/// Collects Dart line coverage from inside the running app and writes per-test
/// LCOV files into a directory the patrol native runner picks up at
/// instrumentation shutdown (it appends them to JaCoCo's `coverage.ec` so
/// BrowserStack's coverage endpoint returns a merged report).
///
/// Activated by `--dart-define=PATROL_BS_COVERAGE=true`. Optional
/// `--dart-define=PATROL_BS_COVERAGE_PACKAGES=foo,bar` restricts collection
/// to a comma-separated set of package regexps (matched against the package
/// name from `package_config.json`). Defaults to including everything except
/// `dart:`/`package:flutter/`/`package:flutter_test/`/`package:patrol`.
class BrowserStackCoverage {
  BrowserStackCoverage._();

  /// Whether the BS coverage hook is enabled. Wired via `--dart-define`.
  static const bool enabled = bool.fromEnvironment('PATROL_BS_COVERAGE');

  static const String _packagesEnv = String.fromEnvironment(
    'PATROL_BS_COVERAGE_PACKAGES',
  );

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
  /// from every running isolate and writing it as LCOV. Safe to call when
  /// [enabled] is false (no-op). Errors are swallowed and logged.
  static Future<void> recordTestCompleted({
    required String testName,
    required String testFilePath,
    required bool passed,
  }) async {
    if (!enabled) return;
    if (!Platform.isAndroid) return;

    try {
      final outDir = await _resolveOutputDir();
      if (outDir == null) return;

      final service = await _connect();
      final vm = await service.getVM();
      final hitMap = <String, Map<int, int>>{};

      for (final isolateRef in vm.isolates ?? const <vms.IsolateRef>[]) {
        final id = isolateRef.id;
        if (id == null) continue;
        try {
          final report = await service.getSourceReport(
            id,
            const ['Coverage'],
            forceCompile: true,
            reportLines: true,
          );
          _mergeReport(report, hitMap);
        } catch (_) {
          // Isolate may have gone away mid-collection; ignore.
        }
      }

      if (hitMap.isEmpty) return;

      final lcov = _formatLcov(testName: testName, hitMap: hitMap);
      final safeName = testName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final file = File('$outDir/$safeName.lcov');
      await file.writeAsString(lcov, flush: true);
      // ignore: avoid_print -- coverage diagnostics go through stdout/logcat.
      print(
        'BrowserStackCoverage: wrote ${file.path} '
        '(${hitMap.length} files, passed=$passed)',
      );
    } catch (e, st) {
      // ignore: avoid_print -- coverage failure must not fail the test.
      print('BrowserStackCoverage: failed to record $testName: $e\n$st');
    }
  }

  static void _mergeReport(
    vms.SourceReport report,
    Map<String, Map<int, int>> hitMap,
  ) {
    final scripts = report.scripts ?? const <vms.ScriptRef>[];
    for (final range in report.ranges ?? const <vms.SourceReportRange>[]) {
      final coverage = range.coverage;
      if (coverage == null) continue;
      final scriptIndex = range.scriptIndex;
      if (scriptIndex == null) continue;
      if (scriptIndex < 0 || scriptIndex >= scripts.length) continue;
      final uriStr = scripts[scriptIndex].uri;
      if (uriStr == null) continue;
      if (!_shouldInclude(uriStr)) continue;

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
    if (_packagesEnv.isNotEmpty) {
      final patterns = _packagesEnv
          .split(',')
          .where((s) => s.isNotEmpty)
          .map(RegExp.new)
          .toList();
      return patterns.any((p) => p.hasMatch(uri));
    }
    // Default: skip SDK/flutter framework noise.
    if (uri.startsWith('dart:')) return false;
    if (uri.startsWith('package:flutter/')) return false;
    if (uri.startsWith('package:flutter_test/')) return false;
    if (uri.startsWith('package:patrol/')) return false;
    if (uri.startsWith('package:patrol_finders/')) return false;
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
        if (count > 0) hit++;
      }
      buf
        ..writeln('LF:${sortedLines.length}')
        ..writeln('LH:$hit')
        ..writeln('end_of_record');
    }
    return buf.toString();
  }

  static Future<String?> _resolveOutputDir() async {
    if (_cachedDir != null) return _cachedDir;
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
    } catch (e) {
      // ignore: avoid_print -- coverage diagnostics must not fail the test.
      print('BrowserStackCoverage: getApplicationSupportDirectory failed: $e');
      return null;
    }
  }
}
