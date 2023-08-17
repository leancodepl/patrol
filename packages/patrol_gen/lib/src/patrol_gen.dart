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
    final dartContent =
        DartGenerator().generateContent(schema, config.dartConfig);

    final swiftContent =
        IOSGenerator().generateContent(schema, config.iosConfig);

    await File(config.dartConfig.contractsFilename)
        .writeAsString(dartContent, flush: true);

    await File(config.iosConfig.contractsFilename)
        .writeAsString(swiftContent, flush: true);
  }
}
