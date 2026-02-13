/// Tracks API usage costs during a chase run.
class CostTracker {
  int _inputTokens = 0;
  int _outputTokens = 0;
  int _apiCalls = 0;

  int get inputTokens => _inputTokens;
  int get outputTokens => _outputTokens;
  int get totalTokens => _inputTokens + _outputTokens;
  int get apiCalls => _apiCalls;

  /// Estimated cost in USD based on Claude pricing.
  double get estimatedCost {
    // Pricing as of 2025 for claude-sonnet-4-20250514:
    // Input: $3 / 1M tokens, Output: $15 / 1M tokens
    final inputCost = _inputTokens * 3.0 / 1000000;
    final outputCost = _outputTokens * 15.0 / 1000000;
    return inputCost + outputCost;
  }

  void recordUsage({
    required int inputTokens,
    required int outputTokens,
  }) {
    _inputTokens += inputTokens;
    _outputTokens += outputTokens;
    _apiCalls++;
  }

  /// Checks if the estimated cost exceeds the [maxCost] budget.
  bool isOverBudget(double maxCost) => estimatedCost > maxCost;

  /// Returns a formatted summary of the costs.
  String get summary {
    return 'API calls: $_apiCalls | '
        'Tokens: $_inputTokens in / $_outputTokens out | '
        'Est. cost: \$${estimatedCost.toStringAsFixed(4)}';
  }

  void reset() {
    _inputTokens = 0;
    _outputTokens = 0;
    _apiCalls = 0;
  }
}
