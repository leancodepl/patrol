import '../cli/common/cli_logger.dart';
import '../config/chase_config.dart';
import '../context/context_models.dart';
import '../utils/cost_tracker.dart';
import 'claude_client.dart';
import 'claude_models.dart';
import 'conversation.dart';
import 'prompts/generation_prompt.dart';
import 'prompts/system_prompt.dart';
import 'tool_registry.dart';
import 'tools/list_files_tool.dart';
import 'tools/read_file_tool.dart';
import 'tools/run_command_tool.dart';
import 'tools/search_code_tool.dart';
import 'tools/write_file_tool.dart';

/// Result of a test generation run.
class GenerationResult {
  const GenerationResult({
    required this.generatedFiles,
    required this.summary,
    required this.iterations,
  });

  final List<String> generatedFiles;
  final String summary;
  final int iterations;
}

/// Agentic loop orchestrator for AI-powered test generation.
///
/// Manages the conversation with Claude, dispatches tool calls,
/// and iterates until tests are generated and validated.
class ChaseAgent {
  ChaseAgent({
    required ChaseConfig config,
    required CostTracker costTracker,
    required CliLogger logger,
    ClaudeClient? claudeClient,
  })  : _config = config,
        _costTracker = costTracker,
        _logger = logger,
        _claudeClient = claudeClient ??
            ClaudeClient(apiKey: config.apiKeys.claude);

  final ChaseConfig _config;
  final CostTracker _costTracker;
  final CliLogger _logger;
  final ClaudeClient _claudeClient;

  /// Generates tests for the given context using the AI agent loop.
  Future<GenerationResult> generate({
    required AgentContext context,
    int? maxIterations,
  }) async {
    final iterations = maxIterations ?? _config.agent.maxIterations;
    final projectRoot = context.projectInfo.rootPath;

    // Set up tools
    final registry = ToolRegistry();
    final writeFileTool = WriteFileTool(
      projectRoot: projectRoot,
      testDirectory: _config.project.testDirectory,
    );

    registry.register(ReadFileTool(projectRoot: projectRoot));
    registry.register(writeFileTool);
    registry.register(ListFilesTool(projectRoot: projectRoot));
    registry.register(SearchCodeTool(projectRoot: projectRoot));
    registry.register(
      RunCommandTool(
        projectRoot: projectRoot,
        allowedCommands: _config.agent.allowedCommands,
      ),
    );

    // Build prompts
    final systemPrompt = buildSystemPrompt(
      projectName: context.projectInfo.name,
      stateManagement: context.projectInfo.stateManagement,
      router: context.projectInfo.router,
      patrolVersion: context.patrolVersion,
      customInstructions: _config.agent.customInstructions,
    );

    final userPrompt = buildGenerationPrompt(context);

    // Initialize conversation
    final conversation = Conversation();
    conversation.addUserMessage(userPrompt);

    var lastTextContent = '';

    // Agentic loop
    for (var i = 0; i < iterations; i++) {
      _logger.detail('Agent iteration ${i + 1}/$iterations');

      // Check budget
      if (_costTracker.isOverBudget(_config.agent.maxCostPerRun)) {
        _logger.warn(
          'Cost budget exceeded (\$${_costTracker.estimatedCost.toStringAsFixed(4)} > '
          '\$${_config.agent.maxCostPerRun}). Stopping agent.',
        );
        break;
      }

      // Check token budget
      if (conversation.isNearBudget) {
        _logger.warn('Approaching token budget. Stopping agent.');
        break;
      }

      // Send message to Claude
      final progress = _logger.progress('Agent thinking (iteration ${i + 1})');

      ClaudeResponse response;
      try {
        response = await _claudeClient.sendMessage(
          ClaudeRequest(
            model: _config.agent.model,
            system: systemPrompt,
            messages: conversation.messages,
            tools: registry.toolDefinitions,
            maxTokens: 4096,
            temperature: _config.agent.temperature,
          ),
        );
      } on ClaudeApiException catch (e) {
        progress.fail('API error');
        _logger.error('Claude API error: $e');
        break;
      }

      // Track usage
      _costTracker.recordUsage(
        inputTokens: response.usage.inputTokens,
        outputTokens: response.usage.outputTokens,
      );

      // Add assistant response to conversation
      conversation.addAssistantMessage(response.content);

      // Extract text content for summary
      if (response.textContent.isNotEmpty) {
        lastTextContent = response.textContent;
        _logger.detail(response.textContent);
      }

      // If no tool calls, we're done
      if (!response.hasToolUse) {
        progress.complete('Agent finished');
        break;
      }

      // Execute tool calls
      final toolResults = <ToolResultBlock>[];
      for (final toolUse in response.toolUseBlocks) {
        progress.update('Executing ${toolUse.name}');
        _logger.detail('Tool: ${toolUse.name}(${_summarizeInput(toolUse.input)})');

        final result = await registry.execute(toolUse.name, toolUse.input);
        toolResults.add(
          ToolResultBlock(
            toolUseId: toolUse.id,
            content: result,
          ),
        );
      }

      progress.complete('Iteration ${i + 1} complete');

      // Add tool results to conversation
      conversation.addToolResults(toolResults);
    }

    return GenerationResult(
      generatedFiles: writeFileTool.writtenFiles,
      summary: lastTextContent,
      iterations: conversation.messageCount ~/ 2,
    );
  }

  String _summarizeInput(Map<String, dynamic> input) {
    final parts = <String>[];
    for (final entry in input.entries) {
      final value = entry.value.toString();
      if (value.length > 50) {
        parts.add('${entry.key}: ${value.substring(0, 50)}...');
      } else {
        parts.add('${entry.key}: $value');
      }
    }
    return parts.join(', ');
  }
}
