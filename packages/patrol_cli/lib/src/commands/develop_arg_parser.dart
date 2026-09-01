import 'package:patrol_cli/src/runner/patrol_command.dart';

/// Configures all options used by `patrol develop`.
///
/// This is shared by:
/// - `DevelopCommand` runtime CLI parsing
/// - `DevelopOptions.parseArgs` for programmatic callers (e.g. MCP)
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
    ..usesAppNameOption()
    ..usesAndroidOptions()
    ..usesIOSOptions()
    ..usesVideoRecordingOptions();

  command.argParser.addOption(
    'use-prebuilt-apks',
    help:
        'Android only. Directory with the app APK and the androidTest APK '
        'built elsewhere with `patrol build android --develop`. Skips the '
        'Gradle build entirely: installs both APKs, starts the Patrol '
        'instrumentation with `am instrument` and attaches for Hot Restart.',
    valueHelp: 'path/to/apks',
  );

  command.argParser.addFlag(
    'open-devtools',
    help: 'Automatically open Patrol extension in DevTools when ready.',
  );
}
