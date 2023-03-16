import 'package:args/command_runner.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';

abstract class PatrolCommand extends Command<int> {
  final defaultWait = 0;
  final defaultRepeatCount = 1;

  var _usesBuildOption = false;

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

  void usesBuildModeOption() {
    _usesBuildOption = true;
    argParser
      ..addFlag(
        'debug',
        help: 'Build a debug version of your app',
        defaultsTo: true,
      )
      ..addFlag(
        'profile',
        help: 'Build a version of your app for performance profiling.',
      )
      ..addFlag(
        'release',
        help: 'Build a release version of your app (default mode)',
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
    argParser.addOption(
      'bundle-id',
      help: 'Bundle identifier of the iOS app under test.',
      valueHelp: 'pl.leancode.AwesomeApp',
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

  BuildMode get buildMode {
    if (!_usesBuildOption) {
      throwToolExit('This command does not support build mode option');
    }

    final buildModes = {
      if (boolArg('debug')) BuildMode.debug,
      if (boolArg('profile')) BuildMode.profile,
      if (boolArg('release')) BuildMode.release,
    };

    if (buildModes.length > 1) {
      throwToolExit('Only one build mode can be specified.');
    }

    return buildModes.single;
  }
}
