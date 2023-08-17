import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/generators/ios/ios_telegraph_generator.dart';
import 'package:patrol_gen/src/schema.dart';

class IOSGenerator {
  String generateContent(Schema schema, IOSConfig config) {
    final buffer = StringBuffer()..write(_contentPrefix(config));

    schema.messages.forEach((e) => buffer.writeln(_createMessage(e)));

    for (var service in schema.services) {
      if (service.swift.needsServer) {
        buffer.writeln(_createServer(service));
      }
      if (service.swift.needsClient) {
        buffer.writeln(_createClient(service));
      }
    }

    return buffer.toString();
  }

  String _contentPrefix(IOSConfig config) {
    return '''
///
//  Generated code. Do not modify.
//  source: schema.dart
//

''';
  }

  String _createMessage(Message message) {
    final fields = message.fields
        .map((e) => e.isList
            ? ' var ${e.name}: [${_transformType(e.type)}]'
            : ' var ${e.name}: ${_transformType(e.type)}')
        .join('\n');

    return '''
struct ${message.name}: Codable {
$fields
}
''';
  }

  String _createServer(Service service) =>
      IOSTelegraphGenerator().generateServer(service);

  String _createClient(Service service) {
    return '';
  }

  String _transformType(String type) {
    switch (type) {
      case 'int':
        return 'Int';
      case 'double':
        return 'Double';
      case 'bool':
        return 'Bool';
      default:
        return type;
    }
  }
}
