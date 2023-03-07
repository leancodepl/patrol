import 'package:args/command_runner.dart';

abstract class PatrolCommand extends Command<int> {
  final defaultScheme = 'Runner';
  final defaultXCConfigFile = 'Flutter/Debug.xcconfig';
  final defaultConfiguration = 'Debug';
  final defaultWait = 0;
  final defaultRepeatCount = 1;

  final defaultFailureMessage =
      'See the logs above to learn what happened. Also consider running with '
      "--verbose. If the logs still aren't useful, then it's a bug - please "
      'report it.';

  // Common options

  /// A command that expects only one target got more should throw.
  void usesTargetOption() {
    argParser.addMultiOption(
      'target',
      aliases: ['targets'],
      abbr: 't',
      help: 'Integration test to use as entrypoint.',
      valueHelp: 'integration_test/app_test.dart',
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

  void usesFlavorOption() {
    argParser.addOption(
      'flavor',
      help: 'Flavor of the app to run.',
    );
  }

  void usesLabelOption() {
    argParser.addFlag(
      'label',
      help: 'Display the label over the application under test.',
      defaultsTo: true,
    );
  }

  void usesWaitOption() {
    argParser.addOption(
      'wait',
      help: 'Seconds to wait after the test finishes.',
      defaultsTo: '0',
    );
  }

  void usesDartDefineOption() {
    argParser.addMultiOption(
      'dart-define',
      aliases: ['dart-defines'],
      help: 'Additional key-value pairs that will be available to the app '
          'under test.',
      valueHelp: 'KEY=VALUE',
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
      ..addOption(
        'scheme',
        help: '(iOS only) Xcode scheme to use',
        defaultsTo: defaultScheme,
      )
      ..addOption(
        'xcconfig',
        help: '(iOS only) Xcode .xcconfig file to use',
        defaultsTo: defaultXCConfigFile,
      )
      ..addOption(
        'configuration',
        help: '(iOS only) Xcode configuration to use',
        defaultsTo: defaultConfiguration,
      );
  }

  // Runtime-only options

  void usesRepeatOption() {
    argParser.addOption(
      'repeat',
      abbr: 'n',
      help: 'Repeat the test n times.',
      defaultsTo: '$defaultRepeatCount',
    );
  }

  void usesUninstallOption() {
    argParser.addFlag(
      'uninstall',
      help: 'Uninstall the app after the test finishes.',
      defaultsTo: true,
    );
  }

  /// Gets the parsed command-line option named [name] as a `bool?`.
  bool? boolArg(String name) {
    if (!argParser.options.containsKey(name)) {
      return null;
    }
    return argResults![name] as bool;
  }

  String? stringArg(String name) {
    if (!argParser.options.containsKey(name)) {
      return null;
    }
    return argResults![name] as String?;
  }

  /// Gets the parsed command-line option named [name] as an `int`.
  int? intArg(String name) {
    if (!argParser.options.containsKey(name)) {
      return null;
    }

    final value = argResults![name] as String?;
    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }

  /// Gets the parsed command-line option named [name] as `List<String>`.
  List<String> stringsArg(String name) {
    return argResults![name]! as List<String>? ?? <String>[];
  }
}
