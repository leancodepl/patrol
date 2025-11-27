import 'dart:collection';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/platform/web/patrol_app_service_web.dart';
import 'package:patrol/src/platform/web/upload_file_data.dart';
import 'package:patrol/src/platform/web/web_automator.dart' as web_automator;
import 'package:patrol/src/platform/web/web_automator_config.dart';
import 'package:patrol/src/platform/web/web_selector.dart';
import 'package:patrol_log/patrol_log.dart';

/// Provides functionality to interact with web applications.
class WebAutomator implements web_automator.WebAutomator {
  /// Creates a new [WebAutomator].
  WebAutomator({required WebAutomatorConfig config}) : _config = config;

  final _patrolLog = PatrolLogWriter();
  final WebAutomatorConfig _config;

  @override
  Future<void> configure() async {
    await _startTest();
  }

  @override
  Future<void> initialize() {
    return initAppService();
  }

  Future<void> _startTest() async {
    await callPlaywright('startTest', {}, logger: _config.logger);
  }

  @override
  Future<void> enableDarkMode() async {
    await callPlaywright(
      'enableDarkMode',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  @override
  Future<void> disableDarkMode() async {
    await callPlaywright(
      'disableDarkMode',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  @override
  Future<void> tap(WebSelector selector, {WebSelector? iframeSelector}) async {
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

  @override
  Future<void> enterText(
    WebSelector selector, {
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

  @override
  Future<void> scrollTo(
    WebSelector selector, {
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

  @override
  Future<void> grantPermissions({required List<String> permissions}) async {
    await callPlaywright(
      'grantPermissions',
      {'permissions': permissions},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  @override
  Future<void> clearPermissions() async {
    await callPlaywright(
      'clearPermissions',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  @override
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

  @override
  Future<List<LinkedHashMap<Object?, Object?>>> getCookies() async {
    final result = await callPlaywright(
      'getCookies',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );

    return (result as List).cast<LinkedHashMap<Object?, Object?>>();
  }

  @override
  Future<void> clearCookies() async {
    await callPlaywright(
      'clearCookies',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  @override
  Future<void> uploadFile({required List<UploadFileData> files}) async {
    await callPlaywright(
      'uploadFile',
      {'files': files.map((f) => f.toJson()).toList()},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  @override
  Future<String> acceptNextDialog() async {
    final result = await callPlaywright(
      'acceptNextDialog',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
    return result as String;
  }

  @override
  Future<String> dismissNextDialog() async {
    final result = await callPlaywright(
      'dismissNextDialog',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
    return result as String;
  }

  @override
  Future<void> pressKey({required String key}) async {
    await callPlaywright(
      'pressKey',
      {'key': key},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  @override
  Future<void> pressKeyCombo({required List<String> keys}) async {
    await callPlaywright(
      'pressKeyCombo',
      {'keys': keys},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  @override
  Future<void> goBack() async {
    await callPlaywright(
      'goBack',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  @override
  Future<void> goForward() async {
    await callPlaywright(
      'goForward',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  @override
  Future<String> getClipboard() async {
    final result = await callPlaywright(
      'getClipboard',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
    return result as String;
  }

  @override
  Future<void> setClipboard({required String text}) async {
    await callPlaywright(
      'setClipboard',
      {'text': text},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  @override
  Future<void> resizeWindow({required Size size}) async {
    await callPlaywright(
      'resizeWindow',
      {'width': size.width, 'height': size.height},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  @override
  Future<List<String>> verifyFileDownloads() async {
    final result = await callPlaywright(
      'verifyFileDownloads',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
    return (result as List<dynamic>).cast<String>();
  }
}
