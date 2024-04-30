import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../annotations.dart';

class KeyGenerator extends GeneratorForAnnotation<GeneratePomAndKeys> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is ClassElement) {
      final List<String?> keys = annotation
          .read('keys')
          .listValue
          .map((e) => e.toStringValue())
          .toList();
      final className = element.name;
      final buffer = StringBuffer();
      buffer
        //..writeln("import 'package:flutter/widgets.dart';")
        ..writeln()
        ..writeln('class ${className}Keys {');

      for (final key in keys) {
        buffer.writeln(
          "  static const $key = Key('${className}_$key');",
        );
      }

      buffer.writeln('}');
      return buffer.toString();
    }
  }
}
