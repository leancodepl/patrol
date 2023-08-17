import 'package:patrol_gen/src/generators/dart/dart_config.dart';
import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/patrol_gen.dart';
import 'package:patrol_gen/src/utils.dart';

Future<void> main(List<String> args) {
  return PatrolGen().run(
    PatrolGenConfig(
      schemaFilename: normalizePath(args[0]),
      dartConfig: DartConfig(
        outputDirectory: normalizePath(args[1]),
      ),
      iosConfig: IOSConfig(
        outputDirectory: normalizePath(args[2]),
      ),
    ),
  );
}
