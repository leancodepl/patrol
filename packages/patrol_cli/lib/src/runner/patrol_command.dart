import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';

abstract class PatrolCommand extends Command<int> {
  /// Seconds to wait after the individual test case finishes executing.
  final defaultWait = 0;

  var _usesBuildOption = false;

  final _defaultTestServerPort = 8081;
  final _defaultAppServerPort = 8082;

  final defaultFailureMessage =
      'See the logs above to learn what happened. Also consider running with '
      "--verbose. If the logs still aren't useful, then it's a bug - please "
      'report it.';

  ArgResults? _argResultsOverride;

  @override
  ArgResults? get argResults => _argResultsOverride ?? super.argResults;

  set argResultsOverride(ArgResults? results) => _argResultsOverride = results;

  ArgResults? _globalResultsOverride;

  @override
  ArgResults? get globalResults =>
      _globalResultsOverride ?? super.globalResults;

  set globalResultsOverride(ArgResults? results) =>
      _globalResultsOverride = results;

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
        valueHelp: 'patrol_test/app_test.dart',
      )
      ..addMultiOption(
        'exclude',
        aliases: ['excludes'],
        help: 'Integration test targets to exclude.',
        valueHelp: 'patrol_test/flaky_test.dart',
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
          'Environment configuration from a provided path that will be available '
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
      ..addFlag(
        'full-isolation',
        help:
            '(Experimental) Uninstall the app between test runs on iOS Simulator to achieve full isolation.',
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

  void usesWeb() {
    argParser
      ..addOption(
        'web-results-dir',
        help: 'Directory where test results will be saved.',
        valueHelp: 'test-results',
      )
      ..addOption(
        'web-report-dir',
        help: 'Directory where test reports will be saved.',
        valueHelp: 'playwright-report',
      )
      ..addOption(
        'web-retries',
        help: 'Number of times to retry failed tests.',
        valueHelp: 'number',
      )
      ..addOption(
        'web-video',
        help: 'Video recording mode.',
        valueHelp: 'off | on | retain-on-failure | on-first-retry',
      )
      ..addOption(
        'web-timeout',
        help: 'Maximum time in milliseconds for single test execution.',
        valueHelp: 'number',
      )
      ..addOption(
        'web-workers',
        help: 'Maximum number of parallel worker processes for test execution.',
        valueHelp: 'number',
      )
      ..addOption(
        'web-reporter',
        help: 'Test reporters to use. JSON array of reporter names.',
        valueHelp: '\'["html", "json", "list"]\'',
      )
      ..addOption(
        'web-locale',
        help: 'Locale for browser emulation.',
        valueHelp: 'en-US | pl-PL',
      )
      ..addOption(
        'web-timezone',
        help: 'Timezone for browser emulation.',
        valueHelp: 'Europe/Paris',
      )
      ..addOption(
        'web-color-scheme',
        help: 'Preferred color scheme for browser emulation.',
        valueHelp: 'light | dark',
      )
      ..addOption(
        'web-geolocation',
        help:
            'Geolocation for browser context. JSON object with latitude and longitude.',
        valueHelp: '\'{"latitude": 51.5074, "longitude": -0.1278}\'',
      )
      ..addOption(
        'web-permissions',
        help:
            'Permissions to grant to the browser context. JSON array of permission names.',
        valueHelp: '\'["geolocation", ...]\'',
      )
      ..addOption(
        'web-user-agent',
        help: 'Custom user agent string for browser context.',
        valueHelp: 'user agent string',
      )
      ..addOption(
        'web-viewport',
        help:
            'Viewport size for browser context. JSON object with width and height.',
        valueHelp: '\'{"width": 1920, "height": 1080}\'',
      )
      ..addOption(
        'web-global-timeout',
        help: 'Maximum total time in milliseconds for the entire test run.',
        valueHelp: 'number',
      )
      ..addOption(
        'web-shard',
        help:
            'Shard tests and execute only the selected shard. '
            'Specify in the format "current/total" (e.g., "1/4" for the first of 4 shards).',
        valueHelp: '1/4',
      )
      ..addOption(
        'web-headless',
        help: 'Whether to run browser in headless mode.',
        valueHelp: 'true | false',
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
}
