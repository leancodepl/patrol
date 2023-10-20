import 'package:patrol_gen/src/generators/android/android_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';
import 'package:patrol_gen/src/utils.dart';

class AndroidContractsGenerator {
  OutputFile generate(Schema schema, AndroidConfig config) {
    final buffer = StringBuffer()
      ..write(_contentPrefix(config))
      ..writeln('class Contracts {');

    for (final enumDefinition in schema.enums) {
      buffer.writeln(_createEnum(enumDefinition));
    }
    for (final messageDefintion in schema.messages) {
      buffer.writeln(_createMessage(messageDefintion));
    }

    buffer.writeln('}');

    return OutputFile(
      filename: config.contractsFilename,
      content: buffer.toString(),
    );
  }

  String _contentPrefix(AndroidConfig config) {
    return '''
///
//  Generated code. Do not modify.
//  source: schema.dart
//

package ${config.package};

''';
  }

  String _createMessage(Message message) {
    final fields = message.fields.map((e) {
      final optional = e.isOptional ? '? = null' : '';
      return switch (e.type) {
        MapFieldType(keyType: final keyType, valueType: final valueType) =>
          '    val ${e.name}: Map<${_transformType(keyType)}, ${_transformType(valueType)}>$optional',
        ListFieldType(type: final type) =>
          '    val ${e.name}: List<${_transformType(type)}>$optional',
        OrdinaryFieldType(type: final type) =>
          '    val ${e.name}: ${_transformType(type)}$optional',
      };
    }).join(',\n');

    final dataKeyword = fields.isNotEmpty ? 'data ' : '';

    final optionalFields = message.fields.where((e) => e.isOptional).toList();

    var optionalFieldUtils = optionalFields.map(_optionalFieldUtil).join('\n');
    if (optionalFields.isNotEmpty) {
      optionalFieldUtils = '''
{
$optionalFieldUtils
  }''';
    }

    return '''
  ${dataKeyword}class ${message.name} (
$fields
  )$optionalFieldUtils
''';
  }

  String _optionalFieldUtil(MessageField field) {
    return '''
    fun has${field.name.capitalize()}(): Boolean {
      return ${field.name} != null
    }''';
  }

  String _createEnum(Enum enumDefinition) {
    final cases = enumDefinition.fields.map((e) => '    $e,').join('\n');

    return '''
  enum class ${enumDefinition.name} {
$cases
  }
''';
  }

  String _transformType(String type) {
    switch (type) {
      case 'int':
        return 'Long';
      case 'double':
        return 'Double';
      case 'bool':
        return 'Boolean';
      default:
        return type;
    }
  }
}
