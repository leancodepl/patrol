import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../annotations.dart';

class KeyGenerator extends GeneratorForAnnotation<GenerateKeys> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is ClassElement) {
      final className = element.name.replaceAll(RegExp('Object'), '');
      final buffer = StringBuffer();
      buffer
        ..writeln('part of \'${element.source.uri}\';')
        ..writeln()
        ..writeln('class ${className}Keys {');

      for (final field in element.fields) {
        final fieldName = field.name;
        buffer.writeln(
          "  static const $fieldName = Key('${className}_$fieldName');",
        );
      }

      buffer.writeln('}');
      return buffer.toString();
    }
  }
}
