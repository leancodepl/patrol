import 'dart:convert';

import 'package:http/http.dart' as http;

class AxeAutomatorClientException implements Exception {
  AxeAutomatorClientException(this.statusCode, this.responseBody);

  final int statusCode;
  final String responseBody;

  @override
  String toString() => 'Invalid response: $statusCode $responseBody';
}

/// Result of [AxeAutomatorClient.ping] — proves the native extension route ran.
class AxePingResult {
  const AxePingResult({
    required this.native,
    required this.extension,
    required this.platform,
  });

  factory AxePingResult.fromJson(Map<String, dynamic> json) {
    return AxePingResult(
      native: json['native'] as bool,
      extension: json['extension'] as String,
      platform: json['platform'] as String,
    );
  }

  final bool native;
  final String extension;
  final String platform;
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

  /// Calls the native `axePing` route. A successful response proves the
  /// patrol_axe extension was discovered and mounted on Patrol's server.
  Future<AxePingResult> ping() async {
    final response = await _client
        .post(_baseUri.replace(path: 'axePing'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw AxeAutomatorClientException(response.statusCode, response.body);
    }

    return AxePingResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AxePingResult> axeScan({
    required bool uploadToDashboard,
    required Set<String> tags,
    String? scanName,
  }) async {
    final response = await _client
        .post(
          _baseUri.replace(path: 'axeScan'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'uploadToDashboard': uploadToDashboard,
            'tags': tags.toList(),
            'scanName': scanName,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw AxeAutomatorClientException(response.statusCode, response.body);
    }

    return AxePingResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> axeInitSession({
    required String dequeApiKey,
    required String dequeProjectId,
  }) => _post('axeInitSession', {
    'dequeApiKey': dequeApiKey,
    'dequeProjectId': dequeProjectId,
  });

  Future<void> _post(String endpoint, Map<String, dynamic> body) async {
    final response = await _client
        .post(
          _baseUri.replace(path: endpoint),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw AxeAutomatorClientException(response.statusCode, response.body);
    }
  }
}
