import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/features/run_commons//dart_defines_reader.dart';
import 'package:test/test.dart';

void main() {
  late FileSystem fs;

  group('DartDefinesReader', () {
    late DartDefinesReader reader;

    setUp(() {
      fs = MemoryFileSystem.test();
      final wd = fs.directory('/projects/awesome_app')
        ..createSync(recursive: true);
      fs.currentDirectory = wd;
      reader = DartDefinesReader(fs: fs, projectRoot: fs.currentDirectory);
    });

    group('fromCli()', () {
      test('reads correct simple input', () {
        final args = [
          'EMAIL=email@example.com',
          'PASSWORD=ny4ncat',
        ];

        expect(
          reader.fromCli(args: args),
          equals({'EMAIL': 'email@example.com', 'PASSWORD': 'ny4ncat'}),
        );
      });

      test('reads correct complex input', () {
        final args = [
          'EMAIL=email@wrong=domain.com',
          r'PASSWORD="ny4ncat\n"',
        ];

        expect(
          reader.fromCli(args: args),
          equals({
            'EMAIL': 'email@wrong=domain.com',
            'PASSWORD': r'"ny4ncat\n"',
          }),
        );
      });
    });

    group('fromFile()', () {
      late File file;
      setUp(() {
        file = fs.file('.patrol.env');
      });

      test('reads correct simple input', () {
        file.writeAsString('EMAIL=email@example.com\nPASSWORD=ny4ncat\n');

        expect(
          reader.fromFile(),
          equals({'EMAIL': 'email@example.com', 'PASSWORD': 'ny4ncat'}),
        );
      });

      test('reads correct simple input with empty lines', () {
        file.writeAsString('EMAIL=email@example.com\n\nPASSWORD=ny4ncat\n');

        expect(
          reader.fromFile(),
          equals({'EMAIL': 'email@example.com', 'PASSWORD': 'ny4ncat'}),
        );
      });
    });
  });
}
