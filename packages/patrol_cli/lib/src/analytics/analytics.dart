// ignore_for_file: implementation_imports
import 'dart:convert';
import 'dart:io' as io;

import 'package:ci/ci.dart' as ci;
import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:patrol_cli/src/base/constants.dart';
import 'package:patrol_cli/src/base/fs.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:platform/platform.dart';
import 'package:uuid/uuid.dart';

typedef FlutterVersionGetter = FlutterVersion Function();

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
    http.Client? httpClient,
    FlutterVersionGetter getFlutterVersion = _getFlutterVersion,
  })  : _fs = fs,
        _platform = platform,
        _httpClient = httpClient ?? http.Client(),
        _postUrl = _getAnalyticsUrl(measurementId, apiSecret),
        _flutterVersion = getFlutterVersion();

  final FileSystem _fs;
  final Platform _platform;

  final http.Client _httpClient;
  final String _postUrl;

  final FlutterVersion _flutterVersion;

  /// Sends an event to Google Analytics that command [name] run.
  ///
  /// Returns true if the event was sent, false otherwise.
  Future<bool> sendCommand(
    String name, {
    Map<String, Object?> eventData = const {},
  }) async {
    final uuid = _config?.clientId;
    if (uuid == null) {
      return false;
    }

    final enabled = _config?.enabled ?? false;
    if (!enabled) {
      return false;
    }

    await _httpClient.post(
      Uri.parse(_postUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: _generateRequestBody(
        clientId: uuid,
        eventName: name,
        additionalEventData: eventData,
      ),
    );
    return true;
  }

  bool get firstRun => _config == null;

  set enabled(bool newValue) {
    _config = AnalyticsConfig(
      clientId: const Uuid().v4(),
      enabled: newValue,
    );
  }

  bool get isCI => ci.isCI;

  bool get enabled {
    if (isCI) {
      return false;
    }

    return _config?.enabled ?? false;
  }

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

  String _generateRequestBody({
    required String clientId,
    required String eventName,
    required Map<String, Object?> additionalEventData,
  }) {
    final event = <String, Object?>{
      'name': eventName,
      'params': <String, Object?>{
        // `engagement_time_msec` is required for users to be reported.
        // See https://stackoverflow.com/q/70708893/7009800
        'engagement_time_msec': 1,
        'flutter_version': _flutterVersion.version,
        'flutter_channel': _flutterVersion.channel,
        'patrol_cli_version': version,
        'os': _platform.operatingSystem,
        'os_version': _platform.operatingSystemVersion,
        'locale': _platform.localeName,
        ...additionalEventData,
      },
    };

    final body = <String, Object?>{
      'client_id': clientId,
      'events': [event],
    };

    return jsonEncode(body);
  }
}

String _getAnalyticsUrl(String measurementId, String apiSecret) {
  const url = 'https://www.google-analytics.com/mp/collect';
  return '$url?measurement_id=$measurementId&api_secret=$apiSecret';
}

class FlutterVersion {
  FlutterVersion(this.version, this.channel);

  factory FlutterVersion.test() => FlutterVersion('1.2.3', 'stable');

  final String version;
  final String channel;
}

FlutterVersion _getFlutterVersion() {
  final result = io.Process.runSync(
    'flutter',
    ['--no-version-check', '--version', '--machine'],
  );

  final versionData = jsonDecode(result.stdOut) as Map<String, dynamic>;
  final frameworkVersion = versionData['frameworkVersion'] as String;
  final channel = versionData['channel'] as String;
  return FlutterVersion(frameworkVersion, channel);
}
