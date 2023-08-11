import 'package:patrol_gen/src/schema.dart';

class SwiftTelegraphGenerator {
  String generateServer(Service service) {
    return '''
${_generateInterface(service)}

${_generateSetUpRoutes(service)}
''';
  }

  String _generateSetUpRoutes(Service service) {
    return service.endpoints.map((e) => _generateRoute(e)).join('\n');
  }

  String _generateRoute(Endpoint endpoint) {
    final command = endpoint.request != null
        ? '''

    let command = try self.decoder.decode(${endpoint.request!.name}.self, from: request.body)'''
        : '';

    return '''
server.route(.POST, "${endpoint.name}") { request in
  do {$command
    interface.${endpoint.name}(${command.isNotEmpty ? 'command' : ''})
    return HTTPResponse(.ok)
  } catch let err {
    return HTTPResponse(.badRequest, headers: [:], error: err)
  }
}
''';
  }

  String _generateInterface(Service service) {
    return '';
  }
}
