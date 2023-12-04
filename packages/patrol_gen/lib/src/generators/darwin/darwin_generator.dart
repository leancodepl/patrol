import 'package:patrol_gen/src/generators/darwin/darwin_config.dart';
import 'package:patrol_gen/src/generators/darwin/darwin_contracts_generator.dart';
import 'package:patrol_gen/src/generators/darwin/darwin_telegraph_server_generator.dart';
import 'package:patrol_gen/src/generators/darwin/darwin_url_session_client_generator.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class DarwinGenerator {
  List<OutputFile> generate(Schema schema, DarwinConfig config) {
    final result = [
      DarwinContractsGenerator().generate(schema, config),
    ];

    final serverGenerator = DarwinTelegraphServerGenerator();
    final clientGenerator = IOSURLSessionClientGenerator();

    for (final service in schema.services) {
      if (service.ios.needsServer) {
        result.add(serverGenerator.generate(service, config));
      }
      if (service.ios.needsClient) {
        result.add(clientGenerator.generate(service, config));
      }
    }

    return result;
  }
}
