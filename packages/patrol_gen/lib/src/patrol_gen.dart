import 'dart:io';

import 'package:patrol_gen/src/generators/android/android_config.dart';
import 'package:patrol_gen/src/generators/android/android_generator.dart';
import 'package:patrol_gen/src/generators/dart/dart_config.dart';
import 'package:patrol_gen/src/generators/dart/dart_generator.dart';
import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/generators/ios/ios_generator.dart';
import 'package:patrol_gen/src/generators/macos/macos_generator.dart';
import 'package:patrol_gen/src/resolve_schema.dart';

class PatrolGenConfig {
  const PatrolGenConfig({
    required this.schemaFilename,
    required this.dartConfig,
    required this.iosConfig,
    required this.macosConfig,
    required this.androidConfig,
  });

  final AndroidConfig androidConfig;
  final IOSConfig macosConfig;
  final IOSConfig iosConfig;
  final DartConfig dartConfig;
  final String schemaFilename;
}

class PatrolGen {
  Future<void> run(PatrolGenConfig config) async {
    final schema = await resolveSchema(config.schemaFilename);

    final files = DartGenerator().generate(schema, config.dartConfig)
      ..addAll(MacosGenerator().generate(schema, config.macosConfig))
      ..addAll(IOSGenerator().generate(schema, config.iosConfig))
      ..addAll(AndroidGenerator().generate(schema, config.androidConfig));

    for (final outputFile in files) {
      await File(outputFile.filename)
          .writeAsString(outputFile.content, flush: true);
    }
  }
}
