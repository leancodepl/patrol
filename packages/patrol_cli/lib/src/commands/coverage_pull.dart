import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/coverage/bs_build_check.dart';
import 'package:patrol_cli/src/coverage/bs_coverage_splitter.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

/// Splits the JaCoCo `.ec` coverage of a patrol Android run into the standard
/// JaCoCo blocks and the Dart blocks appended by patrol's
/// `BrowserStackCoverage` runtime, and writes two outputs:
///
///   * `<output>/jacoco.exec` — a valid JaCoCo binary file with only the
///     standard `SessionInfo` + `ExecutionData` blocks. Viewable in Android
///     Studio (`Analyze → Show Coverage Data`).
///   * `<output>/patrol_lcov.info` — the merged LCOV reconstructed from the
///     `PATROL_DART_COV:` session blocks, with duplicate `SF:` records for the
///     same file (common across tests/shards) merged into one.
///
/// The `.ec` files come either from BrowserStack (`--browserstack-build-id`,
/// optionally `--browserstack-session-id`; every session is merged when it is
/// omitted) or from disk
/// (`--input`, a file or a directory searched recursively), e.g. the outputs of
/// emulator.wtf or Firebase Test Lab.
///
/// Refuses BrowserStack builds that ran with `clearPackageData:true`: coverage
/// and `clearPackageData` are mutually exclusive there (see
/// [buildUsedClearPackageData]), and a first-test-only result is worse than an
/// error.
class CoveragePullCommand extends PatrolCommand {
  CoveragePullCommand({required Logger logger, required FileSystem fs})
    : _logger = logger,
      _fs = fs {
    argParser
      ..addOption(
        'input',
        help:
            'A local .ec file, or a directory searched recursively for .ec '
            'files (e.g. emulator.wtf or Firebase Test Lab outputs). Use either '
            'this or --browserstack-build-id.',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Directory to write jacoco.exec and patrol_lcov.info into.',
        defaultsTo: 'coverage',
      )
      ..addOption(
        'browserstack-build-id',
        help:
            'BrowserStack App Automate Espresso build id to download coverage '
            'from. Use either this or --input.',
      )
      ..addOption(
        'browserstack-session-id',
        help:
            'BrowserStack session id within the build. If omitted, every '
            'session (shard) in the build is pulled and merged.',
      )
      ..addOption(
        'browserstack-creds',
        help:
            'BrowserStack basic-auth credentials as USERNAME:ACCESS_KEY. '
            'Falls back to the BROWSERSTACK_CREDS env var.',
      );
  }

  final Logger _logger;
  final FileSystem _fs;

  @override
  String get name => 'pull';

  @override
  String get docsName => 'coverage';

  @override
  String get description =>
      'Split the JaCoCo coverage of a patrol Android run into jacoco.exec '
      'and patrol_lcov.info, downloading it from BrowserStack or reading '
      'local .ec files.';

  static const _apiBase =
      'https://api-cloud.browserstack.com/app-automate/espresso/v2';

  @override
  Future<int> run() async {
    final buildId = stringArg('browserstack-build-id');
    final input = stringArg('input');
    if ((buildId == null) == (input == null)) {
      _logger.err(
        'Pass either --browserstack-build-id (download from BrowserStack) or '
        '--input '
        '(a local .ec file or a directory of them).',
      );
      return 1;
    }

    final sources = input != null
        ? _readLocal(input)
        : await _downloadFromBrowserStack(buildId!);
    if (sources == null) {
      return 1;
    }

    final outputDir = _fs.directory(stringArg('output'))
      ..createSync(recursive: true);
    return _splitAndWrite(sources, outputDir);
  }

  List<_CoverageSource>? _readLocal(String path) {
    if (stringArg('browserstack-session-id') != null) {
      _logger.err(
        '--browserstack-session-id only applies to --browserstack-build-id.',
      );
      return null;
    }

    final List<File> files;
    switch (_fs.typeSync(path)) {
      case FileSystemEntityType.directory:
        files =
            _fs
                .directory(path)
                .listSync(recursive: true)
                .whereType<File>()
                .where((file) => file.path.endsWith('.ec'))
                .toList()
              ..sort((a, b) => a.path.compareTo(b.path));
      case FileSystemEntityType.file:
        files = [_fs.file(path)];
      default:
        _logger.err('--input $path does not exist.');
        return null;
    }
    if (files.isEmpty) {
      _logger.err('No .ec files found under $path.');
      return null;
    }

    _logger.info('Reading ${files.length} coverage file(s) from $path.');
    return [
      for (final file in files)
        (
          label: _fs.path.relative(file.path, from: _fs.path.dirname(path)),
          bytes: file.readAsBytesSync(),
        ),
    ];
  }

  Future<List<_CoverageSource>?> _downloadFromBrowserStack(
    String buildId,
  ) async {
    final sessionId = stringArg('browserstack-session-id');
    final creds =
        stringArg('browserstack-creds') ??
        io.Platform.environment['BROWSERSTACK_CREDS'];
    if (creds == null || creds.isEmpty) {
      _logger.err(
        'Missing BrowserStack credentials. Pass --browserstack-creds or set '
        'BROWSERSTACK_CREDS.',
      );
      return null;
    }
    if (!creds.contains(':')) {
      _logger.err(
        '--browserstack-creds must be in the form USERNAME:ACCESS_KEY.',
      );
      return null;
    }
    final authHeader = 'Basic ${base64Encode(utf8.encode(creds))}';

    final Map<String, dynamic> build;
    try {
      build = await _fetchBuild(buildId, authHeader);
    } on _BsHttpException catch (e) {
      _logger.err(e.message);
      return null;
    }

    if (buildUsedClearPackageData(build) ?? false) {
      _logger.err(
        'Build $buildId ran with clearPackageData:true, which is incompatible '
        'with coverage on BrowserStack: pm clear between tests revokes the '
        "app's permission to write the coverage file, so only the first test's "
        'coverage would be reported. Re-run the coverage build with '
        'clearPackageData:false (keep it true for regular runs).',
      );
      return null;
    }

    // Without --session-id, pull and merge every session (shard) in the build.
    final List<String> sessionIds;
    if (sessionId != null) {
      sessionIds = [sessionId];
    } else {
      sessionIds = _sessionIdsFrom(build);
      if (sessionIds.isEmpty) {
        _logger.err('No sessions found in build $buildId.');
        return null;
      }
      _logger.info(
        'Merging coverage from ${sessionIds.length} session(s) in build $buildId.',
      );
    }

    final sources = <_CoverageSource>[];
    for (final sid in sessionIds) {
      final Uint8List bytes;
      try {
        bytes = await _fetchCoverage(buildId, sid, authHeader);
      } on _BsHttpException catch (e) {
        _logger.err(e.message);
        return null;
      }
      _logger.info('Session $sid: downloaded ${bytes.length} bytes');
      sources.add((label: 'Session $sid', bytes: bytes));
    }
    return sources;
  }

  int _splitAndWrite(List<_CoverageSource> sources, Directory outputDir) {
    final mergedJacoco = BytesBuilder();
    final mergedLcov = StringBuffer();
    var jacocoSessions = 0;
    var execBlocks = 0;
    var dartChunks = 0;

    for (final source in sources) {
      final BsCoverageSplitResult split;
      try {
        split = splitJacocoExec(source.bytes);
      } on FormatException catch (e) {
        _logger.err('${source.label}: failed to parse coverage: ${e.message}');
        return 1;
      }
      mergedJacoco.add(split.jacocoBytes);
      mergedLcov.write(split.dartLcov);
      jacocoSessions += split.jacocoSessions;
      execBlocks += split.executionDataBlocks;
      dartChunks += split.dartChunks;
    }

    _logger.info(
      'Parsed: $jacocoSessions JaCoCo session(s), $execBlocks class probe(s), '
      '$dartChunks Dart chunk(s) from ${sources.length} coverage file(s).',
    );
    if (dartChunks == 0) {
      _logger.warn(
        'No Dart coverage found. Was the app built with '
        '--dart-define=PATROL_BS_COVERAGE=true, and the instrumentation run '
        'with coverage=true?',
      );
    }

    final jacocoBytes = mergedJacoco.toBytes();
    final jacocoFile = outputDir.childFile('jacoco.exec')
      ..writeAsBytesSync(jacocoBytes);
    _logger.success('Wrote ${jacocoFile.path} (${jacocoBytes.length} B)');

    final lcovFile = outputDir.childFile('patrol_lcov.info')
      ..writeAsStringSync(mergeLcovRecords(mergedLcov.toString()));
    _logger.success('Wrote ${lcovFile.path}');

    return 0;
  }

  Future<Map<String, dynamic>> _fetchBuild(String buildId, String auth) async {
    final url = Uri.parse('$_apiBase/builds/$buildId');
    _logger.info('Fetching $url');
    final res = await http.get(url, headers: {'Authorization': auth});
    if (res.statusCode != 200) {
      throw _BsHttpException(
        'BrowserStack returned ${res.statusCode} for build $buildId: '
        '${res.body.substring(0, res.body.length.clamp(0, 500))}',
      );
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw _BsHttpException(
        'BrowserStack returned an unexpected body for build $buildId.',
      );
    }
    return decoded;
  }

  /// Session (shard) ids nest under `devices[].sessions[].id`.
  static List<String> _sessionIdsFrom(Map<String, dynamic> build) {
    final ids = <String>[];
    final devices = build['devices'];
    if (devices is List) {
      for (final device in devices) {
        final sessions = (device as Map<String, dynamic>)['sessions'];
        if (sessions is List) {
          for (final session in sessions) {
            final id = (session as Map<String, dynamic>)['id'];
            if (id is String) {
              ids.add(id);
            }
          }
        }
      }
    }
    return ids;
  }

  Future<Uint8List> _fetchCoverage(
    String buildId,
    String sessionId,
    String auth,
  ) async {
    final url = Uri.parse(
      '$_apiBase/builds/$buildId/sessions/$sessionId/coverage',
    );
    _logger.info('Fetching $url');
    final res = await http.get(url, headers: {'Authorization': auth});
    if (res.statusCode != 200) {
      throw _BsHttpException(
        'BrowserStack returned ${res.statusCode} for session $sessionId: '
        '${res.body.substring(0, res.body.length.clamp(0, 500))}',
      );
    }
    return res.bodyBytes;
  }
}

class _BsHttpException implements Exception {
  _BsHttpException(this.message);

  final String message;
}

typedef _CoverageSource = ({String label, Uint8List bytes});
