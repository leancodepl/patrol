import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/generators/ios/ios_contracts_generator.dart';
import 'package:patrol_gen/src/generators/ios/ios_telegraph_server_generator.dart';
import 'package:patrol_gen/src/generators/ios/ios_url_session_client_generator.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class IOSGenerator {
  List<OutputFile> generate(Schema schema, IOSConfig config) {
    final result = [
      IOSContractsGenerator().generate(schema, config),
    ];

    final serverGenerator = IOSTelegraphServerGenerator();
    final clientGenerator = IOSURLSessionClientGenerator();

    for (var service in schema.services) {
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
