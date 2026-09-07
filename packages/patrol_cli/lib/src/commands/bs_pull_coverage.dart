import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/coverage/bs_coverage_splitter.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

/// Downloads the JaCoCo `.ec` file produced by an Espresso BrowserStack run,
/// splits the JaCoCo standard blocks from the Dart blocks appended by patrol's
/// `BrowserStackCoverage` runtime, and writes two outputs:
///
///   * `<output>/jacoco.exec` — a valid JaCoCo binary file with only the
///     standard `SessionInfo` + `ExecutionData` blocks. Viewable in Android
///     Studio (`Analyze → Show Coverage Data`).
///   * `<output>/patrol_lcov.info` — the merged LCOV reconstructed from the
///     `PATROL_DART_COV:` session blocks, with duplicate `SF:` records for the
///     same file (common across tests/shards) merged into one.
///
/// Pass `--session-id` for a single session, or omit it to pull every session
/// (shard) in the build and merge them into one `jacoco.exec` + one
/// `patrol_lcov.info`.
class BsPullCoverageCommand extends PatrolCommand {
  BsPullCoverageCommand({required Logger logger, required FileSystem fs})
    : _logger = logger,
      _fs = fs {
    argParser
      ..addOption(
        'build-id',
        help: 'BrowserStack App Automate Espresso build id.',
        mandatory: true,
      )
      ..addOption(
        'session-id',
        help:
            'BrowserStack session id within the build. If omitted, every '
            'session (shard) in the build is pulled and merged.',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Directory to write jacoco.exec and patrol_lcov.info into.',
        defaultsTo: 'coverage',
      )
      ..addOption(
        'creds',
        help:
            'BrowserStack basic-auth credentials as USERNAME:ACCESS_KEY. '
            'Falls back to the BROWSERSTACK_CREDS env var.',
      );
  }

  final Logger _logger;
  final FileSystem _fs;

  @override
  String get name => 'pull-coverage';

  @override
  String get description =>
      'Download and split a BrowserStack JaCoCo coverage file produced by a patrol Espresso run.';

  static const _apiBase =
      'https://api-cloud.browserstack.com/app-automate/espresso/v2';

  @override
  Future<int> run() async {
    final buildId = stringArg('build-id')!;
    final sessionId = stringArg('session-id');
    final outputDir = _fs.directory(stringArg('output'));
    final creds =
        stringArg('creds') ?? io.Platform.environment['BROWSERSTACK_CREDS'];
    if (creds == null || creds.isEmpty) {
      _logger.err(
        'Missing BrowserStack credentials. Pass --creds or set BROWSERSTACK_CREDS.',
      );
      return 1;
    }
    if (!creds.contains(':')) {
      _logger.err('--creds must be in the form USERNAME:ACCESS_KEY.');
      return 1;
    }
    final authHeader = 'Basic ${base64Encode(utf8.encode(creds))}';

    outputDir.createSync(recursive: true);

    // Without --session-id, pull and merge every session (shard) in the build.
    final List<String> sessionIds;
    if (sessionId != null) {
      sessionIds = [sessionId];
    } else {
      try {
        sessionIds = await _listSessionIds(buildId, authHeader);
      } on _BsHttpException catch (e) {
        _logger.err(e.message);
        return 1;
      }
      if (sessionIds.isEmpty) {
        _logger.err('No sessions found in build $buildId.');
        return 1;
      }
      _logger.info(
        'Merging coverage from ${sessionIds.length} session(s) in build $buildId.',
      );
    }

    final mergedJacoco = BytesBuilder();
    final mergedLcov = StringBuffer();
    var jacocoSessions = 0;
    var execBlocks = 0;
    var dartChunks = 0;

    for (final sid in sessionIds) {
      final Uint8List bytes;
      try {
        bytes = await _fetchCoverage(buildId, sid, authHeader);
      } on _BsHttpException catch (e) {
        _logger.err(e.message);
        return 1;
      }
      _logger.info('Session $sid: downloaded ${bytes.length} bytes');

      final BsCoverageSplitResult split;
      try {
        split = splitJacocoExec(bytes);
      } on FormatException catch (e) {
        _logger.err('Session $sid: failed to parse coverage: ${e.message}');
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
      '$dartChunks Dart chunk(s) across ${sessionIds.length} session(s).',
    );

    final jacocoBytes = mergedJacoco.toBytes();
    final jacocoFile = outputDir.childFile('jacoco.exec')
      ..writeAsBytesSync(jacocoBytes);
    _logger.success('Wrote ${jacocoFile.path} (${jacocoBytes.length} B)');

    final lcovFile = outputDir.childFile('patrol_lcov.info')
      ..writeAsStringSync(mergeLcovRecords(mergedLcov.toString()));
    _logger.success('Wrote ${lcovFile.path}');

    return 0;
  }

  /// Enumerates every session (shard) id in [buildId] via the build endpoint,
  /// which nests them under `devices[].sessions[].id`.
  Future<List<String>> _listSessionIds(String buildId, String auth) async {
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
    final ids = <String>[];
    if (decoded is Map<String, dynamic>) {
      final devices = decoded['devices'];
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
