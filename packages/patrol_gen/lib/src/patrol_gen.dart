import 'package:patrol_gen/src/generators/dart/dart_config.dart';
import 'package:patrol_gen/src/generators/dart/dart_generator.dart';
import 'package:patrol_gen/src/generators/swift_generator.dart';
import 'package:patrol_gen/src/resolve_schema.dart';
import 'dart:io';

class PatrolGenConfig {
  const PatrolGenConfig({
    required this.schemaFilename,
    required this.dartConfig,
  });

  final DartConfig dartConfig;
  final String schemaFilename;
}

class PatrolGen {
  Future<void> run(PatrolGenConfig config) async {
    final schema = await resolveSchema(config.schemaFilename);
    final dartContent =
        DartGenerator().generateContent(schema, config.dartConfig);

    final swiftOutputConfig = SwiftOutputConfig(path: 'contracts.swift');
    final swiftContent =
        SwiftGenerator().generateContent(schema, swiftOutputConfig);

    await File(config.dartConfig.contractsFilename)
        .writeAsString(dartContent, flush: true);

    await File(swiftOutputConfig.path).writeAsString(swiftContent, flush: true);
  }
}
