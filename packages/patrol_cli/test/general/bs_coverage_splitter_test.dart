import 'dart:typed_data';

import 'package:patrol_cli/src/coverage/bs_coverage_splitter.dart';
import 'package:test/test.dart';

import '../src/jacoco_exec_writer.dart';

void main() {
  group('splitJacocoExec', () {
    test('splits mixed standard and patrol-injected blocks', () {
      final w = JacocoExecWriter()
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
      final w = JacocoExecWriter()
        ..header()
        ..dartChunk(3, 3, 'third\n')
        ..dartChunk(1, 3, 'first\n')
        ..dartChunk(2, 3, 'second\n');

      final result = splitJacocoExec(w.toBytes());

      expect(result.dartChunks, 3);
      expect(result.dartLcov, 'first\nsecond\nthird\n');
    });

    test('produces empty LCOV when there are no patrol chunks', () {
      final w = JacocoExecWriter()
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
      final w = JacocoExecWriter()..header();
      final bytes = BytesBuilder()
        ..add(w.toBytes())
        ..addByte(0x99); // unknown block

      expect(
        () => splitJacocoExec(bytes.toBytes()),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a missing chunk (truncated payload)', () {
      final w = JacocoExecWriter()
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
      final w = JacocoExecWriter()
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
      final w = JacocoExecWriter()
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

  group('mergeLcovRecords', () {
    test('passes through a single record unchanged (modulo TN:)', () {
      const lcov =
          'TN:a\n'
          'SF:package:app/a.dart\n'
          'DA:1,1\n'
          'DA:2,0\n'
          'LF:2\n'
          'LH:1\n'
          'end_of_record\n';

      expect(
        mergeLcovRecords(lcov),
        'SF:package:app/a.dart\n'
        'DA:1,1\n'
        'DA:2,0\n'
        'LF:2\n'
        'LH:1\n'
        'end_of_record\n',
      );
    });

    test('unions hit lines across records for the same file', () {
      // test A covered line 1, test B covered line 2 of the same file: neither
      // record alone shows the other line as hit, so a naive concatenation
      // could let test B's record shadow test A's data for line 1.
      const lcov =
          'TN:a\n'
          'SF:package:app/shared.dart\n'
          'DA:1,3\n'
          'DA:2,0\n'
          'LF:2\n'
          'LH:1\n'
          'end_of_record\n'
          'TN:b\n'
          'SF:package:app/shared.dart\n'
          'DA:1,0\n'
          'DA:2,5\n'
          'LF:2\n'
          'LH:1\n'
          'end_of_record\n';

      expect(
        mergeLcovRecords(lcov),
        'SF:package:app/shared.dart\n'
        'DA:1,3\n'
        'DA:2,5\n'
        'LF:2\n'
        'LH:2\n'
        'end_of_record\n',
      );
    });

    test('keeps distinct files as separate records, order preserved', () {
      const lcov =
          'SF:package:app/a.dart\n'
          'DA:1,1\n'
          'LF:1\n'
          'LH:1\n'
          'end_of_record\n'
          'SF:package:app/b.dart\n'
          'DA:1,0\n'
          'LF:1\n'
          'LH:0\n'
          'end_of_record\n';

      expect(mergeLcovRecords(lcov), lcov);
    });

    test('returns empty string for empty input', () {
      expect(mergeLcovRecords(''), isEmpty);
    });
  });
}
