import '../claude_models.dart';

/// Abstract base class for AI agent tools.
abstract class AgentTool {
  /// The tool name as it appears in the Claude API.
  String get name;

  /// Description of what the tool does.
  String get description;

  /// JSON Schema for the tool's input parameters.
  Map<String, dynamic> get inputSchema;

  /// Executes the tool with the given [input] parameters.
  Future<String> execute(Map<String, dynamic> input);

  /// Converts this tool to a Claude API tool definition.
  ClaudeTool toClaudeTool() => ClaudeTool(
        name: name,
        description: description,
        inputSchema: inputSchema,
      );
}
