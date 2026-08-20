import 'dart:convert';
import 'dart:io' as io;

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
///     `PATROL_DART_COV:` session blocks.
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
        help: 'BrowserStack session id within the build.',
        mandatory: true,
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

  @override
  Future<int> run() async {
    final buildId = stringArg('build-id')!;
    final sessionId = stringArg('session-id')!;
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

    outputDir.createSync(recursive: true);

    final url = Uri.parse(
      'https://api-cloud.browserstack.com/app-automate/espresso/v2/builds/$buildId/sessions/$sessionId/coverage',
    );
    _logger.info('Fetching $url');
    final res = await http.get(
      url,
      headers: {'Authorization': 'Basic ${base64Encode(utf8.encode(creds))}'},
    );
    if (res.statusCode != 200) {
      _logger.err(
        'BrowserStack returned ${res.statusCode}: ${res.body.substring(0, res.body.length.clamp(0, 500))}',
      );
      return 1;
    }
    final bytes = res.bodyBytes;
    _logger.info('Downloaded ${bytes.length} bytes');

    final BsCoverageSplitResult split;
    try {
      split = splitJacocoExec(bytes);
    } on FormatException catch (e) {
      _logger.err(
        'Failed to parse the BrowserStack coverage file: ${e.message}',
      );
      return 1;
    }
    _logger.info(
      'Parsed: ${split.jacocoSessions} JaCoCo session(s), '
      '${split.executionDataBlocks} class probe(s), '
      '${split.dartChunks} Dart chunk(s).',
    );

    final jacocoFile = outputDir.childFile('jacoco.exec')
      ..writeAsBytesSync(split.jacocoBytes);
    _logger.success('Wrote ${jacocoFile.path} (${split.jacocoBytes.length} B)');

    final lcovFile = outputDir.childFile('patrol_lcov.info')
      ..writeAsStringSync(split.dartLcov);
    _logger.success('Wrote ${lcovFile.path}');

    return 0;
  }
}
