import 'package:patrol_gen/src/generators/dart_generator.dart';
import 'package:patrol_gen/src/generators/swift_generator.dart';
import 'package:patrol_gen/src/resolve_schema.dart';
import 'dart:io';

class PatrolGenOptions {}

class PatrolGen {
  Future<void> run(String schemaPath) async {
    final schema = await resolveSchema(schemaPath);
    final dartOutputConfig = DartOutputConfig(path: 'contracts.dart');
    final dartContent =
        DartGenerator().generateContent(schema, dartOutputConfig);

    final swiftOutputConfig = SwiftOutputConfig(path: 'contracts.swift');
    final swiftContent =
        SwiftGenerator().generateContent(schema, swiftOutputConfig);

    await File(dartOutputConfig.path).writeAsString(dartContent, flush: true);
    await File(swiftOutputConfig.path).writeAsString(swiftContent, flush: true);
  }
}
