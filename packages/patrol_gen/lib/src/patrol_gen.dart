import 'package:patrol_gen/src/generators/dart/dart_config.dart';
import 'package:patrol_gen/src/generators/dart/dart_generator.dart';
import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/generators/ios/ios_generator.dart';
import 'package:patrol_gen/src/resolve_schema.dart';
import 'dart:io';

class PatrolGenConfig {
  const PatrolGenConfig({
    required this.schemaFilename,
    required this.dartConfig,
    required this.iosConfig,
  });

  final IOSConfig iosConfig;
  final DartConfig dartConfig;
  final String schemaFilename;
}

class PatrolGen {
  Future<void> run(PatrolGenConfig config) async {
    final schema = await resolveSchema(config.schemaFilename);

    final files = DartGenerator().generate(schema, config.dartConfig);
    files.addAll(IOSGenerator().generate(schema, config.iosConfig));

    for (var outputFile in files) {
      await File(outputFile.filename)
          .writeAsString(outputFile.content, flush: true);
    }
  }
}
