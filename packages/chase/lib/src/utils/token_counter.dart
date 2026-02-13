/// Approximate token counting for Claude API budget management.
///
/// Uses a simple heuristic: ~4 characters per token for English text,
/// adjusted for code which tends to be more token-dense.
class TokenCounter {
  const TokenCounter();

  /// Estimates the number of tokens in [text].
  ///
  /// This is a rough approximation. Claude's actual tokenizer may differ.
  int estimate(String text) {
    if (text.isEmpty) return 0;

    // Rough heuristic: ~3.5 chars per token for code, ~4 for prose.
    // We use 3.7 as a middle ground since we deal with mixed content.
    return (text.length / 3.7).ceil();
  }

  /// Estimates tokens for a list of messages.
  int estimateMessages(List<Map<String, dynamic>> messages) {
    var total = 0;
    for (final message in messages) {
      final content = message['content'];
      if (content is String) {
        total += estimate(content);
      } else if (content is List) {
        for (final block in content) {
          if (block is Map && block['type'] == 'text') {
            total += estimate(block['text'] as String? ?? '');
          }
        }
      }
      // Add overhead per message for role tokens etc.
      total += 4;
    }
    return total;
  }

  /// Trims [text] to fit within [maxTokens] approximately.
  String trimToFit(String text, int maxTokens) {
    final estimated = estimate(text);
    if (estimated <= maxTokens) return text;

    final targetChars = (maxTokens * 3.7).floor();
    if (targetChars >= text.length) return text;

    return '${text.substring(0, targetChars)}\n\n[... truncated to fit token budget ...]';
  }
}
