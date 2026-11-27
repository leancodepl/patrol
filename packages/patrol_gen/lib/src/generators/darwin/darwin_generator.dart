import 'package:patrol_gen/src/generators/darwin/darwin_config.dart';
import 'package:patrol_gen/src/generators/darwin/darwin_contracts_generator.dart';
import 'package:patrol_gen/src/generators/darwin/darwin_telegraph_server_generator.dart';
import 'package:patrol_gen/src/generators/darwin/darwin_url_session_client_generator.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class DarwinGenerator {
  List<OutputFile> generate(Schema schema, DarwinConfig config) {
    final serverGenerator = DarwinTelegraphServerGenerator();
    final clientGenerator = IOSURLSessionClientGenerator();
    final needsContracts = schema.services.any(
      (service) => service.ios.needsClient || service.ios.needsServer,
    );

    final result = <OutputFile>[];

    if (needsContracts) {
      result.add(DarwinContractsGenerator().generate(schema, config));
    }

    for (final service in schema.services) {
      if (service.ios.needsServer) {
        result.add(serverGenerator.generate(service, config));
      }
      if (service.ios.needsClient) {
        result.add(clientGenerator.generate(service, config));
      }
    }

    // PatrolImpl must compile to nothing without PATROL_ENABLED, so that
    // normal (e.g. release) app builds don't ship the test server.
    return result.map(_guardWithPatrolEnabled).toList();
  }

  OutputFile _guardWithPatrolEnabled(OutputFile file) {
    return OutputFile(
      filename: file.filename,
      content: '#if PATROL_ENABLED\n${file.content}\n#endif\n',
    );
  }
}
