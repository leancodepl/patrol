import 'package:chase/src/agent/claude_models.dart';
import 'package:chase/src/agent/conversation.dart';
import 'package:test/test.dart';

void main() {
  group('Conversation', () {
    late Conversation conversation;

    setUp(() {
      conversation = Conversation(maxTokenBudget: 1000);
    });

    test('starts empty', () {
      expect(conversation.messages, isEmpty);
      expect(conversation.messageCount, 0);
    });

    test('adds user messages', () {
      conversation.addUserMessage('Hello');

      expect(conversation.messageCount, 1);
      expect(conversation.messages.first.role, 'user');
      expect(conversation.messages.first.content, 'Hello');
    });

    test('adds assistant messages', () {
      conversation.addAssistantMessage([
        TextBlock(text: 'I will help you.'),
      ]);

      expect(conversation.messageCount, 1);
      expect(conversation.messages.first.role, 'assistant');
    });

    test('adds tool results', () {
      conversation.addToolResults([
        ToolResultBlock(toolUseId: 'tu_1', content: 'file contents'),
      ]);

      expect(conversation.messageCount, 1);
      expect(conversation.messages.first.role, 'user');
    });

    test('estimates tokens', () {
      conversation.addUserMessage('Hello, this is a test message.');
      expect(conversation.estimatedTokens, greaterThan(0));
    });

    test('detects near budget', () {
      // Add a large message to exceed 85% of the 1000 token budget (850 tokens)
      // ~3200 chars / 3.7 ≈ 865 tokens + 4 overhead = ~869 > 850
      final largeText = 'word ' * 640;
      conversation.addUserMessage(largeText);

      expect(conversation.isNearBudget, isTrue);
    });

    test('clears messages', () {
      conversation.addUserMessage('Hello');
      conversation.addUserMessage('World');

      conversation.clear();

      expect(conversation.messages, isEmpty);
      expect(conversation.messageCount, 0);
    });
  });
}
