import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class IOSContractsGenerator {
  OutputFile generate(Schema schema, IOSConfig config) {
    final buffer = StringBuffer()..write(_contentPrefix(config));

    schema.enums.forEach((e) => buffer.writeln(_createEnum(e)));
    schema.messages.forEach((e) => buffer.writeln(_createMessage(e)));

    return OutputFile(
      filename: config.contractsFilename,
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

  String _createEnum(Enum enumDefinition) {
    final cases = enumDefinition.fields.map((e) => '  case ${e}').join('\n');

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
