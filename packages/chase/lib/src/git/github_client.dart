import 'dart:convert';

import 'package:http/http.dart' as http;

/// GitHub REST API client for PR creation.
class GithubClient {
  GithubClient({
    required this.token,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  static const _apiBase = 'https://api.github.com';

  final String token;
  final http.Client _httpClient;

  /// Creates a pull request.
  Future<PullRequest> createPullRequest({
    required String owner,
    required String repo,
    required String title,
    required String body,
    required String head,
    required String base,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_apiBase/repos/$owner/$repo/pulls'),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'body': body,
        'head': head,
        'base': base,
      }),
    );

    if (response.statusCode != 201) {
      throw GithubApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PullRequest(
      number: json['number'] as int,
      url: json['html_url'] as String,
      title: json['title'] as String,
    );
  }

  void dispose() => _httpClient.close();
}

class PullRequest {
  const PullRequest({
    required this.number,
    required this.url,
    required this.title,
  });

  final int number;
  final String url;
  final String title;
}

class GithubApiException implements Exception {
  const GithubApiException({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;

  @override
  String toString() => 'GitHub API error ($statusCode): $body';
}
