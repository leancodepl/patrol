import 'dart:io';

import 'package:patrol_gen/src/generators/android/android_config.dart';
import 'package:patrol_gen/src/generators/android/android_generator.dart';
import 'package:patrol_gen/src/generators/dart/dart_config.dart';
import 'package:patrol_gen/src/generators/dart/dart_generator.dart';
import 'package:patrol_gen/src/generators/darwin/darwin_config.dart';
import 'package:patrol_gen/src/generators/darwin/darwin_generator.dart';
import 'package:patrol_gen/src/resolve_schema.dart';

class PatrolGenConfig {
  const PatrolGenConfig({
    required this.schemaFilename,
    required this.dartConfig,
    required this.darwinConfig,
    required this.androidConfig,
  });

  final AndroidConfig androidConfig;
  final DartConfig dartConfig;
  final DarwinConfig darwinConfig;
  final String schemaFilename;
}

class PatrolGen {
  Future<void> run(PatrolGenConfig config) async {
    final schema = await resolveSchema(config.schemaFilename);

    final files = DartGenerator().generate(schema, config.dartConfig)
      ..addAll(DarwinGenerator().generate(schema, config.darwinConfig))
      ..addAll(AndroidGenerator().generate(schema, config.androidConfig));

    for (final outputFile in files) {
      await File(outputFile.filename)
          .writeAsString(outputFile.content, flush: true);
    }
  }
}
