import 'package:patrol_cli/src/base/command_line.dart';
import 'package:test/test.dart';

void main() {
  group('splitCommandLine', () {
    test('splits on any whitespace', () {
      expect(splitCommandLine('  fvm   flutter\t--verbose\n'), [
        'fvm',
        'flutter',
        '--verbose',
      ]);
    });

    test('returns no arguments for blank input', () {
      expect(splitCommandLine(''), isEmpty);
      expect(splitCommandLine('   '), isEmpty);
    });

    test('keeps double-quoted text together', () {
      expect(splitCommandLine('--dart-define "MY_VAR=some value"'), [
        '--dart-define',
        'MY_VAR=some value',
      ]);
    });

    test('keeps single-quoted text together', () {
      expect(splitCommandLine("--dart-define 'MY_VAR=some value'"), [
        '--dart-define',
        'MY_VAR=some value',
      ]);
    });

    test('joins quoted text with the surrounding characters', () {
      expect(splitCommandLine('--dart-define=MY_VAR="some value"'), [
        '--dart-define=MY_VAR=some value',
      ]);
    });

    test('keeps the other kind of quote inside quotes', () {
      expect(splitCommandLine(''''say "hi"' "it's"'''), ['say "hi"', "it's"]);
    });

    test('keeps empty quotes as an empty argument', () {
      expect(splitCommandLine('--flavor ""'), ['--flavor', '']);
    });

    test('keeps backslashes as they are', () {
      expect(splitCommandLine(r'C:\flutter\bin\flutter.bat "C:\my sdk\"'), [
        r'C:\flutter\bin\flutter.bat',
        r'C:\my sdk\',
      ]);
    });

    test('keeps a quote without a closing pair as a normal character', () {
      expect(splitCommandLine("/Users/o'brien/flutter/bin/flutter --verbose"), [
        "/Users/o'brien/flutter/bin/flutter",
        '--verbose',
      ]);
      expect(splitCommandLine('--dart-define "MY_VAR=some value'), [
        '--dart-define',
        '"MY_VAR=some',
        'value',
      ]);
    });

    test('pairs two apostrophes unless they are in double quotes', () {
      expect(
        splitCommandLine("/Users/o'brien/flutter --dart-define=NAME=it's"),
        ['/Users/obrien/flutter --dart-define=NAME=its'],
      );
      expect(
        splitCommandLine(
          '''"/Users/o'brien/flutter" --dart-define=NAME=it's''',
        ),
        ["/Users/o'brien/flutter", "--dart-define=NAME=it's"],
      );
    });
  });
}
