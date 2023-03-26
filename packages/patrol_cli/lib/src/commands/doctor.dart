import 'dart:io' as io;

import 'package:patrol_cli/src/base/constants.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:platform/platform.dart';

class DoctorCommand extends PatrolCommand {
  DoctorCommand({
    required PubspecReader pubspecReader,
    required Platform platform,
    required Logger logger,
  })  : _pubspecReader = pubspecReader,
        _platform = platform,
        _logger = logger;

  final PubspecReader _pubspecReader;
  final Platform _platform;

  final Logger _logger;

  @override
  String get name => 'doctor';

  @override
  String get description => 'Show information about installed tooling.';

  @override
  Future<int> run() async {
    _printVersion();
    _printAndroidSpecifics();

    if (_platform.isMacOS) {
      _printIosSpecifics();
    }

    _printProjectSpecifics();

    return 0;
  }

  void _printVersion() {
    _logger.info('Patrol CLI version: $version');
  }

  void _printAndroidSpecifics() {
    _checkIfToolInstalled('adb');

    final androidHome = _platform.environment['ANDROID_HOME'];
    if (androidHome?.isNotEmpty ?? false) {
      _logger.success('Env var \$ANDROID_HOME set to $androidHome');
    } else {
      _logger.err(r'Env var $ANDROID_HOME is not set');
    }
  }

  void _printIosSpecifics() {
    _checkIfToolInstalled('xcodebuild');
    _checkIfToolInstalled('ideviceinstaller', 'brew install ideviceinstaller');
    _checkIfToolInstalled('ios-deploy', 'brew install ios-deploy');
  }

  void _checkIfToolInstalled(String tool, [String? hint]) {
    final result = io.Platform.isWindows
        ? io.Process.runSync('where.exe', [tool])
        : io.Process.runSync('which', [tool]);
    if (result.exitCode == 0) {
      _logger.success('Program $tool found in ${result.stdOut.trim()}');
    } else {
      _logger.err(
        'Program $tool not found ${hint != null ? "(install with `$hint`)" : ""}',
      );
    }
  }

  void _printProjectSpecifics() {
    final pubspecConfig = _pubspecReader.read();
    _logger
      ..info('Patrol configuration in pubspec.yaml:')
      ..info('  Android')
      ..info('    package_name: ${pubspecConfig.android.packageName}')
      ..info('    app_name: ${pubspecConfig.android.appName}')
      ..info('    flavor: ${pubspecConfig.android.flavor}')
      ..info('  IOS')
      ..info('    bundle_id: ${pubspecConfig.ios.bundleId}')
      ..info('    app_name: ${pubspecConfig.ios.appName}')
      ..info('    flavor: ${pubspecConfig.ios.flavor}');
  }
}
