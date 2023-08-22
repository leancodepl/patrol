import 'package:path/path.dart' as path;

class IOSConfig {
  IOSConfig({
    required this.outputDirectory,
  }) : contractsFilename = path.join(outputDirectory, 'Contracts.swift');

  final String outputDirectory;
  final String contractsFilename;

  String clientFileName(String serviceName) =>
      path.join(outputDirectory, '${serviceName}Client.swift');
  String serverFileName(String serviceName) =>
      path.join(outputDirectory, '${serviceName}Server.swift');
}
