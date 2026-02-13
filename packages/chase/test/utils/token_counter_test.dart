import 'package:chase/src/utils/token_counter.dart';
import 'package:test/test.dart';

void main() {
  group('TokenCounter', () {
    const counter = TokenCounter();

    test('returns 0 for empty string', () {
      expect(counter.estimate(''), 0);
    });

    test('estimates tokens for short text', () {
      final tokens = counter.estimate('Hello world');
      expect(tokens, greaterThan(0));
      expect(tokens, lessThan(10));
    });

    test('estimates tokens for longer text', () {
      final text = 'word ' * 100; // 500 chars
      final tokens = counter.estimate(text);
      // ~500 / 3.7 ≈ 135
      expect(tokens, greaterThan(100));
      expect(tokens, lessThan(200));
    });

    test('trims text to fit budget', () {
      final longText = 'x' * 10000;
      final trimmed = counter.trimToFit(longText, 100);

      expect(trimmed.length, lessThan(longText.length));
      expect(trimmed, contains('truncated'));
    });

    test('does not trim text within budget', () {
      const shortText = 'Hello world';
      final result = counter.trimToFit(shortText, 1000);

      expect(result, shortText);
    });

    test('estimates messages with overhead', () {
      final messages = [
        {'role': 'user', 'content': 'Hello'},
        {'role': 'assistant', 'content': 'Hi there'},
      ];

      final tokens = counter.estimateMessages(messages);
      // Should be greater than just the text estimates due to overhead
      expect(tokens, greaterThan(0));
    });
  });
}
