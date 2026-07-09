import 'dart:convert';

import 'package:http/http.dart' as http;

class AxeAutomatorClientException implements Exception {
  AxeAutomatorClientException(this.statusCode, this.responseBody);

  final int statusCode;
  final String responseBody;

  @override
  String toString() => 'Invalid response: $statusCode $responseBody';
}

class AxeAutomatorClient {
  AxeAutomatorClient(
    this._client,
    this._baseUri, {
    Duration timeout = const Duration(seconds: 60),
  }) : _timeout = timeout;

  final http.Client _client;
  final Uri _baseUri;
  final Duration _timeout;

  Future<void> axeInitSession({
    required String dequeApiKey,
    required String dequeProjectId,
  }) => _post('axeInitSession', {
    'dequeApiKey': dequeApiKey,
    'dequeProjectId': dequeProjectId,
  });

  Future<void> axeScan({
    required bool uploadToDashboard,
    required Set<String> tags,
    String? scanName,
  }) => _post('axeScan', {
    'uploadToDashboard': uploadToDashboard,
    'tags': tags.toList(),
    'scanName': scanName,
  });

  Future<void> axeIgnoreRules({required List<String> rulesToIgnore}) =>
      _post('axeIgnoreRules', {'rulesToIgnore': rulesToIgnore});

  Future<void> axeIgnoreByViewIdResourceName({
    required String viewIdResourceName,
    required List<String> ruleList,
  }) => _post('axeIgnoreByViewIdResourceName', {
    'viewIdResourceName': viewIdResourceName,
    'ruleList': ruleList,
  });

  Future<void> axeIgnoreExperimental() => _post('axeIgnoreExperimental', {});

  Future<void> _post(String endpoint, Map<String, dynamic> body) async {
    final response = await _client
        .post(
          _baseUri.resolve(endpoint),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw AxeAutomatorClientException(response.statusCode, response.body);
    }
  }
}
