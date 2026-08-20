import 'dart:convert';
import 'dart:typed_data';

import 'package:patrol_cli/src/coverage/bs_coverage_splitter.dart';
import 'package:test/test.dart';

/// Mirrors the subset of JaCoCo's binary writer that the splitter reads, so the
/// tests can build realistic `.ec` byte streams (big-endian primitives,
/// Java-style modified UTF-8, CompactDataOutput packed boolean arrays).
class _ExecWriter {
  final BytesBuilder _b = BytesBuilder();

  Uint8List toBytes() => _b.toBytes();

  void _u8(int v) => _b.addByte(v & 0xFF);

  void _u16(int v) {
    _b
      ..addByte((v >> 8) & 0xFF)
      ..addByte(v & 0xFF);
  }

  void _i64(int v) {
    final d = ByteData(8)..setInt64(0, v);
    _b.add(d.buffer.asUint8List());
  }

  void _utf(String s) {
    final bytes = utf8.encode(s);
    _u16(bytes.length);
    _b.add(bytes);
  }

  void _varInt(int value) {
    var v = value;
    while ((v & ~0x7F) != 0) {
      _u8((v & 0x7F) | 0x80);
      v >>= 7;
    }
    _u8(v & 0x7F);
  }

  void header() {
    _u8(0x01); // BLOCK_HEADER
    _u16(0xC0C0); // magic
    _u16(0x1007); // version
  }

  void sessionInfo(String id, {int start = 0, int dump = 0}) {
    _u8(0x10); // BLOCK_SESSIONINFO
    _utf(id);
    _i64(start);
    _i64(dump);
  }

  void dartChunk(int seq, int total, String lcov) {
    final b64 = base64.encode(utf8.encode(lcov));
    sessionInfo('PATROL_DART_COV:$seq:$total:$b64');
  }

  void executionData(int classId, String name, int probeCount) {
    _u8(0x11); // BLOCK_EXECUTIONDATA
    _i64(classId);
    _utf(name);
    _varInt(probeCount);
    final byteCount = (probeCount + 7) >> 3;
    _b.add(Uint8List(byteCount)); // packed bits, content irrelevant to reader
  }
}

void main() {
  group('splitJacocoExec', () {
    test('splits mixed standard and patrol-injected blocks', () {
      final w = _ExecWriter()
        ..header()
        ..sessionInfo('session-1')
        ..executionData(0xABCD, 'com/example/Foo', 12)
        ..dartChunk(1, 2, 'TN:a\nSF:package:app/a.dart\n')
        ..dartChunk(2, 2, 'DA:1,1\nend_of_record\n');

      final result = splitJacocoExec(w.toBytes());

      expect(result.jacocoSessions, 1);
      expect(result.executionDataBlocks, 1);
      expect(result.dartChunks, 2);
      expect(
        result.dartLcov,
        'TN:a\nSF:package:app/a.dart\nDA:1,1\nend_of_record\n',
      );

      // The stripped jacoco bytes must still parse and carry no Dart chunks.
      final reparsed = splitJacocoExec(result.jacocoBytes);
      expect(reparsed.jacocoSessions, 1);
      expect(reparsed.executionDataBlocks, 1);
      expect(reparsed.dartChunks, 0);
      expect(reparsed.dartLcov, isEmpty);
    });

    test('reassembles chunks in sequence order regardless of write order', () {
      final w = _ExecWriter()
        ..header()
        ..dartChunk(3, 3, 'third\n')
        ..dartChunk(1, 3, 'first\n')
        ..dartChunk(2, 3, 'second\n');

      final result = splitJacocoExec(w.toBytes());

      expect(result.dartChunks, 3);
      expect(result.dartLcov, 'first\nsecond\nthird\n');
    });

    test('produces empty LCOV when there are no patrol chunks', () {
      final w = _ExecWriter()
        ..header()
        ..sessionInfo('only-standard')
        ..executionData(1, 'A', 3);

      final result = splitJacocoExec(w.toBytes());

      expect(result.dartChunks, 0);
      expect(result.dartLcov, isEmpty);
      expect(result.jacocoSessions, 1);
    });

    test('rejects a truncated header', () {
      expect(
        () => splitJacocoExec(Uint8List.fromList([0x01, 0x02])),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an unknown block type', () {
      final w = _ExecWriter()..header();
      final bytes = BytesBuilder()
        ..add(w.toBytes())
        ..addByte(0x99); // unknown block

      expect(
        () => splitJacocoExec(bytes.toBytes()),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a missing chunk (truncated payload)', () {
      final w = _ExecWriter()
        ..header()
        ..dartChunk(1, 3, 'first\n')
        ..dartChunk(2, 3, 'second\n');
      // seq 3 never arrived (e.g. BrowserStack truncated the response).

      expect(
        () => splitJacocoExec(w.toBytes()),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(contains('got 2 of 3'), contains('[3]')),
          ),
        ),
      );
    });

    test('rejects a duplicate chunk sequence', () {
      final w = _ExecWriter()
        ..header()
        ..dartChunk(1, 2, 'first\n')
        ..dartChunk(1, 2, 'dup\n')
        ..dartChunk(2, 2, 'second\n');

      expect(
        () => splitJacocoExec(w.toBytes()),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('duplicate'),
          ),
        ),
      );
    });

    test('rejects inconsistent chunk totals', () {
      final w = _ExecWriter()
        ..header()
        ..dartChunk(1, 2, 'first\n')
        ..dartChunk(2, 3, 'second\n');

      expect(
        () => splitJacocoExec(w.toBytes()),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('inconsistent'),
          ),
        ),
      );
    });
  });
}
