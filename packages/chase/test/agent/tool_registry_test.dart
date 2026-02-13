import 'package:chase/src/agent/tool_registry.dart';
import 'package:chase/src/agent/tools/agent_tool.dart';
import 'package:test/test.dart';

class _MockTool extends AgentTool {
  @override
  String get name => 'mock_tool';

  @override
  String get description => 'A mock tool for testing.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'message': {'type': 'string'},
        },
        'required': ['message'],
      };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    return 'Executed with: ${input['message']}';
  }
}

void main() {
  group('ToolRegistry', () {
    late ToolRegistry registry;

    setUp(() {
      registry = ToolRegistry();
    });

    test('registers and retrieves tools', () {
      final tool = _MockTool();
      registry.register(tool);

      expect(registry.getTool('mock_tool'), isNotNull);
      expect(registry.getTool('mock_tool'), same(tool));
    });

    test('returns null for unknown tools', () {
      expect(registry.getTool('unknown'), isNull);
    });

    test('generates tool definitions', () {
      registry.register(_MockTool());

      final definitions = registry.toolDefinitions;

      expect(definitions, hasLength(1));
      expect(definitions.first.name, 'mock_tool');
      expect(definitions.first.description, 'A mock tool for testing.');
    });

    test('executes registered tool', () async {
      registry.register(_MockTool());

      final result = await registry.execute(
        'mock_tool',
        {'message': 'hello'},
      );

      expect(result, 'Executed with: hello');
    });

    test('returns error for unknown tool execution', () async {
      final result = await registry.execute('unknown', {});

      expect(result, contains('Unknown tool'));
    });
  });
}
