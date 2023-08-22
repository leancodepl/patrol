import 'package:dart_style/dart_style.dart';
import 'package:patrol_gen/src/generators/dart/dart_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';
import 'package:path/path.dart' as path;

class DartHttpClientGenerator {
  OutputFile generate(Service service, DartConfig config) {
    final buffer = StringBuffer()
      ..write(_contentPrefix(config))
      ..write(_generateExceptionClass(service))
      ..write(_generateClientClass(service));

    return OutputFile(
      filename: config.clientFileName(service.name),
      content: DartFormatter().format(buffer.toString()),
    );
  }

  String _contentPrefix(DartConfig config) {
    return '''
//
//  Generated code. Do not modify.
//  source: schema.dart
//
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '${path.basename(config.contractsFilename)}';
''';
  }

  String _generateClientClass(Service service) {
    final endpoints = service.endpoints.map(_createEndpoint).join('\n\n');

    return '''
class ${service.name}Client {
  const ${service.name}Client(
    this._client,
    this._apiUri, {
    Duration timeout = const Duration(seconds: 30),
  }) : _timeout = timeout;

  final Duration _timeout;
  final http.Client _client;
  final Uri _apiUri;

$endpoints

  Future<Map<String, dynamic>> _sendRequest(
    String requestName, [
    Map<String, dynamic>? request,
  ]) async {
    final response = await _client
        .post(_apiUri.resolve(requestName), body: jsonEncode(request))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw NativeAutomatorClientException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
''';
  }

  String _createEndpoint(Endpoint endpoint) {
    final returnType = endpoint.response?.name ?? 'void';
    final parameter =
        endpoint.request != null ? '${endpoint.request!.name} request,' : '';
    final jsonRequest = endpoint.request != null ? 'request.toJson(),' : '';
    final asyncKeyword = endpoint.response != null ? ' async ' : '';

    final sendRequest = endpoint.response != null
        ? '''
final json = await _sendRequest('${endpoint.name}', ${jsonRequest});
return ${endpoint.response!.name}.fromJson(json);
'''
        : '''
return _sendRequest('${endpoint.name}', ${jsonRequest});''';

    return '''
Future<$returnType> ${endpoint.name}($parameter) $asyncKeyword {
    $sendRequest
}
''';
  }

  String _generateExceptionClass(Service service) {
    final toStringMethod = r'''@override
  String toString() {
    return 'Invalid response: $statusCode $responseBody';
  }''';

    return '''
class ${service.name}ClientException implements Exception {
  ${service.name}ClientException(this.statusCode, this.responseBody);

  final String responseBody;
  final int statusCode;

  $toStringMethod
}''';
  }
}
