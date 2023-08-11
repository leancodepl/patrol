import 'package:patrol_gen/src/generators/swift_telegraph_generator.dart';
import 'package:patrol_gen/src/schema.dart';

class SwiftOutputConfig {
  const SwiftOutputConfig({required this.path});

  final String path;
}

class SwiftGenerator {
  String generateContent(Schema schema, SwiftOutputConfig outputConfig) {
    final buffer = StringBuffer()..write(_contentPrefix(outputConfig));

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

  String _contentPrefix(SwiftOutputConfig outputConfig) {
    return '''
///
//  Generated code. Do not modify.
//  source: schema.dart
//

''';
  }

  String _createMessage(Message message) {
    final fields = message.fields
        .map((e) => ' var ${e.name}: ${_transformDartType(e.type)}')
        .join('\n');

    return '''
struct ${message.name}: Codable {
$fields
}
''';
  }

  String _createServer(Service service) =>
      SwiftTelegraphGenerator().generateServer(service);

  String _createClient(Service service) {
    return '';
  }

  String _transformDartType(String type) {
    return type;
  }
}
