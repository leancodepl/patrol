import 'package:patrol_cli/src/commands/mcp.dart';
import 'package:test/test.dart';

void main() {
  group('McpCommand.developArgsFrom', () {
    test('prefers the arguments after --', () {
      expect(McpCommand.developArgsFrom(['--flavor', 'dev'], '--flavor prod'), [
        '--flavor',
        'dev',
      ]);
    });

    test('keeps a quoted PATROL_FLAGS value together', () {
      expect(
        McpCommand.developArgsFrom(
          const [],
          '--flavor dev --dart-define "GREETING=hello world"',
        ),
        ['--flavor', 'dev', '--dart-define', 'GREETING=hello world'],
      );
    });

    test('gives no flags for an empty or blank PATROL_FLAGS', () {
      expect(McpCommand.developArgsFrom(const [], null), isEmpty);
      expect(McpCommand.developArgsFrom(const [], '   '), isEmpty);
    });
  });
}
