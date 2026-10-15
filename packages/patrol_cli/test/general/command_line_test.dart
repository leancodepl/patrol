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

    test('throws on an unclosed quote', () {
      expect(
        () => splitCommandLine('--dart-define "MY_VAR=some value'),
        throwsFormatException,
      );
    });
  });
}
