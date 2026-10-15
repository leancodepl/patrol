import 'dart:convert';

import 'package:coverage/coverage.dart' as coverage;
import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/coverage/coverage_common.dart';

/// Generates a Dart coverage report for web test runs.
///
/// The browser has no Dart VM, so the Playwright runner records Chrome's JS
/// coverage per test into [dataDirectory] instead. This tool maps it back to
/// Dart via source maps and writes the same report as the mobile flow.
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

  Directory get dataDirectory => _rootDirectory
      .childDirectory('.dart_tool')
      .childDirectory('patrol')
      .childDirectory('web_coverage');

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
    bool perTest = false,
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

    // Recover each future to null so one bad file doesn't reject the batch.
    // Package resolution runs alongside and is awaited directly, so its
    // `ToolExit` propagates unwrapped.
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

    final parsed = testHitMaps.nonNulls.toList();
    _logger.info('Converted ${parsed.length} / ${files.length} web coverages');

    final report = await LcovReport.create(
      packagePath: _rootDirectory.path,
      ignoreGlobs: ignoreGlobs,
      perTest: perTest,
    );
    for (final test in parsed) {
      report.add((name: test.name, hitMap: _scopedTo(test.hitMap, packages)));
    }
    if (report.isEmpty) {
      _logger.warn(
        'Web coverage data did not map back to any Dart sources, '
        'skipping coverage report.',
      );
      return;
    }

    await report.save(fs: _fs, logger: _logger);
  }

  Future<TestCoverage?> _parseTestCoverage(
    File file,
    String flutterPackageName,
  ) async {
    final coverageFile = await _readCoverageFile(file);
    if (coverageFile == null) {
      return null;
    }
    final (:testName, :entries) = coverageFile;
    final byId = {for (final e in entries) e['scriptId'] as String: e};

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

    return (
      name: testName,
      hitMap: await coverage.HitMap.parseJson(
        (parsed['coverage'] as List).cast<Map<String, dynamic>>(),
      ),
    );
  }

  /// The files come from a separate process, so a malformed one is skipped
  /// rather than fatal.
  Future<({String? testName, List<Map<String, dynamic>> entries})?>
  _readCoverageFile(File file) async {
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
    return (
      testName: json['testName'] as String?,
      entries: (json['entries'] as List)
          .whereType<Map<String, dynamic>>()
          .where((e) => e['scriptId'] is String)
          .toList(),
    );
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
/// Resolver understands. Unattributable sources return null and are excluded
/// from the report; SDK sources are already filtered by `parseChromeCoverage`.
///
/// Relative sources are resolved against the script's URL, where the dev server
/// exposes dependencies under `/packages/<name>/`.
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
///
/// Both prefixes are only recognized at the root, so an app source living under
/// e.g. `lib/packages/widgets/button.dart` stays with the app package instead
/// of being attributed to a `widgets` dependency.
Uri? _packageUriFromPath(List<String> pathSegments, String appPackageName) {
  final segments = pathSegments.where((s) => s.isNotEmpty).toList();

  return switch (segments) {
    ['packages', final package, final first, ...final rest] => Uri(
      scheme: 'package',
      pathSegments: [package, first, ...rest],
    ),
    ['lib', final first, ...final rest] => Uri(
      scheme: 'package',
      pathSegments: [appPackageName, first, ...rest],
    ),
    _ => null,
  };
}
