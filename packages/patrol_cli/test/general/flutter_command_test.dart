import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterCommand.toDartCommand', () {
    test('maps a bare flutter to dart', () {
      final dart = const FlutterCommand('flutter').toDartCommand();

      expect(dart.executable, 'dart');
      expect(dart.arguments, isEmpty);
    });

    test('maps an absolute path, keeping the SDK it points at', () {
      final dart = const FlutterCommand(
        '/Users/me/fvm/versions/3.47.0/bin/flutter',
      ).toDartCommand();

      expect(dart.executable, '/Users/me/fvm/versions/3.47.0/bin/dart');
      expect(dart.arguments, isEmpty);
    });

    test('maps a wrapper that takes flutter as an argument', () {
      // `fvm flutter` must become `fvm dart`, not `dart` -- otherwise the
      // daemon would come from a different SDK than the app is built with.
      final dart = const FlutterCommand('fvm', ['flutter']).toDartCommand();

      expect(dart.executable, 'fvm');
      expect(dart.arguments, ['dart']);
    });

    test("keeps the wrapper's other arguments", () {
      final dart = const FlutterCommand('mise', [
        'exec',
        '--',
        'flutter',
      ]).toDartCommand();

      expect(dart.executable, 'mise');
      expect(dart.arguments, ['exec', '--', 'dart']);
    });

    test('maps Windows executables', () {
      final dart = const FlutterCommand(
        r'C:\src\flutter\bin\flutter.bat',
      ).toDartCommand();

      expect(dart.executable, r'C:\src\flutter\bin\dart.bat');
    });

    test('falls back to dart on PATH for an unrecognizable command', () {
      final dart = const FlutterCommand('some-wrapper', [
        'run',
      ]).toDartCommand();

      expect(dart.executable, 'dart');
      expect(dart.arguments, isEmpty);
    });

    test('parse + toDartCommand round trip', () {
      expect(
        FlutterCommand.parse('fvm flutter').toDartCommand().toString().trim(),
        'fvm dart',
      );
    });
  });
}
