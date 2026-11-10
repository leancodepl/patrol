import 'dart:convert';
import 'dart:typed_data';

/// Result of splitting a BrowserStack Espresso JaCoCo `.ec` file into its
/// standard JaCoCo blocks and the Dart coverage chunks patrol appended.
class BsCoverageSplitResult {
  BsCoverageSplitResult({
    required this.jacocoBytes,
    required this.dartLcov,
    required this.jacocoSessions,
    required this.executionDataBlocks,
    required this.dartChunks,
    required this.dartRuns,
    required this.taggedDartRuns,
  });

  /// A valid JaCoCo binary file containing only the standard `SessionInfo` +
  /// `ExecutionData` blocks (patrol's Dart blocks stripped out).
  final Uint8List jacocoBytes;

  /// The merged LCOV reconstructed from the `PATROL_DART_COV:` blocks.
  final String dartLcov;

  /// Number of standard JaCoCo `SessionInfo` blocks kept.
  final int jacocoSessions;

  /// Number of `ExecutionData` (class probe) blocks kept.
  final int executionDataBlocks;

  /// Number of Dart coverage chunks decoded.
  final int dartChunks;

  /// Number of separate Dart coverage dumps (one per test process under
  /// `clearPackageData:true`, else usually one).
  final int dartRuns;

  /// How many of [dartRuns] carry a run id. Only shell-appended runs do, so
  /// zero under `clearPackageData:true` means only the first test's coverage
  /// made it into the file.
  final int taggedDartRuns;
}

/// JaCoCo .exec splitter. Reads the binary block stream and partitions it into
/// "standard" blocks (kept verbatim) and patrol-appended Dart chunks (decoded
/// back to LCOV). Accepts concatenated dumps (a header per appended run), as
/// written per test under `clearPackageData:true`.
///
/// Throws a [FormatException] on a malformed stream or a truncated/partial set
/// of Dart chunks, rather than silently writing an incomplete LCOV.
BsCoverageSplitResult splitJacocoExec(Uint8List bytes) {
  final reader = _CompactReader(bytes);
  final out = BytesBuilder();
  // Keyed by run id: under clearPackageData every test appends its own run.
  final runs = <String, _DartRun>{};
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
  reader
    ..readUint16()
    ..readUint16();
  out.add(bytes.sublist(headerStart, reader.offset));

  while (reader.hasMore) {
    final blockStart = reader.offset;
    final type = reader.readUint8();
    switch (type) {
      case _blockHeader:
        reader
          ..readUint16()
          ..readUint16();
        out.add(bytes.sublist(blockStart, reader.offset));
      case _blockSessionInfo:
        final id = reader.readUtf();
        final start = reader.readInt64();
        final dump = reader.readInt64();
        if (id.startsWith(_patrolPrefix)) {
          // id format: PATROL_DART_COV:[<runId>:]<seq>:<total>:<base64>
          // (base64 has no ':', older builds omit runId).
          final parts = id.substring(_patrolPrefix.length).split(':');
          if (parts.length != 3 && parts.length != 4) {
            continue;
          }
          final runId = parts.length == 4 ? parts.removeAt(0) : '';
          final seq = int.parse(parts[0]);
          final total = int.parse(parts[1]);
          final decoded = utf8.decode(base64.decode(parts[2]));
          final run = runs.putIfAbsent(runId, _DartRun.new);
          if (run.chunks.containsKey(seq)) {
            throw FormatException(
              'duplicate Dart coverage chunk seq $seq${_runLabel(runId)}',
            );
          }
          run.totals.add(total);
          run.chunks[seq] = decoded;
          totalDartChunks++;
        } else {
          out.add(bytes.sublist(blockStart, reader.offset));
          sessions++;
          // touch start/dump to silence unused warning
          assert(start <= dump || dump <= start);
        }
      case _blockExecutionData:
        reader
          ..readInt64() // classId
          ..readUtf() // name
          ..readBooleanArray(); // probes
        out.add(bytes.sublist(blockStart, reader.offset));
        execData++;
      default:
        throw FormatException(
          'unknown block type 0x${type.toRadixString(16)} at offset $blockStart',
        );
    }
  }

  // Reject a partial/truncated payload rather than silently writing an
  // incomplete LCOV. Within a run every chunk advertises the same <total>, and
  // seqs must cover 1..total exactly once.
  final lcov = StringBuffer();
  for (final MapEntry(key: runId, value: run) in runs.entries) {
    if (run.totals.length != 1) {
      throw FormatException(
        'inconsistent Dart coverage chunk totals${_runLabel(runId)}: '
        '${run.totals}',
      );
    }
    final total = run.totals.single;
    if (run.chunks.length != total) {
      final missing = <int>[
        for (var i = 1; i <= total; i++)
          if (!run.chunks.containsKey(i)) i,
      ];
      throw FormatException(
        'incomplete Dart coverage${_runLabel(runId)}: got '
        '${run.chunks.length} of $total chunk(s), missing seq(s) $missing '
        '(response truncated?)',
      );
    }
    final orderedSeqs = run.chunks.keys.toList()..sort();
    for (final s in orderedSeqs) {
      lcov.write(run.chunks[s]);
    }
  }

  return BsCoverageSplitResult(
    jacocoBytes: out.toBytes(),
    dartLcov: lcov.toString(),
    jacocoSessions: sessions,
    executionDataBlocks: execData,
    dartChunks: totalDartChunks,
    dartRuns: runs.length,
    taggedDartRuns: runs.keys.where((runId) => runId.isNotEmpty).length,
  );
}

class _DartRun {
  final chunks = <int, String>{};
  final totals = <int>{};
}

String _runLabel(String runId) => runId.isEmpty ? '' : ' in run $runId';

/// Merges duplicate `SF:` (source file) records in a concatenated LCOV blob
/// into one record per file, taking the union of hit lines (max hit count per
/// line). Needed because the native side now embeds one LCOV per test rather
/// than one cumulative LCOV per process — tests commonly cover overlapping
/// files, and naively concatenating their records would leave a later test's
/// block shadowing an earlier one's data for the same file in tools that
/// don't already merge repeated `SF:` sections. Drops `TN:` (test name) since
/// after merging across tests it no longer identifies a single test.
String mergeLcovRecords(String lcov) {
  final byFile = <String, Map<int, int>>{};
  final fileOrder = <String>[];
  String? currentFile;

  for (final rawLine in lcov.split('\n')) {
    final line = rawLine.trimRight();
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      if (!byFile.containsKey(currentFile)) {
        fileOrder.add(currentFile);
        byFile[currentFile] = <int, int>{};
      }
    } else if (line.startsWith('DA:') && currentFile != null) {
      final rest = line.substring(3);
      final comma = rest.indexOf(',');
      if (comma < 0) {
        continue;
      }
      final lineNo = int.parse(rest.substring(0, comma));
      final count = int.parse(rest.substring(comma + 1));
      final perFile = byFile[currentFile]!;
      final existing = perFile[lineNo];
      if (existing == null || count > existing) {
        perFile[lineNo] = count;
      }
    }
  }

  final buf = StringBuffer();
  for (final file in fileOrder) {
    final lines = byFile[file]!;
    final sortedLines = lines.keys.toList()..sort();
    buf.writeln('SF:$file');
    var hit = 0;
    for (final lineNo in sortedLines) {
      final count = lines[lineNo]!;
      buf.writeln('DA:$lineNo,$count');
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

const _blockHeader = 0x01;
const _blockSessionInfo = 0x10;
const _blockExecutionData = 0x11;
const _patrolPrefix = 'PATROL_DART_COV:';

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
      if ((b & 0x80) == 0) {
        return result;
      }
      shift += 7;
    }
  }
}
