import '../utils/token_counter.dart';
import 'claude_models.dart';

/// Manages conversation history and token tracking for the AI agent.
class Conversation {
  Conversation({this.maxTokenBudget = 180000});

  final int maxTokenBudget;
  final List<ClaudeMessage> _messages = [];
  final _tokenCounter = const TokenCounter();

  List<ClaudeMessage> get messages => List.unmodifiable(_messages);

  int get messageCount => _messages.length;

  /// Adds a user message with text content.
  void addUserMessage(String text) {
    _messages.add(ClaudeMessage(role: 'user', content: text));
  }

  /// Adds a user message with tool results.
  void addToolResults(List<ToolResultBlock> results) {
    _messages.add(
      ClaudeMessage(
        role: 'user',
        content: results,
      ),
    );
  }

  /// Adds an assistant message (the raw content from Claude's response).
  void addAssistantMessage(List<ContentBlock> content) {
    _messages.add(
      ClaudeMessage(
        role: 'assistant',
        content: content,
      ),
    );
  }

  /// Estimates the total token count of the conversation.
  int get estimatedTokens {
    var total = 0;
    for (final message in _messages) {
      if (message.content is String) {
        total += _tokenCounter.estimate(message.content as String);
      } else if (message.content is List) {
        for (final block in message.content as List) {
          if (block is TextBlock) {
            total += _tokenCounter.estimate(block.text);
          } else if (block is ToolResultBlock) {
            total += _tokenCounter.estimate(block.content);
          } else if (block is ToolUseBlock) {
            total += _tokenCounter.estimate(block.input.toString());
          }
        }
      }
      total += 4; // Message overhead
    }
    return total;
  }

  /// Whether the conversation is approaching the token budget.
  bool get isNearBudget => estimatedTokens > maxTokenBudget * 0.85;

  /// Clears the conversation history.
  void clear() => _messages.clear();
}
