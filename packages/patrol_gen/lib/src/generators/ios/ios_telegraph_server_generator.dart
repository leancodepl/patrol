import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class IOSTelegraphServerGenerator {
  OutputFile generate(Service service, IOSConfig config) {
    final buffer = StringBuffer()..write(_contentPrefix(config));

    return OutputFile(
      filename: config.serverFileName(service.name),
      content: buffer.toString(),
    );
  }

  String _contentPrefix(IOSConfig config) {
    return '''
///
//  Generated code. Do not modify.
//  source: schema.dart
//

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
