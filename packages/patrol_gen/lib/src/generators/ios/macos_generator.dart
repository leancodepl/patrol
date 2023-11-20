import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/generators/ios/ios_contracts_generator.dart';
import 'package:patrol_gen/src/generators/ios/ios_flying_fox_server_generator.dart';
import 'package:patrol_gen/src/generators/ios/macos_client_generator.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class MacosGenerator {
  List<OutputFile> generate(Schema schema, IOSConfig config) {
    final result = [
      IOSContractsGenerator().generate(schema, config),
    ];

    final serverGenerator = IOSFlyingFoxServerGenerator();
    final clientGenerator = MacosClientGenerator();

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
