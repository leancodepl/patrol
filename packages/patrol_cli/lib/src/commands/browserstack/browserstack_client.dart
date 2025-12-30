import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:patrol_cli/src/base/logger.dart';

/// Client for BrowserStack API interactions.
class BrowserStackClient {
  BrowserStackClient({
    required String credentials,
    required Logger logger,
    http.Client? httpClient,
  }) : _credentials = credentials,
       _logger = logger,
       _httpClient = httpClient ?? http.Client();

  final String _credentials;
  final Logger _logger;
  final http.Client _httpClient;

  static const _baseUrl = 'https://api-cloud.browserstack.com';

  String get _authHeader {
    final encoded = base64Encode(utf8.encode(_credentials));
    return 'Basic $encoded';
  }

  Map<String, String> get _defaultHeaders => {'Authorization': _authHeader};

  /// Make a GET request to the BrowserStack API.
  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final response = await _httpClient.get(url, headers: _defaultHeaders);

    if (response.statusCode >= 400) {
      throw BrowserStackException(
        'GET $endpoint failed with status ${response.statusCode}: ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Make a POST request to the BrowserStack API.
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final response = await _httpClient.post(
      url,
      headers: {..._defaultHeaders, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 400) {
      throw BrowserStackException(
        'POST $endpoint failed with status ${response.statusCode}: ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Upload a file to BrowserStack.
  Future<Map<String, dynamic>> uploadFile(String endpoint, File file) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(_defaultHeaders)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      throw BrowserStackException(
        'Upload to $endpoint failed with status ${response.statusCode}: ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Download a file from a URL.
  Future<File> downloadFile(
    String url,
    String outputPath, {
    int maxRetries = 5,
    Duration retryDelay = const Duration(seconds: 30),
    bool Function(File)? validate,
  }) async {
    var attempt = 0;

    while (true) {
      attempt++;
      try {
        final response = await _httpClient.get(
          Uri.parse(url),
          headers: _defaultHeaders,
        );

        if (response.statusCode >= 400) {
          throw BrowserStackException(
            'Download failed with status ${response.statusCode}',
          );
        }

        final file = File(outputPath);
        await file.writeAsBytes(response.bodyBytes);

        // Run validation if provided
        if (validate != null && !validate(file)) {
          throw BrowserStackException('Validation failed for $outputPath');
        }

        return file;
      } catch (e) {
        if (attempt >= maxRetries) {
          throw BrowserStackException(
            'Download failed after $maxRetries attempts: $outputPath',
          );
        }

        _logger.warn(
          'Attempt $attempt failed, retrying in ${retryDelay.inSeconds} seconds...',
        );
        await Future<void>.delayed(retryDelay);
      }
    }
  }

  /// Close the HTTP client.
  void close() {
    _httpClient.close();
  }
}

/// Exception thrown for BrowserStack API errors.
class BrowserStackException implements Exception {
  BrowserStackException(this.message);

  final String message;

  @override
  String toString() => 'BrowserStackException: $message';
}

/// Framework type for BrowserStack testing.
enum BsFramework {
  espresso('espresso', 'android'),
  xcuitest('xcuitest', 'ios');

  const BsFramework(this.value, this.platform);

  final String value;
  final String platform;
}
