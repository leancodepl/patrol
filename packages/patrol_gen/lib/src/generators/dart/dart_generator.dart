import 'package:patrol_gen/src/generators/dart/dart_config.dart';
import 'package:patrol_gen/src/schema.dart';
import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';

class DartGenerator {
  String generateContent(Schema schema, DartConfig config) {
    final buffer = StringBuffer()..write(_contentPrefix(config));

    schema.enums.forEach((e) => buffer.writeln(_createEnum(e)));
    schema.messages.forEach((e) => buffer.writeln(_createMessage(e)));

    return DartFormatter().format(buffer.toString());
  }

  String _contentPrefix(DartConfig config) {
    return '''
//
//  Generated code. Do not modify.
//  source: schema.dart
//
// ignore_for_file: public_member_api_docs

import 'package:json_annotation/json_annotation.dart';

part '${path.basenameWithoutExtension(config.contractsFilename)}.g.dart';

''';
  }

  String _createEnum(Enum enumDefinition) {
    final fieldsContent = enumDefinition.fields.map((e) {
      return '''
@JsonValue('${e}')
${e}''';
    }).join(',\n');

    return '''
enum ${enumDefinition.name} {
  $fieldsContent
}
''';
  }

  String? _createMessage(Message message) {
    final fieldsContent = message.fields
        .map((f) => f.isList
            ? 'final List<${f.type}>${f.isOptional ? '?' : ''} ${f.name};'
            : 'final ${f.type}${f.isOptional ? '?' : ''} ${f.name};')
        .join('\n');

    var constructorParameters = message.fields
        .map((e) => '${e.isOptional ? '' : 'required'} this.${e.name},')
        .join();

    constructorParameters =
        message.fields.isEmpty ? '' : '{$constructorParameters}';

    return '''
@JsonSerializable()
class ${message.name} {
  ${message.name}(${constructorParameters});

  factory ${message.name}.fromJson(Map<String,dynamic> json) => _\$${message.name}FromJson(json);

  $fieldsContent

  Map<String, dynamic> toJson() => _\$${message.name}ToJson(this);
}
''';
  }
}
