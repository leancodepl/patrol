/// AI-powered Patrol test generation for Flutter.
library chase;

// Config
export 'src/config/chase_config.dart';
export 'src/config/config_loader.dart';
export 'src/config/secrets.dart';

// Analyzer
export 'src/analyzer/diff_analyzer.dart';
export 'src/analyzer/diff_models.dart';
export 'src/analyzer/change_classifier.dart';
export 'src/analyzer/impact_scorer.dart';

// Context
export 'src/context/project_scanner.dart';
export 'src/context/test_mapper.dart';
export 'src/context/context_builder.dart';
export 'src/context/context_models.dart';

// Agent
export 'src/agent/chase_agent.dart';
export 'src/agent/claude_client.dart';
export 'src/agent/claude_models.dart';
export 'src/agent/conversation.dart';
export 'src/agent/tool_registry.dart';

// Runner
export 'src/runner/patrol_builder.dart';
export 'src/runner/local_validator.dart';
export 'src/runner/marathon_client.dart';
export 'src/runner/result_reporter.dart';

// Git
export 'src/git/git_client.dart';
export 'src/git/github_client.dart';
export 'src/git/pr_manager.dart';

// Utils
export 'src/utils/process_runner.dart';
export 'src/utils/token_counter.dart';
export 'src/utils/cost_tracker.dart';
