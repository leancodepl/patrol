import 'dart:convert';

import 'package:coverage/coverage.dart' as coverage;
import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/coverage/coverage_common.dart';

/// Generates a Dart coverage report for web test runs.
///
/// The browser has no Dart VM, so instead of a VM service the Playwright runner
/// records Chrome's JS coverage per test (with source maps) into
/// [dataDirectory]. This tool maps it back to Dart and writes the same
/// `coverage/patrol_lcov.info` report as the mobile flow.
class WebCoverageTool {
  WebCoverageTool({
    required FileSystem fs,
    required Directory rootDirectory,
    required Logger logger,
  }) : _fs = fs,
       _rootDirectory = rootDirectory,
       _logger = logger;

  final FileSystem _fs;
  final Directory _rootDirectory;
  final Logger _logger;

  /// Where the Playwright runner drops one JSON file per test with the raw V8
  /// coverage entries.
  Directory get dataDirectory => _rootDirectory
      .childDirectory('.dart_tool')
      .childDirectory('patrol')
      .childDirectory('web_coverage');

  /// Clears data from previous runs and returns the directory to write to.
  Future<Directory> prepareDataDirectory() async {
    final dir = dataDirectory;
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
    await dir.create(recursive: true);
    return dir;
  }

  Future<void> run({
    required String flutterPackageName,
    required Set<RegExp> packagesRegExps,
    required Set<Glob> ignoreGlobs,
    bool includeWorkspacePackages = false,
  }) async {
    final dir = dataDirectory;
    final files = dir.existsSync()
        ? dir
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.json'))
              .toList()
        : <File>[];

    if (files.isEmpty) {
      _logger.warn(
        'No web coverage data was collected, skipping coverage report. '
        'Make sure the tests are running on Chromium.',
      );
      return;
    }

    // Parse concurrently, recovering each future to null so one bad file
    // doesn't reject the whole batch. Package resolution runs alongside the
    // parse and is awaited directly so its `ToolExit` propagates unwrapped.
    final testHitMapsFuture = Future.wait(
      files.map(
        (file) => _parseTestCoverage(file, flutterPackageName).catchError((
          Object err,
        ) {
          _logger.warn('Skipping unreadable coverage file ${file.path}: $err');
          return null;
        }),
      ),
    );

    final packages = await getCoveragePackages(
      rootDirectory: _rootDirectory,
      packagesRegExps: packagesRegExps,
      includeWorkspacePackages: includeWorkspacePackages,
      logger: _logger,
    );
    final testHitMaps = await testHitMapsFuture;

    // Merge sequentially since `HitMap.merge` mutates the accumulator.
    final parsed = testHitMaps
        .whereType<Map<String, coverage.HitMap>>()
        .toList();
    final hitMap = <String, coverage.HitMap>{};
    for (final testHitMap in parsed) {
      hitMap.merge(_scopedTo(testHitMap, packages));
    }
    _logger.info('Converted ${parsed.length} / ${files.length} web coverages');

    if (hitMap.isEmpty) {
      _logger.warn(
        'Web coverage data did not map back to any Dart sources, '
        'skipping coverage report.',
      );
      return;
    }

    await formatAndSaveLcovReport(
      fs: _fs,
      hitMap: hitMap,
      packagePath: _rootDirectory.path,
      ignoreGlobs: ignoreGlobs,
      logger: _logger,
    );
  }

  /// Converts one test's V8 coverage into a Dart hit map, or null if the file
  /// is unusable.
  Future<Map<String, coverage.HitMap>?> _parseTestCoverage(
    File file,
    String flutterPackageName,
  ) async {
    final entries = await _readCoverageEntries(file);
    if (entries == null) {
      return null;
    }
    final byId = {for (final e in entries) e['scriptId'] as String: e};

    // Source, source map and URL are supplied via these lookups by scriptId.
    final parsed = await coverage.parseChromeCoverage(
      entries,
      (id) async => byId[id]?['source'] as String?,
      (id) async => byId[id]?['sourceMap'] as String?,
      (sourceUrl, id) async => resolveDartSourceUri(
        sourceUrl: sourceUrl,
        scriptUrl: byId[id]?['url'] as String?,
        appPackageName: flutterPackageName,
      ),
    );

    return coverage.HitMap.parseJson(
      (parsed['coverage'] as List).cast<Map<String, dynamic>>(),
    );
  }

  /// Returns the entries `parseChromeCoverage` can consume, or null if the file
  /// is malformed. Written by a separate process, so a bad file is skipped
  /// rather than fatal; only entries with a String `scriptId` are kept.
  Future<List<Map<String, dynamic>>?> _readCoverageEntries(File file) async {
    final Object? json;
    try {
      json = jsonDecode(await file.readAsString());
    } on FormatException catch (err) {
      _logger.warn('Skipping malformed coverage file ${file.path}: $err');
      return null;
    }
    if (json is! Map<String, dynamic> || json['entries'] is! List) {
      _logger.warn('Skipping malformed coverage file ${file.path}');
      return null;
    }
    return (json['entries'] as List)
        .whereType<Map<String, dynamic>>()
        .where((e) => e['scriptId'] is String)
        .toList();
  }

  /// Mirrors the VM collector: an empty [packages] set means no filtering.
  Map<String, coverage.HitMap> _scopedTo(
    Map<String, coverage.HitMap> hitMap,
    Set<String> packages,
  ) {
    if (packages.isEmpty) {
      return hitMap;
    }
    return {
      for (final entry in hitMap.entries)
        if (packages.contains(_packageNameOf(entry.key)))
          entry.key: entry.value,
    };
  }
}

String? _packageNameOf(String source) {
  final uri = Uri.tryParse(source);
  if (uri == null || uri.scheme != 'package' || uri.pathSegments.isEmpty) {
    return null;
  }
  return uri.pathSegments.first;
}

/// Maps a source map `sources` entry to a Dart URI the `package:coverage`
/// Resolver understands, or null for unattributable sources (which are then
/// excluded from the report). Handles the shapes the compilers emit:
/// - `package:` and `file:` URIs are already usable;
/// - DDC's `org-dartlang-app:///` for app-root sources;
/// - otherwise the source is relative to the script's URL, where the dev
///   server exposes dependencies under `/packages/<name>/`.
///
/// SDK sources (`org-dartlang-sdk:`) are already filtered by
/// `parseChromeCoverage`.
Uri? resolveDartSourceUri({
  required String sourceUrl,
  required String? scriptUrl,
  required String appPackageName,
}) {
  final uri = Uri.tryParse(sourceUrl);
  if (uri != null && uri.hasScheme) {
    return switch (uri.scheme) {
      'package' || 'file' => uri,
      'org-dartlang-app' => _packageUriFromPath(
        uri.pathSegments,
        appPackageName,
      ),
      _ => null,
    };
  }

  if (scriptUrl == null) {
    return null;
  }
  final script = Uri.tryParse(scriptUrl);
  if (script == null) {
    return null;
  }
  final Uri resolved;
  try {
    resolved = script.resolve(sourceUrl);
  } on FormatException {
    return null;
  }
  return _packageUriFromPath(resolved.pathSegments, appPackageName);
}

/// Attributes a server/app-root path to a package: `packages/<name>/<path>`
/// is a dependency, while a top-level `lib/` belongs to the app package.
Uri? _packageUriFromPath(List<String> pathSegments, String appPackageName) {
  final segments = pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) {
    return null;
  }

  if (segments.indexOf('packages') case final i
      when i != -1 && i + 1 < segments.length) {
    return Uri(scheme: 'package', pathSegments: segments.sublist(i + 1));
  }

  if (segments case ['lib', final first, ...final rest]) {
    return Uri(
      scheme: 'package',
      pathSegments: [appPackageName, first, ...rest],
    );
  }

  return null;
}
