import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/compatibility_checker/version_compatibility.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:version/version.dart';

abstract class PatrolCommand extends Command<int> {
  final pubUpdater = PubUpdater();

  /// Seconds to wait after the individual test case finishes executing.
  final defaultWait = 0;

  var _usesBuildOption = false;

  final _defaultTestServerPort = 8081;
  final _defaultAppServerPort = 8082;

  final defaultFailureMessage =
      'See the logs above to learn what happened. Also consider running with '
      "--verbose. If the logs still aren't useful, then it's a bug - please "
      'report it.';

  // Common options

  /// Defines common inputs for commands that build.
  ///
  /// A command that expects only one target but got more should throw.
  void usesTargetOption() {
    argParser
      ..addMultiOption(
        'target',
        aliases: ['targets'],
        abbr: 't',
        help: 'Integration test target to use as entrypoint.',
        valueHelp: 'integration_test/app_test.dart',
      )
      ..addMultiOption(
        'exclude',
        aliases: ['excludes'],
        help: 'Integration test targets to exclude.',
        valueHelp: 'integration_test/flaky_test.dart',
      )
      ..addFlag(
        'generate-bundle',
        defaultsTo: true,
        help: 'Whether to generate a bundled Dart test file.',
      );
  }

  /// A command that expects only one device but got more should throw.
  void usesDeviceOption() {
    argParser.addMultiOption(
      'device',
      aliases: ['devices'],
      abbr: 'd',
      help: 'Devices to run the tests on. If empty, the first device is used.',
      valueHelp: "all, emulator-5554, 'iPhone 14'",
    );
  }

  void usesBuildModeOption() {
    _usesBuildOption = true;
    argParser
      ..addFlag(
        'debug',
        help: 'Build a debug version of your app (default mode)',
      )
      ..addFlag(
        'profile',
        help: 'Build a version of your app for performance profiling.',
      )
      ..addFlag('release', help: 'Build a release version of your app');
  }

  void usesFlavorOption() {
    argParser.addOption('flavor', help: 'Flavor of the app to run.');
  }

  void usesLabelOption() {
    argParser.addFlag(
      'label',
      help: 'Display the label over the application under test.',
      defaultsTo: true,
    );
  }

  void usesDartDefineOption() {
    argParser.addMultiOption(
      'dart-define',
      aliases: ['dart-defines'],
      help:
          'Additional key-value pairs that will be available to the app '
          'under test.',
      valueHelp: 'KEY=VALUE',
    );
  }

  void usesPortOptions() {
    argParser
      ..addOption(
        'test-server-port',
        help: 'Port to use for server running in the test instrumentation app.',
        defaultsTo: _defaultTestServerPort.toString(),
      )
      ..addOption(
        'app-server-port',
        help: 'Port to use for server running in the app under test.',
        defaultsTo: _defaultAppServerPort.toString(),
      );
  }

  void usesDartDefineFromFileOption() {
    argParser.addMultiOption(
      'dart-define-from-file',
      help:
          'Environment configuration from a provided path that will be available'
          'to the app under test.',
      valueHelp: 'config/test.json',
    );
  }

  void usesTagsOption() {
    argParser.addOption(
      'tags',
      help: 'Tags to filter the tests by.',
      valueHelp: '(chrome || firefox) && !slow',
    );
  }

  void usesExcludeTagsOption() {
    argParser.addOption(
      'exclude-tags',
      help: 'Tags to exclude the tests by.',
      valueHelp: 'safari',
    );
  }

  void usesAndroidOptions() {
    argParser.addOption(
      'package-name',
      help: 'Package name of the Android app under test.',
      valueHelp: 'pl.leancode.awesomeapp',
    );
  }

  void usesIOSOptions() {
    argParser
      ..addOption(
        'bundle-id',
        help: 'Bundle identifier of the iOS app under test.',
        valueHelp: 'pl.leancode.AwesomeApp',
      )
      ..addFlag(
        'clear-permissions',
        help:
            'Clear permissions available through XCUIProtectedResource API before running each test.',
        negatable: false,
      )
      ..addOption(
        'ios',
        help:
            'Pass iOS version. If empty, `latest` will be used. This flag only works with iOS simulator.',
        valueHelp: '17.5',
      );
  }

  void usesMacOSOptions() {
    argParser.addOption(
      'bundle-id',
      help: 'Bundle identifier of the MacOS app under test.',
      valueHelp: 'pl.leancode.macos.AwesomeApp',
    );
  }

  // Runtime-only options

  void usesUninstallOption() {
    argParser.addFlag(
      'uninstall',
      help: 'Uninstall the app before and after the test finishes.',
      defaultsTo: true,
    );
  }

  void usesShowFlutterLogs() {
    argParser.addFlag(
      'show-flutter-logs',
      help: 'Show Flutter logs while running the tests.',
    );
  }

  void usesHideTestSteps() {
    argParser.addFlag(
      'hide-test-steps',
      help: 'Hide test steps while running the tests.',
    );
  }

  void usesClearTestSteps() {
    argParser.addFlag(
      'clear-test-steps',
      help: 'Clear test steps after the test finishes.',
      defaultsTo: true,
    );
  }

  void usesCheckCompatibilityOption() {
    argParser.addFlag(
      'check-compatibility',
      defaultsTo: true,
      help: 'Verify if the dependencies are compatible between each other.',
    );
  }

  void usesBuildNameOption() {
    argParser.addOption(
      'build-name',
      help: 'Version name of the app.',
      valueHelp: '1.2.3',
    );
  }

  void usesBuildNumberOption() {
    argParser.addOption(
      'build-number',
      help: 'Version code of the app.',
      valueHelp: '123',
    );
  }

  /// Gets the parsed command-line flag named [name] as a `bool`.
  ///
  /// If no flag named [name] was added to the `ArgParser`, an [ArgumentError]
  /// will be thrown.
  bool boolArg(String name) => argResults![name] as bool;

  /// Gets the parsed command-line option named [name] as a `String`.
  ///
  /// If no option named [name] was added to the `ArgParser`, an [ArgumentError]
  /// will be thrown.
  String? stringArg(String name) => argResults![name] as String?;

  /// Gets the parsed command-line option named [name] as an `int`.
  int? intArg(String name) {
    final value = stringArg(name);
    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }

  /// Gets the parsed command-line option named [name] as `List<String>`.
  List<String> stringsArg(String name) {
    return argResults![name]! as List<String>? ?? <String>[];
  }

  FlutterCommand get flutterCommand {
    final arg = globalResults?['flutter-command'] as String?;

    var cmd = arg;
    if (cmd == null || cmd.isEmpty) {
      cmd = Platform.environment['PATROL_FLUTTER_COMMAND'];
    }

    if (cmd == null || cmd.isEmpty) {
      cmd = 'flutter';
    }

    return FlutterCommand.parse(cmd);
  }

  BuildMode get buildMode {
    if (!_usesBuildOption) {
      // If this happens, it's a developer fault, not the user's.
      throw StateError('This command does not support build mode option');
    }

    final buildModes = {
      if (boolArg('debug')) BuildMode.debug,
      if (boolArg('profile')) BuildMode.profile,
      if (boolArg('release')) BuildMode.release,
    };
    if (buildModes.isEmpty) {
      buildModes.add(BuildMode.debug);
    }

    if (buildModes.length > 1) {
      throwToolExit('Only one build mode can be specified');
    }

    return buildModes.single;
  }

  int get appServerPort {
    final port = intArg('app-server-port');
    if (port == null) {
      throw StateError('Command tried to use appServerPort but it is null');
    }
    return port;
  }

  int get testServerPort {
    final port = intArg('test-server-port');
    if (port == null) {
      throw StateError('Command tried to use testServerPort but it is null');
    }
    return port;
  }

  /// The name of the command in the online docs (https://patrol.leancode.co),
  /// if different than [name].
  String? get docsName => name;

  @override
  String? get usageFooter {
    return 'Read detailed docs at https://patrol.leancode.co/cli-commands/$docsName';
  }

  Future<void> checkForUpdates({
    required String currentVersion,
    required String latestVersion,
    required CompatibilityChecker compatibilityChecker,
    required Logger logger,
  }) async {
    final currentVersionParsed = Version.parse(currentVersion);
    final latestVersionParsed = Version.parse(latestVersion);

    final patrolVersion = await compatibilityChecker.getPatrolVersion(
      flutterCommand: flutterCommand,
    );

    // Parse patrol version if available
    final patrolVer = patrolVersion != null
        ? Version.parse(patrolVersion)
        : null;

    // Check for incompatibility first
    if (patrolVer != null) {
      final isCompatible = areVersionsCompatible(
        currentVersionParsed,
        patrolVer,
      );

      if (!isCompatible) {
        final maxCliVersion = getMaxCompatibleCliVersion(patrolVer);
        final versionInfo =
            'patrol_cli ${lightCyan.wrap(currentVersion)} is not compatible with patrol ${lightCyan.wrap(patrolVersion)}.';

        final command = maxCliVersion != null
            ? 'dart pub global activate patrol_cli $maxCliVersion'
            : null;

        final actionMessage = maxCliVersion != null
            ? 'To resolve this issue, ${currentVersionParsed < maxCliVersion ? "upgrade" : "downgrade"} patrol_cli to a compatible version:'
            : 'Please upgrade both "patrol_cli" and "patrol" dependencies to the latest versions.';

        _showVersionMessage(
          title: lightYellow.wrap('Version incompatibility detected!') ?? '',
          versionInfo: versionInfo,
          actionMessage: actionMessage,
          command: command,
          logger: logger,
        );
        return;
      }
    }

    // No update available
    if (latestVersionParsed <= currentVersionParsed) {
      return;
    }

    // Determine if we should show update notification and which message
    if (patrolVer != null) {
      final maxCliVersion = getMaxCompatibleCliVersion(patrolVer);

      // Already at max compatible version for this patrol version
      if (maxCliVersion != null && currentVersionParsed >= maxCliVersion) {
        return;
      }

      // Show constrained update message if latest is incompatible
      if (maxCliVersion != null && latestVersionParsed > maxCliVersion) {
        _showVersionMessage(
          title: lightYellow.wrap('Update available!') ?? '',
          versionInfo:
              '${lightCyan.wrap(currentVersion)} \u2192 ${lightCyan.wrap(maxCliVersion.toString())}',
          actionMessage: 'To update to the latest compatible version, run:',
          command: 'dart pub global activate patrol_cli $maxCliVersion',
          additionalWarning:
              "⚠️  Newest patrol_cli $latestVersion is not compatible with your project's patrol version.\nConsider upgrading your patrol package for the latest features.",
          logger: logger,
        );
        return;
      }
    }

    // Show simple update message
    _showVersionMessage(
      title: lightYellow.wrap('Update available!') ?? '',
      versionInfo:
          '${lightCyan.wrap(currentVersion)} \u2192 ${lightCyan.wrap(latestVersion)}',
      actionMessage: 'Run ${lightCyan.wrap('patrol update')} to update.',
      logger: logger,
    );
  }

  void _showVersionMessage({
    required String title,
    required String versionInfo,
    required Logger logger,
    String? actionMessage,
    String? command,
    String? additionalWarning,
  }) {
    final buffer = StringBuffer()
      ..writeln('$title $versionInfo')
      ..writeln();

    if (command != null) {
      if (actionMessage != null) {
        buffer.writeln(actionMessage);
      }
      buffer
        ..writeln(lightCyan.wrap(command))
        ..writeln();
    }

    if (additionalWarning != null) {
      buffer
        ..writeln(additionalWarning)
        ..writeln();
    }

    buffer.writeln(
      'Check the compatibility table at: ${lightCyan.wrap('https://patrol.leancode.co/documentation/compatibility-table')}',
    );

    logger
      ..info('')
      ..info(buffer.toString())
      ..info('');
  }
}
