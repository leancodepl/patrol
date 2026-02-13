import 'dart:convert';

import 'package:http/http.dart' as http;

import 'claude_models.dart';

/// Client for the Claude Messages API with tool_use support.
class ClaudeClient {
  ClaudeClient({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _apiVersion = '2023-06-01';

  final String apiKey;
  final http.Client _httpClient;

  /// Sends a request to the Claude Messages API.
  Future<ClaudeResponse> sendMessage(ClaudeRequest request) async {
    final response = await _httpClient.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': _apiVersion,
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw ClaudeApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ClaudeResponse.fromJson(json);
  }

  void dispose() => _httpClient.close();
}

class ClaudeApiException implements Exception {
  const ClaudeApiException({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;

  @override
  String toString() => 'Claude API error ($statusCode): $body';
}
