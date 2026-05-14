import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:patrol_cli/src/base/logger.dart';
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
    final outputDir = _fs.directory(stringArg('output')!);
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

    final split = _SplitJacocoExec.split(bytes);
    _logger.info(
      'Parsed: ${split.jacocoSessions} JaCoCo session(s), '
      '${split.executionDataBlocks} class probe(s), '
      '${split.dartChunks} Dart chunk(s).',
    );

    final jacocoFile = outputDir.childFile('jacoco.exec');
    jacocoFile.writeAsBytesSync(split.jacocoBytes);
    _logger.success('Wrote ${jacocoFile.path} (${split.jacocoBytes.length} B)');

    final lcovFile = outputDir.childFile('patrol_lcov.info');
    lcovFile.writeAsStringSync(split.dartLcov);
    _logger.success('Wrote ${lcovFile.path}');

    return 0;
  }
}

/// JaCoCo .exec splitter. Reads the binary block stream and partitions it
/// into "standard" blocks (kept verbatim) and patrol-appended Dart chunks
/// (decoded back to LCOV).
class _SplitJacocoExec {
  _SplitJacocoExec._({
    required this.jacocoBytes,
    required this.dartLcov,
    required this.jacocoSessions,
    required this.executionDataBlocks,
    required this.dartChunks,
  });

  final Uint8List jacocoBytes;
  final String dartLcov;
  final int jacocoSessions;
  final int executionDataBlocks;
  final int dartChunks;

  static const _blockHeader = 0x01;
  static const _blockSessionInfo = 0x10;
  static const _blockExecutionData = 0x11;
  static const _patrolPrefix = 'PATROL_DART_COV:';

  static _SplitJacocoExec split(Uint8List bytes) {
    final reader = _CompactReader(bytes);
    final out = BytesBuilder();
    final dartChunks = <int, String>{};
    var totalDartChunks = 0;
    var sessions = 0;
    var execData = 0;

    if (bytes.length < 5) {
      throw const FormatException('truncated .exec: missing header');
    }

    // Copy header verbatim.
    final headerStart = reader.offset;
    final firstByte = reader.readUint8();
    if (firstByte != _blockHeader) {
      throw FormatException(
        'expected BLOCK_HEADER (0x01), got 0x${firstByte.toRadixString(16)}',
      );
    }
    // magic (char/u16) + version (char/u16)
    reader.readUint16();
    reader.readUint16();
    out.add(bytes.sublist(headerStart, reader.offset));

    while (reader.hasMore) {
      final blockStart = reader.offset;
      final type = reader.readUint8();
      switch (type) {
        case _blockSessionInfo:
          final id = reader.readUtf();
          final start = reader.readInt64();
          final dump = reader.readInt64();
          if (id.startsWith(_patrolPrefix)) {
            // id format: PATROL_DART_COV:<seq>:<total>:<base64>
            final rest = id.substring(_patrolPrefix.length);
            final firstColon = rest.indexOf(':');
            final secondColon = rest.indexOf(':', firstColon + 1);
            if (firstColon < 0 || secondColon < 0) {
              continue;
            }
            final seq = int.parse(rest.substring(0, firstColon));
            // total is at rest[firstColon+1..secondColon]; payload after.
            final payload = rest.substring(secondColon + 1);
            final decoded = utf8.decode(base64.decode(payload));
            dartChunks[seq] = decoded;
            totalDartChunks++;
          } else {
            out.add(bytes.sublist(blockStart, reader.offset));
            sessions++;
            // touch start/dump to silence unused warning
            assert(start <= dump || dump <= start);
          }
          break;
        case _blockExecutionData:
          reader.readInt64(); // classId
          reader.readUtf(); // name
          reader.readBooleanArray(); // probes
          out.add(bytes.sublist(blockStart, reader.offset));
          execData++;
          break;
        default:
          throw FormatException(
            'unknown block type 0x${type.toRadixString(16)} at offset $blockStart',
          );
      }
    }

    final orderedSeqs = dartChunks.keys.toList()..sort();
    final lcov = StringBuffer();
    for (final s in orderedSeqs) {
      lcov.write(dartChunks[s]);
    }

    return _SplitJacocoExec._(
      jacocoBytes: out.toBytes(),
      dartLcov: lcov.toString(),
      jacocoSessions: sessions,
      executionDataBlocks: execData,
      dartChunks: totalDartChunks,
    );
  }
}

/// Decodes the subset of JaCoCo's CompactDataOutput stream we need:
/// big-endian primitives, Java-style modified UTF-8, and the CompactDataOutput
/// variable-length encoding used for the probe boolean array.
class _CompactReader {
  _CompactReader(this._bytes) : _data = ByteData.sublistView(_bytes);

  final Uint8List _bytes;
  final ByteData _data;
  int offset = 0;

  bool get hasMore => offset < _bytes.length;

  int readUint8() => _bytes[offset++];

  int readUint16() {
    final v = _data.getUint16(offset);
    offset += 2;
    return v;
  }

  int readInt64() {
    final v = _data.getInt64(offset);
    offset += 8;
    return v;
  }

  String readUtf() {
    final len = readUint16();
    // Modified UTF-8: for our payloads (ASCII base64 + ASCII prefix) it's
    // byte-equivalent to standard UTF-8. Decode permissively.
    final bytes = _bytes.sublist(offset, offset + len);
    offset += len;
    return utf8.decode(bytes, allowMalformed: true);
  }

  /// CompactDataOutput packed boolean array: VarInt length, then ceil(n/8)
  /// bytes of bit-packed values.
  void readBooleanArray() {
    final n = _readVarInt();
    final byteCount = (n + 7) >> 3;
    offset += byteCount;
  }

  int _readVarInt() {
    var result = 0;
    var shift = 0;
    while (true) {
      final b = readUint8();
      result |= (b & 0x7F) << shift;
      if ((b & 0x80) == 0) return result;
      shift += 7;
    }
  }
}
