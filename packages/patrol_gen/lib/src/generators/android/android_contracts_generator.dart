import 'package:patrol_gen/src/generators/android/android_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class AndroidContractsGenerator {
  OutputFile generate(Schema schema, AndroidConfig config) {
    final buffer = StringBuffer()..write(_contentPrefix(config));

    schema.enums.forEach((e) => buffer.writeln(_createEnum(e)));
    schema.messages.forEach((e) => buffer.writeln(_createMessage(e)));

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

import kotlinx.serialization.Serializable

''';
  }

  String _createMessage(Message message) {
    final fields = message.fields.map((e) {
      final optional = e.isOptional ? '?' : '';
      return e.isList
          ? ' val ${e.name}: List<${_transformType(e.type)}>$optional'
          : ' val ${e.name}: ${_transformType(e.type)}$optional';
    }).join(',\n');

    final dataKeyword = fields.isNotEmpty ? 'data ' : '';

    return '''
@Serializable
${dataKeyword}class ${message.name} (
$fields
)
''';
  }

  String _createEnum(Enum enumDefinition) {
    final cases = enumDefinition.fields.map((e) => '  ${e},').join('\n');

    return '''
@Serializable
enum class ${enumDefinition.name} {
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
        return 'Boolean';
      default:
        return type;
    }
  }
}
