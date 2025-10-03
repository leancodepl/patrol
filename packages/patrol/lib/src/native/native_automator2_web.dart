import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/native/native_automator_web.dart';
import 'package:patrol/src/native/patrol_app_service_web.dart';
import 'package:patrol_log/patrol_log.dart';

class NativeAutomator2 {
  NativeAutomator2({required NativeAutomatorConfig config}) : _config = config;

  final _patrolLog = PatrolLogWriter();
  final NativeAutomatorConfig _config;

  Future<void> initialize() {
    return initAppService();
  }

  Future<void> enableDarkMode() async {
    await callPlaywright(
      'enableDarkMode',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<void> disableDarkMode() async {
    await callPlaywright(
      'disableDarkMode',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }
}
