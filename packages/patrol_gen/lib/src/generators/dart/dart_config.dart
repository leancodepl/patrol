import 'package:path/path.dart' as path;

class DartConfig {
  DartConfig({
    required this.outputDirectory,
  }) : contractsFilename = path.join(outputDirectory, 'contracts.dart');

  final String outputDirectory;
  final String contractsFilename;
}
