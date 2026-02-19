import 'package:patrol_cli/src/runner/patrol_command.dart';

/// Configures all options used by `patrol develop`.
///
/// This is shared by:
/// - `DevelopCommand` runtime CLI parsing
/// - `DevelopOptions.fromArgs` for programmatic callers (e.g. MCP)
void configureDevelopArgParser(PatrolCommand command) {
  command
    ..usesTargetOption()
    ..usesDeviceOption()
    ..usesBuildModeOption()
    ..usesFlavorOption()
    ..usesDartDefineOption()
    ..usesDartDefineFromFileOption()
    ..usesLabelOption()
    ..usesPortOptions()
    ..usesTagsOption()
    ..usesHideTestSteps()
    ..usesClearTestSteps()
    ..usesCheckCompatibilityOption()
    ..usesUninstallOption()
    ..usesBuildNameOption()
    ..usesBuildNumberOption()
    ..usesAndroidOptions()
    ..usesIOSOptions();

  command.argParser.addFlag(
    'open-devtools',
    help: 'Automatically open Patrol extension in DevTools when ready.',
  );
}
