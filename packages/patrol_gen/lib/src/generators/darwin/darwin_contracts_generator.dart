import 'package:patrol_gen/src/generators/darwin/darwin_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class DarwinContractsGenerator {
  OutputFile generate(Schema schema, DarwinConfig config) {
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

  String _contentPrefix(DarwinConfig config) {
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
    final fields = message.fields
        .map((e) {
          final optional = e.isOptional ? '?' : '';
          return switch (e.type) {
            MapFieldType(keyType: final keyType, valueType: final valueType) =>
              '${e.name}: [${_transformType(keyType)}: ${_transformType(valueType)}]$optional',
            ListFieldType(type: final type) =>
              '${e.name}: [${_transformType(type)}]$optional',
            OrdinaryFieldType(type: final type) =>
              '${e.name}: ${_transformType(type)}$optional',
          };
        })
        .map((e) => '  public var $e')
        .join('\n');

    return '''
public struct ${message.name}: Codable {
$fields
}
''';
  }

  String _createEnum(Enum enumDefinition) {
    final cases = enumDefinition.fields.map((e) => '  case $e').join('\n');

    return '''
public enum ${enumDefinition.name}: String, Codable {
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
