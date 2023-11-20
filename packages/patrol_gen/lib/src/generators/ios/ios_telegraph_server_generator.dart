import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class IOSTelegraphServerGenerator {
  OutputFile generate(Service service, IOSConfig config) {
    final buffer = StringBuffer()
      ..write(_contentPrefix(config))
      ..write(_generateServerProtocol(service))
      ..writeln()
      ..write(_generateHandlers(service))
      ..writeln()
      ..write(_generateSetupRoutes(service))
      ..writeln()
      ..write(_generateUtils());

    return OutputFile(
      filename: config.serverFileName(service.name),
      content: buffer.toString(),
    );
  }

  String _contentPrefix(IOSConfig config) {
    return '''
///
//  swift-format-ignore-file
//
//  Generated code. Do not modify.
//  source: schema.dart
//

import Telegraph

''';
  }

  String _generateServerProtocol(Service service) {
    final endpoints = service.endpoints.map(_generateProtocolMethod).join('\n');

    return '''
protocol ${service.name}Server {
$endpoints
}
''';
  }

  String _generateProtocolMethod(Endpoint endpoint) {
    final request =
        endpoint.request != null ? 'request: ${endpoint.request!.name}' : '';
    final response =
        endpoint.response != null ? ' -> ${endpoint.response!.name}' : '';
    return '    func ${endpoint.name}($request) throws$response';
  }

  String _generateHandlers(Service service) {
    final handlers = service.endpoints.map(_generateHandler).join('\n\n');
    return '''
extension ${service.name}Server {
$handlers
}
''';
  }

  String _generateHandler(Endpoint endpoint) {
    final requestArg = endpoint.request != null
        ? '''

        let requestArg = try JSONDecoder().decode(${endpoint.request!.name}.self, from: request.body)'''
        : '';

    final responseVariable = endpoint.response != null ? 'let response = ' : '';
    final response = endpoint.response != null
        ? '''
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: body)'''
        : '        return HTTPResponse(.ok)';

    return '''
    private func ${endpoint.name}Handler(request: HTTPRequest) throws -> HTTPResponse {$requestArg
        ${responseVariable}try ${endpoint.name}(${requestArg.isNotEmpty ? 'request: requestArg' : ''})
$response
    }''';
  }

  String _generateSetupRoutes(Service service) {
    final routes = service.endpoints.map(_generateRoute).join('\n');

    return '''
extension ${service.name}Server {
    func setupRoutes(server: Server) {
$routes
    }
}
''';
  }

  String _generateRoute(Endpoint endpoint) {
    return '''
        server.route(.POST, "${endpoint.name}") {
            request in handleRequest(
                request: request,
                handler: ${endpoint.name}Handler)
        }''';
  }

  String _generateUtils() {
    // https://forums.swift.org/t/using-async-functions-from-synchronous-functions-and-breaking-all-the-rules/59782
    return '''

extension NativeAutomatorServer {
    private func handleRequest(request: HTTPRequest, handler: @escaping (HTTPRequest) throws -> HTTPResponse) -> HTTPResponse {
        do {
            return try handler(request)
        } catch let err {
            return HTTPResponse(.badRequest, headers: [:], error: err)
        }
    }
}

''';
  }
}
