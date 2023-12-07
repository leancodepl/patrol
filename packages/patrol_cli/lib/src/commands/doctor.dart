import 'dart:io' as io;

import 'package:patrol_cli/src/base/constants.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:platform/platform.dart';

class DoctorCommand extends PatrolCommand {
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
  String get description => 'Show information about installed tooling.';

  @override
  Future<int> run() async {
    _printHeader();
    _printVersion();
    _printAndroidSpecifics();

    if (_platform.isMacOS) {
      _printIosSpecifics();
    }

    return 0;
  }

  void _printHeader() {
    _logger.info('Patrol doctor:');
  }

  void _printVersion() {
    _logger.info('Patrol CLI version: $version');
  }

  void _printAndroidSpecifics() {
    _logger.info('Android: ');

    _checkIfToolInstalled(
      'adb',
      'See the link: https://www.xda-developers.com/install-adb-windows-macos-linux/#how-to-set-up-adb',
    );

    final androidHome = _platform.environment['ANDROID_HOME'];
    if (androidHome?.isNotEmpty ?? false) {
      _logger.success('• Env var \$ANDROID_HOME set to $androidHome');
    } else {
      final linkHint = switch (_platform.operatingSystem) {
        Platform.linux => 'https://stackoverflow.com/a/28889144/9899010',
        Platform.macOS => 'https://stackoverflow.com/a/33631853/9899010',
        Platform.windows =>
          'https://www.ibm.com/docs/en/rtw/10.5.1?topic=prwut-setting-changing-android-home-path-in-windows-operating-systems',
        _ => '',
      };
      _logger.err(
        '• Env var \$ANDROID_HOME is not set. (See the link: $linkHint)',
      );
    }
  }

  void _printIosSpecifics() {
    _logger.info('iOS / macOS: ');
    _checkIfToolInstalled('xcodebuild', 'Install Xcode on your Mac');
    _checkIfToolInstalled(
      'ideviceinstaller',
      _commandHint('brew install ideviceinstaller'),
    );
  }

  String _commandHint(String command) => 'install with `$command`';

  void _checkIfToolInstalled(String tool, [String? hint]) {
    final result = io.Platform.isWindows
        ? io.Process.runSync('where.exe', [tool])
        : io.Process.runSync('which', [tool]);
    if (result.exitCode == 0) {
      _logger.success('• Program $tool found in ${result.stdOut.trim()}');
    } else {
      _logger.err(
        '• Program $tool not found ${hint != null ? "($hint)" : ""}',
      );
    }
  }
}
