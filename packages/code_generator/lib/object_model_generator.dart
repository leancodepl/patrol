import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:path/path.dart' as p;

import '../annotations.dart';

class ObjectModelGenerator extends GeneratorForAnnotation<GeneratePomAndKeys> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is ClassElement) {
      final className = element.name;
      final packageName = buildStep.inputId.package;
      final pagePath = buildStep.inputId.path
          .replaceAll(RegExp('_object'), '')
          .replaceAll(RegExp('lib'), '');

      String currentFilePath = buildStep.inputId.path;
      String targetFilePath = 'base_om.dart';
      String relativePath =
          p.relative(targetFilePath, from: p.dirname(currentFilePath));

      final buffer = StringBuffer()
        ..writeln("import 'package:$packageName$pagePath';")
        ..writeln()
        ..writeln("import '$relativePath';")
        ..writeln(
          'final class ${className}Model extends BaseObjectModel<$className> {',
        )
        ..writeln('  ${className}Model(super.\$);')
        ..writeln('}');
      return buffer.toString();
    }
  }
}
