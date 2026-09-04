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
}

/// JaCoCo .exec splitter. Reads the binary block stream and partitions it into
/// "standard" blocks (kept verbatim) and patrol-appended Dart chunks (decoded
/// back to LCOV).
///
/// Throws a [FormatException] on a malformed stream or a truncated/partial set
/// of Dart chunks, rather than silently writing an incomplete LCOV.
BsCoverageSplitResult splitJacocoExec(Uint8List bytes) {
  final reader = _CompactReader(bytes);
  final out = BytesBuilder();
  final dartChunks = <int, String>{};
  final declaredTotals = <int>{};
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
          final total = int.parse(rest.substring(firstColon + 1, secondColon));
          final payload = rest.substring(secondColon + 1);
          final decoded = utf8.decode(base64.decode(payload));
          if (dartChunks.containsKey(seq)) {
            throw FormatException('duplicate Dart coverage chunk seq $seq');
          }
          declaredTotals.add(total);
          dartChunks[seq] = decoded;
          totalDartChunks++;
        } else {
          out.add(bytes.sublist(blockStart, reader.offset));
          sessions++;
          // touch start/dump to silence unused warning
          assert(start <= dump || dump <= start);
        }
      case _blockExecutionData:
        reader.readInt64(); // classId
        reader.readUtf(); // name
        reader.readBooleanArray(); // probes
        out.add(bytes.sublist(blockStart, reader.offset));
        execData++;
      default:
        throw FormatException(
          'unknown block type 0x${type.toRadixString(16)} at offset $blockStart',
        );
    }
  }

  // Reject a partial/truncated payload rather than silently writing an
  // incomplete LCOV. Every chunk advertises the same <total>, and seqs must
  // cover 1..total exactly once.
  if (dartChunks.isNotEmpty) {
    if (declaredTotals.length != 1) {
      throw FormatException(
        'inconsistent Dart coverage chunk totals: $declaredTotals',
      );
    }
    final total = declaredTotals.single;
    if (dartChunks.length != total) {
      final missing = <int>[];
      for (var i = 1; i <= total; i++) {
        if (!dartChunks.containsKey(i)) {
          missing.add(i);
        }
      }
      throw FormatException(
        'incomplete Dart coverage: got ${dartChunks.length} of $total '
        'chunk(s), missing seq(s) $missing (response truncated?)',
      );
    }
  }

  final orderedSeqs = dartChunks.keys.toList()..sort();
  final lcov = StringBuffer();
  for (final s in orderedSeqs) {
    lcov.write(dartChunks[s]);
  }

  return BsCoverageSplitResult(
    jacocoBytes: out.toBytes(),
    dartLcov: lcov.toString(),
    jacocoSessions: sessions,
    executionDataBlocks: execData,
    dartChunks: totalDartChunks,
  );
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
