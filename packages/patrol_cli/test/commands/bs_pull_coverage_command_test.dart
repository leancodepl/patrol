import 'dart:typed_data';

import 'package:args/command_runner.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/commands/bs_pull_coverage.dart';
import 'package:patrol_cli/src/coverage/bs_coverage_splitter.dart';
import 'package:test/test.dart';

import '../src/jacoco_exec_writer.dart';
import '../src/mocks.dart';

Uint8List _ec({String? lcov, String className = 'com/example/Foo'}) {
  final writer = JacocoExecWriter()
    ..header()
    ..sessionInfo('jacoco')
    ..executionData(1, className, 4);
  if (lcov != null) {
    writer.dartChunk(1, 1, lcov);
  }
  return writer.toBytes();
}

void main() {
  group('BsPullCoverageCommand --input', () {
    late MemoryFileSystem fs;
    late MockLogger logger;
    late CommandRunner<int> runner;

    setUp(() {
      fs = MemoryFileSystem.test();
      logger = MockLogger();
      runner = CommandRunner<int>('patrol', 'test')
        ..addCommand(BsPullCoverageCommand(logger: logger, fs: fs));
    });

    void writeFile(String path, List<int> bytes) {
      fs.file(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);
    }

    test(
      'merges every .ec under a directory, like emulator.wtf outputs',
      () async {
        final first = _ec(
          lcov: 'SF:package:app/a.dart\nDA:1,1\nDA:2,0\nend_of_record\n',
        );
        final second = _ec(
          lcov: 'SF:package:app/a.dart\nDA:1,0\nDA:2,3\nend_of_record\n',
          className: 'com/example/Bar',
        );
        writeFile('ew-out/Pixel7_api34/0/Test#a.ec', first);
        writeFile('ew-out/Pixel7_api34/1/Test#b.ec', second);
        writeFile('ew-out/Pixel7_api34/1/logcat.txt', [1, 2, 3]);

        final code = await runner.run([
          'pull-coverage',
          '--input',
          'ew-out',
          '--output',
          'cov',
        ]);

        expect(code, 0);
        expect(
          fs.file('cov/patrol_lcov.info').readAsStringSync(),
          'SF:package:app/a.dart\nDA:1,1\nDA:2,3\nLF:2\nLH:2\nend_of_record\n',
        );
        expect(fs.file('cov/jacoco.exec').readAsBytesSync(), [
          ...splitJacocoExec(first).jacocoBytes,
          ...splitJacocoExec(second).jacocoBytes,
        ]);
      },
    );

    test('accepts a single .ec file', () async {
      writeFile(
        'coverage.ec',
        _ec(lcov: 'SF:package:app/a.dart\nDA:1,1\nend_of_record\n'),
      );

      final code = await runner.run([
        'pull-coverage',
        '--input',
        'coverage.ec',
      ]);

      expect(code, 0);
      expect(
        fs.file('coverage/patrol_lcov.info').readAsStringSync(),
        'SF:package:app/a.dart\nDA:1,1\nLF:1\nLH:1\nend_of_record\n',
      );
    });

    test('warns, but succeeds, when there is no Dart coverage', () async {
      writeFile('coverage.ec', _ec());

      final code = await runner.run([
        'pull-coverage',
        '--input',
        'coverage.ec',
      ]);

      expect(code, 0);
      verify(
        () => logger.warn(any(that: contains('No Dart coverage'))),
      ).called(1);
    });

    test('fails on a malformed file and names it', () async {
      writeFile('out/broken.ec', [0x01, 0x02]);

      final code = await runner.run(['pull-coverage', '--input', 'out']);

      expect(code, 1);
      verify(() => logger.err(any(that: contains('broken.ec')))).called(1);
    });

    test('fails when the directory has no .ec files', () async {
      writeFile('out/logcat.txt', [1]);

      expect(await runner.run(['pull-coverage', '--input', 'out']), 1);
      verify(() => logger.err(any(that: contains('No .ec files')))).called(1);
    });

    test('fails when the input does not exist', () async {
      expect(await runner.run(['pull-coverage', '--input', 'missing']), 1);
      verify(() => logger.err(any(that: contains('does not exist')))).called(1);
    });

    test('rejects --session-id together with --input', () async {
      writeFile('coverage.ec', _ec());

      final code = await runner.run([
        'pull-coverage',
        '--input',
        'coverage.ec',
        '--session-id',
        'abc',
      ]);

      expect(code, 1);
      expect(fs.directory('coverage').existsSync(), isFalse);
    });

    test('requires exactly one of --input and --build-id', () async {
      expect(await runner.run(['pull-coverage']), 1);
      expect(
        await runner.run(['pull-coverage', '--input', 'x', '--build-id', 'y']),
        1,
      );
      verify(() => logger.err(any(that: contains('Pass either')))).called(2);
    });
  });
}
