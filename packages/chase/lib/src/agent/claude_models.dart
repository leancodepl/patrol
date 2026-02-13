import 'package:meta/meta.dart';

/// Request to the Claude Messages API.
@immutable
class ClaudeRequest {
  const ClaudeRequest({
    required this.model,
    required this.messages,
    required this.system,
    this.tools,
    this.maxTokens = 4096,
    this.temperature = 0.0,
  });

  final String model;
  final List<ClaudeMessage> messages;
  final String system;
  final List<ClaudeTool>? tools;
  final int maxTokens;
  final double temperature;

  Map<String, dynamic> toJson() => {
        'model': model,
        'messages': messages.map((m) => m.toJson()).toList(),
        'system': system,
        if (tools != null && tools!.isNotEmpty)
          'tools': tools!.map((t) => t.toJson()).toList(),
        'max_tokens': maxTokens,
        'temperature': temperature,
      };
}

/// A message in the Claude conversation.
@immutable
class ClaudeMessage {
  const ClaudeMessage({
    required this.role,
    required this.content,
  });

  final String role; // 'user' or 'assistant'
  final dynamic content; // String or List<ContentBlock>

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content is String
            ? content
            : (content as List).map((b) {
                if (b is ContentBlock) return b.toJson();
                return b as Map<String, dynamic>;
              }).toList(),
      };
}

/// A content block in a message.
abstract class ContentBlock {
  Map<String, dynamic> toJson();
}

/// Text content block.
@immutable
class TextBlock extends ContentBlock {
  TextBlock({required this.text});

  final String text;

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};
}

/// Tool use content block (from assistant).
@immutable
class ToolUseBlock extends ContentBlock {
  ToolUseBlock({
    required this.id,
    required this.name,
    required this.input,
  });

  final String id;
  final String name;
  final Map<String, dynamic> input;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'tool_use',
        'id': id,
        'name': name,
        'input': input,
      };
}

/// Tool result content block (from user).
@immutable
class ToolResultBlock extends ContentBlock {
  ToolResultBlock({
    required this.toolUseId,
    required this.content,
    this.isError = false,
  });

  final String toolUseId;
  final String content;
  final bool isError;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'tool_result',
        'tool_use_id': toolUseId,
        'content': content,
        if (isError) 'is_error': true,
      };
}

/// Tool definition for Claude API.
@immutable
class ClaudeTool {
  const ClaudeTool({
    required this.name,
    required this.description,
    required this.inputSchema,
  });

  final String name;
  final String description;
  final Map<String, dynamic> inputSchema;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'input_schema': inputSchema,
      };
}

/// Response from the Claude Messages API.
@immutable
class ClaudeResponse {
  const ClaudeResponse({
    required this.id,
    required this.content,
    required this.stopReason,
    required this.usage,
  });

  factory ClaudeResponse.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List;
    final content = contentList.map((block) {
      final type = block['type'] as String;
      switch (type) {
        case 'text':
          return TextBlock(text: block['text'] as String);
        case 'tool_use':
          return ToolUseBlock(
            id: block['id'] as String,
            name: block['name'] as String,
            input: Map<String, dynamic>.from(block['input'] as Map),
          );
        default:
          return TextBlock(text: '[Unknown block type: $type]');
      }
    }).toList();

    final usage = json['usage'] as Map<String, dynamic>;

    return ClaudeResponse(
      id: json['id'] as String,
      content: content,
      stopReason: json['stop_reason'] as String?,
      usage: TokenUsage(
        inputTokens: usage['input_tokens'] as int,
        outputTokens: usage['output_tokens'] as int,
      ),
    );
  }

  final String id;
  final List<ContentBlock> content;
  final String? stopReason;
  final TokenUsage usage;

  /// Whether the model wants to use tools.
  bool get hasToolUse =>
      content.any((block) => block is ToolUseBlock);

  /// Gets all tool use blocks.
  List<ToolUseBlock> get toolUseBlocks =>
      content.whereType<ToolUseBlock>().toList();

  /// Gets the text content (if any).
  String get textContent => content
      .whereType<TextBlock>()
      .map((b) => b.text)
      .join('\n');

  /// Whether the model stopped naturally (no more tool calls).
  bool get isEndTurn => stopReason == 'end_turn';
}

/// Token usage from a Claude API response.
@immutable
class TokenUsage {
  const TokenUsage({
    required this.inputTokens,
    required this.outputTokens,
  });

  final int inputTokens;
  final int outputTokens;
}
