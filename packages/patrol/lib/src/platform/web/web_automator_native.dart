import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/platform/web/patrol_app_service_web.dart';
import 'package:patrol/src/platform/web/web_automator.dart' as web_automator;
import 'package:patrol/src/platform/web/web_automator_config.dart';
import 'package:patrol_log/patrol_log.dart';

class WebAutomator extends web_automator.WebAutomator {
  WebAutomator({required WebAutomatorConfig config}) : _config = config;

  final _patrolLog = PatrolLogWriter();
  final WebAutomatorConfig _config;

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
