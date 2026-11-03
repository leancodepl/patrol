import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterCommand.parse', () {
    test('splits the executable from its arguments', () {
      final command = FlutterCommand.parse('fvm flutter');

      expect(command.executable, 'fvm');
      expect(command.arguments, ['flutter']);
    });

    test('keeps a quoted executable path with spaces together', () {
      final command = FlutterCommand.parse(
        '"/Users/me/my sdk/bin/flutter" --no-version-check',
      );

      expect(command.executable, '/Users/me/my sdk/bin/flutter');
      expect(command.arguments, ['--no-version-check']);
    });
  });
}
