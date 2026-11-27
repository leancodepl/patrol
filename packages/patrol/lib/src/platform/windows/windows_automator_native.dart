import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

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
  WindowsAutomator({required WindowsAutomatorConfig config})
    : assert(
        config.connectionTimeout > config.findTimeout,
        'connectionTimeout must be longer than findTimeout',
      ),
      _config = config {
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
  Future<void> tap(
    windows_automator.WindowsSelector selector, {
    Duration? timeout,
  }) {
    return _findBasedRequest(
      'tap',
      selector,
      timeout: timeout,
    );
  }

  @override
  Future<void> waitUntilVisible(
    windows_automator.WindowsSelector selector, {
    Duration? timeout,
  }) {
    return _findBasedRequest(
      'waitUntilVisible',
      selector,
      timeout: timeout,
    );
  }

  @override
  Future<bool> isElementVisible(
    windows_automator.WindowsSelector selector, {
    Duration? timeout,
  }) {
    // Instant check by default (sidecar ~500ms). Explicit timeout waits longer.
    final findTimeout = timeout;
    final httpTimeout = findTimeout != null
        ? _requestTimeoutFor(findTimeout)
        : _config.connectionTimeout;

    return _wrapRequest(
      'isElementVisible',
      () async {
        final json = await _sendRequestTimed(
          'isElementVisible',
          {
            ..._selectorBody(selector),
            if (findTimeout != null)
              'timeoutMillis': findTimeout.inMilliseconds,
          },
          timeout: httpTimeout,
        );
        return json['visible'] == true;
      },
      requestTimeout: httpTimeout,
    );
  }

  @override
  Future<windows_automator.WindowsUiElement?> findElement(
    windows_automator.WindowsSelector selector, {
    Duration? timeout,
  }) {
    final findTimeout = timeout ?? _config.findTimeout;
    final httpTimeout = _requestTimeoutFor(findTimeout);

    return _wrapRequest(
      'findElement',
      () async {
        final json = await _sendRequestTimed(
          'findElement',
          {
            ..._selectorBody(selector),
            'timeoutMillis': findTimeout.inMilliseconds,
          },
          timeout: httpTimeout,
        );
        final element = json['element'];
        if (element is! Map<String, dynamic>) {
          if (element is Map) {
            return windows_automator.WindowsUiElement.fromJson(
              Map<String, dynamic>.from(element),
            );
          }
          return null;
        }
        return windows_automator.WindowsUiElement.fromJson(element);
      },
      requestTimeout: httpTimeout,
    );
  }

  @override
  Future<void> enterText(
    windows_automator.WindowsSelector selector, {
    required String text,
    Duration? timeout,
  }) {
    final findTimeout = timeout ?? _config.findTimeout;
    final httpTimeout = _requestTimeoutFor(findTimeout);

    return _wrapRequest(
      'enterText',
      () => _sendRequestTimed(
        'enterText',
        {
          'text': text,
          ..._selectorBody(selector),
          'timeoutMillis': findTimeout.inMilliseconds,
        },
        timeout: httpTimeout,
      ),
      requestTimeout: httpTimeout,
    );
  }

  @override
  Future<void> pressKey(
    int keyCode, {
    bool shift = false,
    bool ctrl = false,
    bool alt = false,
  }) {
    return _wrapRequest(
      'pressKey',
      () => _sendRequest('pressKey', {
        'keyCode': keyCode,
        'shift': shift,
        'ctrl': ctrl,
        'alt': alt,
      }),
    );
  }

  @override
  Future<int> launchApp({
    required String appPath,
    String? arguments,
    bool activate = true,
  }) {
    return _wrapRequest(
      'launchApp',
      () async {
        final json = await _sendRequest('launchApp', {
          'appPath': appPath,
          'arguments': ?arguments,
          'activate': activate,
        });
        final pid = json['processId'];
        if (pid is int) {
          return pid;
        }
        if (pid is num) {
          return pid.toInt();
        }
        throw WindowsAutomatorClientException(
          200,
          'launchApp response missing processId: $json',
        );
      },
    );
  }

  @override
  Future<void> activateApp({
    String? processName,
    String? windowName,
    int? processId,
  }) {
    final hasProcess = processName != null && processName.isNotEmpty;
    final hasWindow = windowName != null && windowName.isNotEmpty;
    final hasPid = processId != null && processId > 0;
    if (!hasProcess && !hasWindow && !hasPid) {
      throw ArgumentError(
        'Provide at least one of processName, windowName, or processId',
      );
    }

    return _wrapRequest(
      'activateApp',
      () => _sendRequest('activateApp', {
        if (hasProcess) 'processName': processName,
        if (hasWindow) 'windowName': windowName,
        if (hasPid) 'processId': processId,
      }),
    );
  }

  Future<void> _findBasedRequest(
    String action,
    windows_automator.WindowsSelector selector, {
    Duration? timeout,
  }) {
    final findTimeout = timeout ?? _config.findTimeout;
    final httpTimeout = _requestTimeoutFor(findTimeout);

    return _wrapRequest(
      action,
      () => _sendRequestTimed(
        action,
        {
          ..._selectorBody(selector),
          'timeoutMillis': findTimeout.inMilliseconds,
        },
        timeout: httpTimeout,
      ),
      requestTimeout: httpTimeout,
    );
  }

  /// Builds the selector JSON, applying the default app-under-test scope.
  Map<String, dynamic> _selectorBody(
    windows_automator.WindowsSelector selector,
  ) {
    final body = selector.toJson();
    final scope =
        selector.within ?? windows_automator.WindowsScope.appUnderTest;

    if (scope.isDesktop) {
      return body;
    }

    if (scope.isAppUnderTest) {
      body['within'] = <String, dynamic>{'processId': pid};
      return body;
    }

    body['within'] = scope.toJson();
    return body;
  }

  Duration _requestTimeoutFor(Duration findTimeout) {
    // Sidecar holds the HTTP request open until the find timeout elapses.
    final padded = findTimeout + const Duration(seconds: 5);
    return Duration(
      microseconds: math.max(
        _config.connectionTimeout.inMicroseconds,
        padded.inMicroseconds,
      ),
    );
  }

  Future<T> _wrapRequest<T>(
    String name,
    Future<T> Function() request, {
    bool enablePatrolLog = true,
    Duration? requestTimeout,
  }) async {
    _config.logger(name);
    final text = '$name()';
    final timeout = requestTimeout ?? _config.connectionTimeout;

    try {
      final result = await request().timeout(timeout);
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
      throw PatrolActionException(err.message);
    }
  }

  Future<Map<String, dynamic>> _sendRequest(
    String requestName, [
    Map<String, dynamic>? request,
  ]) {
    return _sendRequestTimed(
      requestName,
      request,
      timeout: _config.connectionTimeout,
    );
  }

  Future<Map<String, dynamic>> _sendRequestTimed(
    String requestName,
    Map<String, dynamic>? request, {
    required Duration timeout,
  }) async {
    final response = await _client
        .post(
          _apiUri.resolve(requestName),
          body: jsonEncode(request ?? <String, dynamic>{}),
          headers: {
            'Connection': 'keep-alive',
            'Content-Type': 'application/json',
            'Keep-Alive': 'timeout=${timeout.inSeconds}',
          },
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw WindowsAutomatorClientException.fromResponse(
        response.statusCode,
        response.body,
      );
    }

    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw WindowsAutomatorClientException(
      response.statusCode,
      'Expected JSON object, got ${decoded.runtimeType}',
    );
  }
}

/// Thrown when the Windows automator HTTP server returns a non-200 status.
class WindowsAutomatorClientException implements Exception {
  /// Creates a new [WindowsAutomatorClientException].
  WindowsAutomatorClientException(
    this.statusCode,
    this.responseBody, {
    this.error,
  });

  /// Parses a sidecar error response (`{ "error": "..." }`).
  factory WindowsAutomatorClientException.fromResponse(
    int statusCode,
    String responseBody,
  ) {
    String? error;
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map && decoded['error'] is String) {
        error = decoded['error'] as String;
      }
    } on Object {
      // Keep raw body when JSON parse fails.
    }
    return WindowsAutomatorClientException(
      statusCode,
      responseBody,
      error: error,
    );
  }

  /// HTTP status code (`400` / `404` / `500`).
  final int statusCode;

  /// Raw response body.
  final String responseBody;

  /// Parsed `error` field from the JSON body, when present.
  final String? error;

  /// Best message for [PatrolActionException].
  String get message =>
      error ?? 'Windows automator error ($statusCode): $responseBody';

  @override
  String toString() => message;
}
