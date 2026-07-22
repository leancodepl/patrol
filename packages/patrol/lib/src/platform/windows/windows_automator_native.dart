import 'dart:async';
import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:patrol/patrol.dart' show PatrolActionException;
import 'package:patrol/src/platform/windows/windows_automator.dart'
    as windows_automator;
import 'package:patrol/src/platform/windows/windows_automator_config.dart';
import 'package:patrol_log/patrol_log.dart';

/// HTTP client talking to the Windows Patrol sidecar on port 8081.
class WindowsAutomator implements windows_automator.WindowsAutomator {
  /// Creates a new [WindowsAutomator].
  WindowsAutomator({required WindowsAutomatorConfig config}) : _config = config {
    _client = http.Client();
    _apiUri = Uri.http('${_config.host}:${_config.port}');
    _config.logger(
      'WindowsAutomator client created, port: ${_config.port}',
    );
  }

  final WindowsAutomatorConfig _config;
  final _patrolLog = PatrolLogWriter();
  late final http.Client _client;
  late final Uri _apiUri;

  @override
  WindowsAutomatorConfig get config => _config;

  @override
  Future<void> markPatrolAppServiceReady() {
    return _wrapRequest(
      'markPatrolAppServiceReady',
      () => _sendRequest('markPatrolAppServiceReady'),
      enablePatrolLog: false,
    );
  }

  @override
  Future<void> tapAt(Offset point) {
    return _wrapRequest(
      'tapAt',
      () => _sendRequest('tapAt', {'x': point.dx, 'y': point.dy}),
    );
  }

  @override
  Future<void> tap({String? name, String? automationId}) {
    return _wrapRequest(
      'tap',
      () => _sendRequest('tap', _selectorBody(name: name, automationId: automationId)),
    );
  }

  @override
  Future<void> waitUntilVisible({String? name, String? automationId}) {
    return _wrapRequest(
      'waitUntilVisible',
      () => _sendRequest(
        'waitUntilVisible',
        _selectorBody(name: name, automationId: automationId),
      ),
    );
  }

  @override
  Future<void> enterText(
    String text, {
    String? name,
    String? automationId,
  }) {
    return _wrapRequest(
      'enterText',
      () => _sendRequest('enterText', {
        'text': text,
        ..._selectorBody(name: name, automationId: automationId),
      }),
    );
  }

  Map<String, String> _selectorBody({String? name, String? automationId}) {
    final hasName = name != null && name.isNotEmpty;
    final hasId = automationId != null && automationId.isNotEmpty;
    if (hasName == hasId) {
      throw ArgumentError(
        'Provide exactly one of name or automationId',
      );
    }
    return hasName ? {'name': name!} : {'automationId': automationId!};
  }

  Future<T> _wrapRequest<T>(
    String name,
    Future<T> Function() request, {
    bool enablePatrolLog = true,
  }) async {
    _config.logger(name);
    final text = '$name()';

    try {
      final result = await request().timeout(_config.connectionTimeout);
      if (enablePatrolLog) {
        _patrolLog.log(StepEntry(action: text, status: StepEntryStatus.success));
      }
      return result;
    } on TimeoutException {
      if (enablePatrolLog) {
        _patrolLog.log(
          StepEntry(action: text, status: StepEntryStatus.failure),
        );
      }
      throw PatrolActionException(
        'Timeout while waiting for Windows automator: $name',
      );
    } on WindowsAutomatorClientException catch (err) {
      if (enablePatrolLog) {
        _patrolLog.log(
          StepEntry(action: text, status: StepEntryStatus.failure),
        );
      }
      throw PatrolActionException(err.toString());
    }
  }

  Future<Map<String, dynamic>> _sendRequest(
    String requestName, [
    Map<String, dynamic>? request,
  ]) async {
    final response = await _client
        .post(
          _apiUri.resolve(requestName),
          body: jsonEncode(request ?? <String, dynamic>{}),
          headers: {
            'Connection': 'keep-alive',
            'Content-Type': 'application/json',
            'Keep-Alive': 'timeout=${_config.connectionTimeout.inSeconds}',
          },
        )
        .timeout(_config.connectionTimeout);

    if (response.statusCode != 200) {
      throw WindowsAutomatorClientException(
        response.statusCode,
        response.body,
      );
    }

    return response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : <String, dynamic>{};
  }
}

/// Thrown when the Windows automator HTTP server returns a non-200 status.
class WindowsAutomatorClientException implements Exception {
  /// Creates a new [WindowsAutomatorClientException].
  WindowsAutomatorClientException(this.statusCode, this.responseBody);

  /// HTTP status code.
  final int statusCode;

  /// Response body.
  final String responseBody;

  @override
  String toString() => 'Invalid response: $statusCode $responseBody';
}
