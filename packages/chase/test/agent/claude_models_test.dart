import 'package:chase/src/agent/claude_models.dart';
import 'package:test/test.dart';

void main() {
  group('ClaudeResponse', () {
    test('parses text response', () {
      final json = {
        'id': 'msg_123',
        'content': [
          {'type': 'text', 'text': 'Hello world'},
        ],
        'stop_reason': 'end_turn',
        'usage': {
          'input_tokens': 100,
          'output_tokens': 50,
        },
      };

      final response = ClaudeResponse.fromJson(json);

      expect(response.id, 'msg_123');
      expect(response.textContent, 'Hello world');
      expect(response.isEndTurn, isTrue);
      expect(response.hasToolUse, isFalse);
      expect(response.usage.inputTokens, 100);
      expect(response.usage.outputTokens, 50);
    });

    test('parses tool use response', () {
      final json = {
        'id': 'msg_456',
        'content': [
          {'type': 'text', 'text': 'Let me read that file.'},
          {
            'type': 'tool_use',
            'id': 'tu_789',
            'name': 'read_file',
            'input': {'path': 'lib/main.dart'},
          },
        ],
        'stop_reason': 'tool_use',
        'usage': {
          'input_tokens': 200,
          'output_tokens': 100,
        },
      };

      final response = ClaudeResponse.fromJson(json);

      expect(response.hasToolUse, isTrue);
      expect(response.isEndTurn, isFalse);
      expect(response.toolUseBlocks, hasLength(1));
      expect(response.toolUseBlocks.first.name, 'read_file');
      expect(response.toolUseBlocks.first.input['path'], 'lib/main.dart');
      expect(response.textContent, 'Let me read that file.');
    });

    test('parses multiple tool use blocks', () {
      final json = {
        'id': 'msg_multi',
        'content': [
          {
            'type': 'tool_use',
            'id': 'tu_1',
            'name': 'read_file',
            'input': {'path': 'a.dart'},
          },
          {
            'type': 'tool_use',
            'id': 'tu_2',
            'name': 'list_files',
            'input': {'pattern': 'lib/**/*.dart'},
          },
        ],
        'stop_reason': 'tool_use',
        'usage': {
          'input_tokens': 300,
          'output_tokens': 150,
        },
      };

      final response = ClaudeResponse.fromJson(json);

      expect(response.toolUseBlocks, hasLength(2));
      expect(response.toolUseBlocks[0].name, 'read_file');
      expect(response.toolUseBlocks[1].name, 'list_files');
    });
  });

  group('ClaudeRequest', () {
    test('serializes to JSON correctly', () {
      final request = ClaudeRequest(
        model: 'claude-sonnet-4-20250514',
        system: 'You are a test agent.',
        messages: [
          const ClaudeMessage(role: 'user', content: 'Generate tests.'),
        ],
        tools: [
          const ClaudeTool(
            name: 'read_file',
            description: 'Read a file.',
            inputSchema: {
              'type': 'object',
              'properties': {
                'path': {'type': 'string'},
              },
              'required': ['path'],
            },
          ),
        ],
        maxTokens: 4096,
        temperature: 0.0,
      );

      final json = request.toJson();

      expect(json['model'], 'claude-sonnet-4-20250514');
      expect(json['system'], 'You are a test agent.');
      expect(json['messages'], hasLength(1));
      expect(json['tools'], hasLength(1));
      expect(json['max_tokens'], 4096);
      expect(json['temperature'], 0.0);
    });
  });

  group('ContentBlock', () {
    test('TextBlock serializes correctly', () {
      final block = TextBlock(text: 'hello');
      expect(block.toJson(), {'type': 'text', 'text': 'hello'});
    });

    test('ToolUseBlock serializes correctly', () {
      final block = ToolUseBlock(
        id: 'tu_1',
        name: 'read_file',
        input: {'path': 'test.dart'},
      );
      final json = block.toJson();
      expect(json['type'], 'tool_use');
      expect(json['id'], 'tu_1');
      expect(json['name'], 'read_file');
    });

    test('ToolResultBlock serializes correctly', () {
      final block = ToolResultBlock(
        toolUseId: 'tu_1',
        content: 'file contents here',
      );
      final json = block.toJson();
      expect(json['type'], 'tool_result');
      expect(json['tool_use_id'], 'tu_1');
      expect(json['content'], 'file contents here');
      expect(json.containsKey('is_error'), isFalse);
    });

    test('ToolResultBlock with error serializes correctly', () {
      final block = ToolResultBlock(
        toolUseId: 'tu_1',
        content: 'File not found',
        isError: true,
      );
      final json = block.toJson();
      expect(json['is_error'], isTrue);
    });
  });
}
