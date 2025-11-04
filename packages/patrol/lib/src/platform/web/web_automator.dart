import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:patrol/patrol.dart' show PatrolActionException;
import 'package:patrol/src/platform/android/contracts/contracts.dart';
import 'package:patrol/src/platform/android/contracts/native_automator_client.dart';
import 'package:patrol/src/platform/web/patrol_app_service_web.dart';
import 'package:patrol_log/patrol_log.dart';

class WebAutomatorConfig {
  const WebAutomatorConfig({this.logger = _defaultPrintLogger});

  final void Function(String) logger;
}

class WebAutomator {
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
