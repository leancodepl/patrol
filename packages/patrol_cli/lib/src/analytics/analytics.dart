// ignore_for_file: implementation_imports
import 'dart:convert';

import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:patrol_cli/src/base/constants.dart';
import 'package:patrol_cli/src/base/fs.dart';
import 'package:platform/platform.dart';
import 'package:uuid/uuid.dart';
//import 'package:unified_analytics/src/ga_client.dart';
//import 'package:unified_analytics/src/utils.dart';

const _analyticsUrl = 'https://www.google-analytics.com/mp/collect';

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
    required FileSystem fs,
    required Platform platform,
  })  : _fs = fs,
        _platform = platform,
        _client = http.Client(),
        _postUrl =
            '$_analyticsUrl?measurement_id=$measurementId&api_secret=$apiSecret';

  final FileSystem _fs;
  final Platform _platform;

  final http.Client _client;
  final String _postUrl;

  /// Sends an event to Google Analytics that command [name] run.
  Future<void> sendCommand(
    String name, {
    Map<String, Object?> eventData = const {},
  }) async {
    final uuid = _config?.clientId;
    if (uuid == null) {
      return;
    }

    await _client.post(
      Uri.parse(_postUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        _generateRequestBody(
          clientId: uuid,
          eventName: name,
          eventData: {
            'client_id': uuid,
            'flutter_version': flutterVersion,
            'patrol_cli_version': version,
          },
        ),
      ),
    );
  }

  bool get firstRun => _config == null;

  set enabled(bool newValue) {
    _config = AnalyticsConfig(
      clientId: const Uuid().v4(),
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
    return getHomeDirectory(_fs, _platform)
        .childDirectory('.config')
        .childDirectory('patrol_cli')
        .childFile('analytics.json');
  }
}

Map<String, Object?> _generateRequestBody({
  required String clientId,
  required String eventName,
  required Map<String, Object?> eventData,
}) {
  print('eventData: $eventData');

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
