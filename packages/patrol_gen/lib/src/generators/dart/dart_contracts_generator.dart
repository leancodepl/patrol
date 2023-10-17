import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:patrol_gen/src/generators/dart/dart_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class DartContractsGenerator {
  OutputFile generate(Schema schema, DartConfig config) {
    final buffer = StringBuffer()..write(_contentPrefix(config));

    for (final enumDefinition in schema.enums) {
      buffer.writeln(_createEnum(enumDefinition));
    }
    for (final messageDefintion in schema.messages) {
      buffer.writeln(_createMessage(messageDefintion));
    }

    final content = DartFormatter().format(buffer.toString());

    return OutputFile(filename: config.contractsFilename, content: content);
  }

  String _contentPrefix(DartConfig config) {
    return '''
//
//  Generated code. Do not modify.
//  source: schema.dart
//
// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part '${path.basenameWithoutExtension(config.contractsFilename)}.g.dart';

''';
  }

  String _createEnum(Enum enumDefinition) {
    final fieldsContent = enumDefinition.fields.map((e) {
      return '''
@JsonValue('$e')
$e''';
    }).join(',\n');

    return '''
enum ${enumDefinition.name} {
  $fieldsContent
}
''';
  }

  String? _createMessage(Message message) {
    final fieldsContent = message.fields
        .map(
          (f) => switch (f.type) {
            ListFieldType(type: final type) =>
              'final List<$type>${f.isOptional ? '?' : ''} ${f.name};',
            MapFieldType(keyType: final keyType, valueType: final valueType) =>
              'final Map<$keyType,$valueType>${f.isOptional ? '?' : ''} ${f.name};',
            OrdinaryFieldType(type: final type) =>
              'final $type${f.isOptional ? '?' : ''} ${f.name};'
          },
        )
        .join('\n');

    final propsGetter = _createPropsGetter(message);

    var constructorParameters = message.fields
        .map((e) => '${e.isOptional ? '' : 'required'} this.${e.name},')
        .join();

    constructorParameters =
        message.fields.isEmpty ? '' : '{$constructorParameters}';

    return '''
@JsonSerializable()
class ${message.name} with EquatableMixin {
  ${message.name}($constructorParameters);

  factory ${message.name}.fromJson(Map<String,dynamic> json) => _\$${message.name}FromJson(json);

  $fieldsContent

  Map<String, dynamic> toJson() => _\$${message.name}ToJson(this);

  $propsGetter
}
''';
  }

  String _createPropsGetter(Message message) {
    final properties = message.fields.map((e) => e.name).join(',');
    final propertiesContent =
        properties.isEmpty ? 'const []' : '[$properties,]';

    return '''
  @override
  List<Object?> get props => $propertiesContent;
''';
  }
}
