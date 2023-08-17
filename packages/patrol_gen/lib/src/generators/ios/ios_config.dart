import 'package:path/path.dart' as path;

class IOSConfig {
  IOSConfig({
    required this.outputDirectory,
  }) : contractsFilename = path.join(outputDirectory, 'contracts.swift');

  final String outputDirectory;
  final String contractsFilename;
}
