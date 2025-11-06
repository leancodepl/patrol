import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/native/contracts/contracts.dart';
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

  Future<void> tapWeb({
    required WebSelector selector,
    WebSelector? iframeSelector,
  }) async {
    await callPlaywright(
      'tap',
      {
        'selector': selector.toJson(),
        'iframeSelector': iframeSelector?.toJson(),
      },
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<void> enterTextWeb({
    required WebSelector selector,
    required String text,
    WebSelector? iframeSelector,
  }) async {
    await callPlaywright(
      'enterText',
      {
        'selector': selector.toJson(),
        'text': text,
        'iframeSelector': iframeSelector?.toJson(),
      },
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<void> scrollToWeb({
    required WebSelector selector,
    WebSelector? iframeSelector,
  }) async {
    await callPlaywright(
      'scrollTo',
      {
        'selector': selector.toJson(),
        'iframeSelector': iframeSelector?.toJson(),
      },
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<void> grantPermissions({required List<String> permissions}) async {
    await callPlaywright(
      'grantPermissions',
      {'permissions': permissions},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<void> clearPermissions() async {
    await callPlaywright(
      'clearPermissions',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<void> addCookie({
    required String name,
    required String value,
    String? url,
    String? domain,
    String? path,
    int? expires,
    bool? httpOnly,
    bool? secure,
    String? sameSite,
  }) async {
    await callPlaywright(
      'addCookie',
      {
        'name': name,
        'value': value,
        'url': url,
        'domain': domain,
        'path': path,
        'expires': expires,
        'httpOnly': httpOnly,
        'secure': secure,
        'sameSite': sameSite,
      },
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<List<LinkedHashMap<Object?, Object?>>> getCookies() async {
    final result = await callPlaywright(
      'getCookies',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );

    return (result as List).cast<LinkedHashMap<Object?, Object?>>();
  }

  Future<void> clearCookies() async {
    await callPlaywright(
      'clearCookies',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<void> uploadFile({
    required WebSelector selector,
    required List<String> filePaths,
  }) async {
    await callPlaywright(
      'uploadFile',
      {'selector': selector.toJson(), 'filePaths': filePaths},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<void> acceptDialog() async {
    await callPlaywright(
      'acceptDialog',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<void> dismissDialog() async {
    await callPlaywright(
      'dismissDialog',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<String> getDialogMessage() async {
    final result = await callPlaywright(
      'getDialogMessage',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
    return result as String;
  }

  Future<void> pressKey({required String key}) async {
    await callPlaywright(
      'pressKey',
      {'key': key},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<void> pressKeyCombo({required List<String> keys}) async {
    await callPlaywright(
      'pressKeyCombo',
      {'keys': keys},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<String> waitForDownload({int? timeoutMs}) async {
    final result = await callPlaywright(
      'waitForDownload',
      {'timeoutMs': timeoutMs},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
    return result as String;
  }

  Future<void> goBack() async {
    await callPlaywright(
      'goBack',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<void> goForward() async {
    await callPlaywright(
      'goForward',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<String> getClipboard() async {
    final result = await callPlaywright(
      'getClipboard',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
    return result as String;
  }

  Future<void> setClipboard({required String text}) async {
    await callPlaywright(
      'setClipboard',
      {'text': text},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }
}
