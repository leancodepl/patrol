import 'package:path/path.dart' as path;

class DartConfig {
  DartConfig({
    required this.outputDirectory,
  }) : contractsFilename = path.join(outputDirectory, 'contracts.dart');

  final String outputDirectory;
  final String contractsFilename;

  String serviceFileName(String serviceName) =>
      path.join(outputDirectory, '${_fileName(serviceName)}_server.dart');

  String clientFileName(String serviceName) =>
      path.join(outputDirectory, '${_fileName(serviceName)}_client.dart');

  String _fileName(String pascalCaseName) {
    final beforeCapitalLetter = RegExp(r"(?=[A-Z])");

    final parts = pascalCaseName.split(beforeCapitalLetter);
    return parts.map((e) => e.toLowerCase()).join('_');
  }
}
