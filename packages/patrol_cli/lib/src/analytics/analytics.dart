// ignore_for_file: implementation_imports
import 'dart:convert';

import 'package:file/file.dart';
import 'package:unified_analytics/src/ga_client.dart';
import 'package:unified_analytics/src/utils.dart';

class AnalyticsConfig {
  AnalyticsConfig({
    required this.clientId,
    required this.enabled,
  });

  AnalyticsConfig.fromJson(Map<String, dynamic> json)
      : clientId = json['clientId'] as String,
        enabled = json['enabled'] as bool;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'clientId': clientId,
      'enabled': enabled,
    };
  }

  /// UUID v4 unique for this client.
  final String clientId;
  final bool enabled;
}

class Analytics {
  Analytics({
    required String measurementId,
    required String apiSecret,
    required this.appName,
    required FileSystem fs,
  })  : _fs = fs,
        _client = GAClient(
          measurementId: measurementId,
          apiSecret: apiSecret,
        );

  final String appName;
  final FileSystem _fs;
  final GAClient _client;

  Future<void> sendEvent(
    String dimension, // FIXME: currently ignored
    String name, {
    Map<String, Object?> eventData = const {},
  }) async {
    final uuid = _config?.clientId;
    if (uuid == null) {
      return;
    }

    final body = _generateRequestBody(
      clientId: uuid,
      eventName: name,
      eventData: eventData,
    );

    await _client.sendData(body);
  }

  bool get firstRun => _config == null;

  set enabled(bool newValue) {
    _config = AnalyticsConfig(
      clientId: Uuid().generateV4(),
      enabled: newValue,
    );
  }

  bool get enabled => _config?.enabled ?? false;

  AnalyticsConfig? get _config {
    if (!_configFile.existsSync()) {
      return null;
    }

    final contents = _configFile.readAsStringSync();
    final json = jsonDecode(contents) as Map<String, dynamic>;
    return AnalyticsConfig(
      clientId: json['clientId'] as String,
      enabled: json['enabled'] as bool,
    );
  }

  set _config(AnalyticsConfig? newValue) {
    if (newValue == null) {
      _configFile.deleteSync();
      return;
    }

    _configFile
      ..createSync(recursive: true)
      ..writeAsStringSync(jsonEncode(newValue.toJson()));
  }

  File get _configFile {
    return getHomeDirectory(_fs)
        .childDirectory('.config')
        .childDirectory('patrol_cli')
        .childFile('analytics.json');
  }
}

/// Adapted from [generateRequestBody].
Map<String, Object?> _generateRequestBody({
  required String clientId,
  required String eventName,
  required Map<String, Object?> eventData,
}) {
  return <String, Object?>{
    'client_id': clientId,
    'events': <Map<String, Object?>>[
      <String, Object?>{
        'name': eventName,
        'params': eventData,
      }
    ],
  };
}
