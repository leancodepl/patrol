import 'package:patrol_gen/src/generators/android/android_config.dart';
import 'package:patrol_gen/src/generators/android/android_contracts_generator.dart';
import 'package:patrol_gen/src/generators/android/android_http4k_client_generator.dart';
import 'package:patrol_gen/src/generators/android/android_http4k_server_generator.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class AndroidGenerator {
  List<OutputFile> generate(Schema schema, AndroidConfig config) {
    final result = [
      AndroidContractsGenerator().generate(schema, config),
    ];

    final serverGenerator = AndroidHttp4kServerGenerator();
    final clientGenerator = AndroidHttp4kClientGenerator();

    for (var service in schema.services) {
      if (service.android.needsServer) {
        result.add(serverGenerator.generate(service, config));
      }
      if (service.android.needsClient) {
        result.add(clientGenerator.generate(service, config));
      }
    }

    return result;
  }
}
