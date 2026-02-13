import 'package:chase/src/utils/cost_tracker.dart';
import 'package:test/test.dart';

void main() {
  group('CostTracker', () {
    late CostTracker tracker;

    setUp(() {
      tracker = CostTracker();
    });

    test('starts at zero', () {
      expect(tracker.inputTokens, 0);
      expect(tracker.outputTokens, 0);
      expect(tracker.totalTokens, 0);
      expect(tracker.apiCalls, 0);
      expect(tracker.estimatedCost, 0.0);
    });

    test('records usage', () {
      tracker.recordUsage(inputTokens: 1000, outputTokens: 500);

      expect(tracker.inputTokens, 1000);
      expect(tracker.outputTokens, 500);
      expect(tracker.totalTokens, 1500);
      expect(tracker.apiCalls, 1);
    });

    test('accumulates usage across calls', () {
      tracker.recordUsage(inputTokens: 1000, outputTokens: 500);
      tracker.recordUsage(inputTokens: 2000, outputTokens: 1000);

      expect(tracker.inputTokens, 3000);
      expect(tracker.outputTokens, 1500);
      expect(tracker.apiCalls, 2);
    });

    test('calculates estimated cost', () {
      // 1M input tokens = $3, 1M output tokens = $15
      tracker.recordUsage(inputTokens: 1000000, outputTokens: 0);
      expect(tracker.estimatedCost, closeTo(3.0, 0.01));

      tracker.reset();
      tracker.recordUsage(inputTokens: 0, outputTokens: 1000000);
      expect(tracker.estimatedCost, closeTo(15.0, 0.01));
    });

    test('checks budget correctly', () {
      tracker.recordUsage(inputTokens: 100000, outputTokens: 30000);
      // Cost = 0.3 + 0.45 = 0.75

      expect(tracker.isOverBudget(1.0), isFalse);
      expect(tracker.isOverBudget(0.5), isTrue);
    });

    test('provides formatted summary', () {
      tracker.recordUsage(inputTokens: 5000, outputTokens: 1000);

      final summary = tracker.summary;

      expect(summary, contains('API calls: 1'));
      expect(summary, contains('5000 in'));
      expect(summary, contains('1000 out'));
      expect(summary, contains('\$'));
    });

    test('resets correctly', () {
      tracker.recordUsage(inputTokens: 1000, outputTokens: 500);
      tracker.reset();

      expect(tracker.inputTokens, 0);
      expect(tracker.outputTokens, 0);
      expect(tracker.apiCalls, 0);
    });
  });
}
