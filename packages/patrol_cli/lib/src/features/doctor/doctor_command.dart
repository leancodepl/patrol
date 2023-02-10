import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:patrol_cli/src/common/constants.dart';
import 'package:patrol_cli/src/common/extensions/process.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:platform/platform.dart';

class DoctorCommand extends Command<int> {
  DoctorCommand({
    required Logger logger,
    required Platform platform,
  })  : _logger = logger,
        _platform = platform;

  final Logger _logger;
  final Platform _platform;

  @override
  String get name => 'doctor';

  @override
  String get description => 'Show information about the installed tooling.';

  @override
  Future<int> run() async {
    _printVersion();
    _printAndroidSpecifics();

    if (_platform.isMacOS) {
      _printIosSpecifics();
    }

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
}
