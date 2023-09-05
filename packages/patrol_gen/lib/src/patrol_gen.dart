import 'package:patrol_gen/src/generators/android/android_config.dart';
import 'package:patrol_gen/src/generators/android/android_generator.dart';
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

    final files = DartGenerator().generate(schema, config.dartConfig);
    files
      //TODO: We should rename IOSGenerator to SwiftGenerator
      // but we should wait until feature/stop-depending-on-gRPC-code-generator
      // is marged to master branch. We will avoid conflicts.
      ..addAll(IOSGenerator().generate(schema, config.macosConfig))
      ..addAll(IOSGenerator().generate(schema, config.iosConfig))
      ..addAll(AndroidGenerator().generate(schema, config.androidConfig));

    for (var outputFile in files) {
      await File(outputFile.filename)
          .writeAsString(outputFile.content, flush: true);
    }
  }
}
