import 'package:args/args.dart';
import 'package:patrol_cli/src/commands/develop_arg_parser.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

/// Configuration options for a patrol develop session.
///
/// This data class decouples the orchestration logic from CLI arg parsing,
/// allowing both the CLI and MCP server to drive a develop session.
class DevelopOptions {
  const DevelopOptions({
    required this.target,
    required this.flutterCommand,
    required this.buildMode,
    required this.testServerPort,
    required this.appServerPort,
    this.flavor,
    this.packageName,
    this.bundleId,
    this.buildName,
    this.buildNumber,
    this.devices = const [],
    this.dartDefines = const [],
    this.dartDefineFromFilePaths = const [],
    this.generateBundle = true,
    this.uninstall = true,
    this.displayLabel = true,
    this.openDevtools = false,
    this.hideTestSteps = false,
    this.clearTestSteps = true,
    this.checkCompatibility = true,
    this.iosVersion,
  });

  factory DevelopOptions.fromArgResults(
    ArgResults results, {
    required String target,
    FlutterCommand? flutterCommand,
  }) {
    final buildModes = {
      if (results['debug'] case true) BuildMode.debug,
      if (results['profile'] case true) BuildMode.profile,
      if (results['release'] case true) BuildMode.release,
    };
    if (buildModes.length > 1) {
      throw ArgumentError('Only one build mode can be specified');
    }
    if (buildModes.isEmpty) {
      buildModes.add(BuildMode.debug);
    }

    return DevelopOptions(
      target: target,
      flutterCommand: flutterCommand ?? const FlutterCommand('flutter'),
      buildMode: buildModes.first,
      testServerPort: int.parse(results['test-server-port'] as String),
      appServerPort: int.parse(results['app-server-port'] as String),
      flavor: results['flavor'] as String?,
      packageName: results['package-name'] as String?,
      bundleId: results['bundle-id'] as String?,
      buildName: results['build-name'] as String?,
      buildNumber: results['build-number'] as String?,
      devices: (results['device'] as List<String>?) ?? const [],
      dartDefines: (results['dart-define'] as List<String>?) ?? const [],
      dartDefineFromFilePaths:
          (results['dart-define-from-file'] as List<String>?) ?? const [],
      generateBundle: results['generate-bundle'] as bool,
      uninstall: results['uninstall'] as bool,
      displayLabel: results['label'] as bool,
      openDevtools: results['open-devtools'] as bool,
      hideTestSteps: results['hide-test-steps'] as bool,
      clearTestSteps: results['clear-test-steps'] as bool,
      checkCompatibility: results['check-compatibility'] as bool,
      iosVersion: results['ios'] as String?,
    );
  }

  /// Parses a list of CLI-style flag strings into [DevelopOptions] and the
  /// full [ArgResults].
  ///
  /// Uses an [ArgParser] with the same option names and defaults as the
  /// `patrol develop` CLI command, plus global flags (e.g. `--verbose`,
  /// `--flutter-command`) that are normally handled by the CLI runner.
  /// This is the entry point for non-CLI callers (e.g. the MCP server) that
  /// receive all flags as a flat string.
  ///
  /// [args] are the flag strings (e.g. `['--flavor', 'dev', '--verbose']`).
  /// [target] is the test file path (required, passed separately).
  /// [flutterCommand] is a fallback; `--flutter-command` in [args] takes
  /// precedence if present.
  ///
  /// Returns a record of ([DevelopOptions], [ArgResults]) so that callers can
  /// inspect global flags (e.g. `verbose`) from the same parse pass.
  static (DevelopOptions, ArgResults) parseArgs(
    List<String> args, {
    required String target,
    FlutterCommand? flutterCommand,
  }) {
    final parserCommand = _DevelopOptionsParserCommand();
    configureDevelopArgParser(parserCommand);
    // Also accept global flags that are relevant to develop sessions.
    // In the CLI these live on the runner's parser, but non-CLI callers
    // (e.g. MCP) pass all flags flat so the parser must know about them.
    addGlobalFlags(parserCommand.argParser);
    final results = parserCommand.argParser.parse(args);

    // --flutter-command from args takes precedence over the parameter.
    final parsedFlutterCmd = results['flutter-command'] as String?;
    final effectiveFlutterCmd =
        parsedFlutterCmd != null && parsedFlutterCmd.isNotEmpty
            ? FlutterCommand.parse(parsedFlutterCmd)
            : flutterCommand;

    final options = DevelopOptions.fromArgResults(
      results,
      target: target,
      flutterCommand: effectiveFlutterCmd,
    );
    return (options, results);
  }

  final String target;
  final FlutterCommand flutterCommand;
  final BuildMode buildMode;
  final int testServerPort;
  final int appServerPort;

  final String? flavor;
  final String? packageName;
  final String? bundleId;
  final String? buildName;
  final String? buildNumber;

  /// Device names/ids to use. Empty means auto-select first device.
  final List<String> devices;

  /// Custom dart defines from --dart-define args (key=value format).
  final List<String> dartDefines;

  /// Paths to dart define files from --dart-define-from-file.
  final List<String> dartDefineFromFilePaths;

  final bool generateBundle;
  final bool uninstall;
  final bool displayLabel;
  final bool openDevtools;
  final bool hideTestSteps;
  final bool clearTestSteps;
  final bool checkCompatibility;

  /// iOS version for simulator. Defaults to 'latest' if null.
  final String? iosVersion;
}

class _DevelopOptionsParserCommand extends PatrolCommand {
  @override
  String get name => 'develop-options-parser';

  @override
  String get description => 'Internal parser holder for DevelopOptions';
}
