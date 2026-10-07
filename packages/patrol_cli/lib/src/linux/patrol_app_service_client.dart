import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:patrol_cli/src/crossplatform/test_manifest.dart';

/// The result of a single `runDartTest` call.
///
/// Mirrors `RunDartTestResponse` from `package:patrol`'s contracts. patrol_cli
/// doesn't depend on `package:patrol`, so the shapes are written by hand here.
class RunDartTestResult {
  const RunDartTestResult({required this.result, this.details});

  factory RunDartTestResult.fromJson(Map<String, dynamic> json) {
    return RunDartTestResult(
      result: RunDartTestResultStatus.fromValue(json['result'] as String),
      details: json['details'] as String?,
    );
  }

  final RunDartTestResultStatus result;
  final String? details;

  bool get failed => result == RunDartTestResultStatus.failure;
}

/// Mirrors `RunDartTestResponseResult` from `package:patrol`'s contracts.
enum RunDartTestResultStatus {
  success,
  skipped,
  failure;

  static RunDartTestResultStatus fromValue(String value) {
    return RunDartTestResultStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => throw FormatException('Unknown runDartTest result: $value'),
    );
  }
}

/// Thrown when the app answered with a status code other than 200.
class PatrolAppServiceException implements Exception {
  const PatrolAppServiceException(this.endpoint, this.statusCode, this.body);

  final String endpoint;
  final int statusCode;
  final String body;

  @override
  String toString() =>
      'PatrolAppServiceException: $endpoint returned $statusCode: $body';
}

/// A client for the `PatrolAppService` HTTP server that runs inside the app
/// under test (`PatrolAppServiceServer` in `package:patrol`).
///
/// On Android, iOS and macOS the native test runner is the client. On Linux
/// there is no native runner, so `patrol test` talks to the app directly.
class PatrolAppServiceClient {
  PatrolAppServiceClient({required http.Client httpClient, required int port})
    : _httpClient = httpClient,
      _baseUri = Uri.parse('http://127.0.0.1:$port');

  final http.Client _httpClient;
  final Uri _baseUri;

  /// Returns the tests that the app registered, flattened in declaration
  /// order.
  ///
  /// Throws [PatrolAppServiceException] on a non-200 response and lets
  /// connection errors (for example, the server is not up yet) through.
  Future<TestManifest> listDartTests({required Duration timeout}) async {
    final response = await _httpClient
        .post(_baseUri.resolve('listDartTests'))
        .timeout(timeout);
    _checkStatus('listDartTests', response);
    return TestManifest.parse(response.body);
  }

  /// Asks the app to run the test with the flattened [name] and waits for the
  /// result.
  ///
  /// There is no timeout: a test can legitimately run for minutes. The caller
  /// is responsible for noticing that the app process exited.
  Future<RunDartTestResult> runDartTest(String name) async {
    final response = await _httpClient.post(
      _baseUri.resolve('runDartTest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    _checkStatus('runDartTest', response);
    return RunDartTestResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  void _checkStatus(String endpoint, http.Response response) {
    if (response.statusCode != 200) {
      throw PatrolAppServiceException(
        endpoint,
        response.statusCode,
        response.body,
      );
    }
  }
}
