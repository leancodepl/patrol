import '../../context/context_models.dart';

/// Builds the user message for the AI agent with diff and context.
String buildGenerationPrompt(AgentContext context) {
  final buffer = StringBuffer()
    ..writeln('## Code Changes to Test')
    ..writeln()
    ..writeln('The following files have been changed and need Patrol integration tests:')
    ..writeln();

  // List prioritized changes
  for (final change in context.prioritizedChanges) {
    final category = change.category.name;
    final type = change.file.changeType.name;
    final score = change.score.toStringAsFixed(2);
    buffer.writeln(
      '- **${change.file.path}** ($type, category: $category, priority: $score)',
    );

    if (change.existingTestPath != null) {
      buffer.writeln('  - Existing test: ${change.existingTestPath}');
    }
  }

  // Include the raw diff
  buffer
    ..writeln()
    ..writeln('## Raw Diff')
    ..writeln()
    ..writeln('```diff')
    ..writeln(_truncateDiff(context.diffResult.rawDiff))
    ..writeln('```');

  // Existing tests info
  if (context.existingTests.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Existing Patrol Tests')
      ..writeln();

    for (final test in context.existingTests) {
      buffer.writeln('- ${test.path}');
      if (test.sourceFilePath != null) {
        buffer.writeln('  → tests: ${test.sourceFilePath}');
      }
    }
  }

  // Instructions
  buffer
    ..writeln()
    ..writeln('## Instructions')
    ..writeln()
    ..writeln('1. Start by reading the changed source files to understand what was changed.')
    ..writeln('2. Check if there are existing tests that need updating.')
    ..writeln('3. Plan which tests to create or update.')
    ..writeln('4. Write the test files using write_test_file.')
    ..writeln('5. Run `dart analyze integration_test/` to validate.')
    ..writeln('6. Fix any issues found by the analyzer.')
    ..writeln('7. Provide a summary of what you created.');

  return buffer.toString();
}

String _truncateDiff(String diff) {
  // Limit diff to ~30k characters to leave room for other context
  if (diff.length <= 30000) return diff;
  return '${diff.substring(0, 30000)}\n\n[... diff truncated ...]';
}
