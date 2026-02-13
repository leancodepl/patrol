import 'claude_models.dart';
import 'tools/agent_tool.dart';

/// Registers and dispatches agent tools.
class ToolRegistry {
  final Map<String, AgentTool> _tools = {};

  /// Registers a tool.
  void register(AgentTool tool) {
    _tools[tool.name] = tool;
  }

  /// Gets the Claude API tool definitions for all registered tools.
  List<ClaudeTool> get toolDefinitions =>
      _tools.values.map((t) => t.toClaudeTool()).toList();

  /// Executes a tool call and returns the result.
  Future<String> execute(String toolName, Map<String, dynamic> input) async {
    final tool = _tools[toolName];
    if (tool == null) {
      return 'Error: Unknown tool "$toolName". '
          'Available tools: ${_tools.keys.join(', ')}';
    }
    return tool.execute(input);
  }

  /// Gets a registered tool by name.
  AgentTool? getTool(String name) => _tools[name];
}
