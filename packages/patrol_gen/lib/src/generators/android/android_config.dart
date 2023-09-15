import 'package:path/path.dart' as path;

class AndroidConfig {
  AndroidConfig({
    required this.outputDirectory,
    required this.package,
  }) : contractsFilename = path.join(outputDirectory, 'Contracts.kt');

  final String package;
  final String outputDirectory;
  final String contractsFilename;

  String clientFileName(String serviceName) =>
      path.join(outputDirectory, '${serviceName}Client.kt');
  String serverFileName(String serviceName) =>
      path.join(outputDirectory, '${serviceName}Server.kt');
}
