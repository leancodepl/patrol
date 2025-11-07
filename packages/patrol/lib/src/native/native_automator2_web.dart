import 'dart:collection';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/native/contracts/contracts.dart';
import 'package:patrol/src/native/native_automator_web.dart';
import 'package:patrol/src/native/patrol_app_service_web.dart';
import 'package:patrol_log/patrol_log.dart';

class NativeAutomator2 {
  NativeAutomator2({required NativeAutomatorConfig config}) : _config = config;

  final _patrolLog = PatrolLogWriter();
  final NativeAutomatorConfig _config;

  Future<void> configure() async {
    await _startTest();
  }

  Future<void> initialize() {
    return initAppService();
  }

  Future<void> _startTest() async {
    await callPlaywright(
      'startTest',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
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

  Future<void> uploadFile({required List<UploadFileData> files}) async {
    await callPlaywright(
      'uploadFile',
      {'files': files.map((f) => f.toJson()).toList()},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

  Future<String> acceptNextDialog() async {
    final result = await callPlaywright(
      'acceptNextDialog',
      {},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
    return result as String;
  }

  Future<String> dismissNextDialog() async {
    final result = await callPlaywright(
      'dismissNextDialog',
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

  Future<void> resizeWindow({required int width, required int height}) async {
    await callPlaywright(
      'resizeWindow',
      {'width': width, 'height': height},
      logger: _config.logger,
      patrolLog: _patrolLog,
    );
  }

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

/// Represents a file to be uploaded in web tests.
class UploadFileData {
  UploadFileData({
    required this.name,
    required this.content,
    this.mimeType = 'application/octet-stream',
  });

  /// The name of the file (e.g., 'example.txt')
  final String name;

  /// The file content as bytes
  final List<int> content;

  /// The MIME type of the file (e.g., 'text/plain', 'image/png')
  final String mimeType;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mimeType': mimeType,
      'base64Data': base64Encode(content),
    };
  }
}
