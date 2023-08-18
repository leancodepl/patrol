import 'package:patrol_gen/src/generators/dart/dart_config.dart';
import 'package:patrol_gen/src/generators/dart/dart_contracts_generator.dart';
import 'package:patrol_gen/src/generators/dart/dart_shelf_server_generator.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class DartGenerator {
  List<OutputFile> generate(Schema schema, DartConfig config) {
    final result = [
      DartContractsGenerator().generate(schema, config),
    ];

    final serverGenerator = DartShelfServerGenerator();

    for (var service in schema.services) {
      if (service.dart.needsServer) {
        result.add(serverGenerator.generate(service, config));
      }
    }

    return result;
  }
}
