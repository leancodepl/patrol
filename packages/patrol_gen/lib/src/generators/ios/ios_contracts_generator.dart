import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class IOSContractsGenerator {
  OutputFile generate(Schema schema, IOSConfig config) {
    final buffer = StringBuffer()..write(_contentPrefix(config));

    for (final enumDefinition in schema.enums) {
      buffer.writeln(_createEnum(enumDefinition));
    }
    for (final messageDefintion in schema.messages) {
      buffer.writeln(_createMessage(messageDefintion));
    }

    return OutputFile(
      filename: config.contractsFilename,
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

''';
  }

  String _createMessage(Message message) {
    final fields = message.fields.map((e) {
      final optional = e.isOptional ? '?' : '';
      return e.isList
          ? '  var ${e.name}: [${_transformType(e.type)}]$optional'
          : '  var ${e.name}: ${_transformType(e.type)}$optional';
    }).join('\n');

    return '''
struct ${message.name}: Codable {
$fields
}
''';
  }

  String _createEnum(Enum enumDefinition) {
    final cases = enumDefinition.fields.map((e) => '  case $e').join('\n');

    return '''
enum ${enumDefinition.name}: String, Codable {
$cases
}
''';
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
