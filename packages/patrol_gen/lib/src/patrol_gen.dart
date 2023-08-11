import 'package:patrol_gen/src/generators/dart_generator.dart';
import 'package:patrol_gen/src/resolve_schema.dart';
import 'dart:io';

class PatrolGenOptions {}

class PatrolGen {
  Future<void> run(String schemaPath) async {
    final schema = await resolveSchema(schemaPath);
    final dartOutputConfig = DartOutputConfig(path: 'contracts.dart');
    final dartContent =
        DartGenerator().generateContent(schema, dartOutputConfig);

    await File(dartOutputConfig.path).writeAsString(dartContent, flush: true);
  }
}
