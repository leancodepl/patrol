import 'package:patrol_gen/src/schema.dart';
import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';

class DartOutputConfig {
  const DartOutputConfig({required this.path});

  final String path;
}

class DartGenerator {
  String generateContent(Schema schema, DartOutputConfig outputConfig) {
    final buffer = StringBuffer()..write(_contentPrefix(outputConfig));

    schema.enums.forEach((e) => buffer.writeln(_createEnum(e)));
    schema.messages.forEach((e) => buffer.writeln(_createMessage(e)));

    return DartFormatter().format(buffer.toString());
  }

  String _contentPrefix(DartOutputConfig outputConfig) {
    return '''
///
//  Generated code. Do not modify.
//  source: schema.dart
//
import 'package:json_annotation/json_annotation.dart';

part '${path.basenameWithoutExtension(outputConfig.path)}.g.dart';

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
        .map((f) => 'final ${f.type}${f.optional ? '?' : ''} ${f.name};')
        .join('\n');

    var constructorParameters = message.fields
        .map((e) => '${e.optional ? '' : 'required'} this.${e.name}')
        .join(',');

    constructorParameters =
        message.fields.isEmpty ? '' : '{$constructorParameters}';

    return '''
@JsonSerializable()
class ${message.name} {
  ${message.name}(${constructorParameters});

  $fieldsContent

  factory ${message.name}.fromJson(Map<String,dynamic> json) => _\$${message.name}FromJson(json);

  Map<String, dynamic> toJson() => _\$${message.name}ToJson(this);
}
''';
  }
}
