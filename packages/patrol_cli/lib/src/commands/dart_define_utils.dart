import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';

/// Merge two map with overriding values for duplicated keys, by [dartDefines] values.
Map<String, String> mergeKeys({
  required Map<String, dynamic> json,
  required Map<String, dynamic> dartDefines,
}) {
  final modified = Map<String, String>.from(json);

  if (dartDefines.isNotEmpty) {
    dartDefines.forEach((key, value) {
      modified[key] = value as String;
    });
  }
  return modified;
}

/// Merge dart defines from files and from cli arguments.
Map<String, String> mergeDartDefines(
  List<String> dartDefineFromFilePaths,
  Map<String, String> dartDefines,
  DartDefinesReader dartDefinesReader,
  Logger logger,
) {
  var dartDefineFromFiles = <String, dynamic>{};

  for (final dartDefineFromFilePath in dartDefineFromFilePaths) {
    logger.detail(
      'Received path for --dart-define-from-file: $dartDefineFromFilePath',
    );
    dartDefineFromFiles = mergeKeys(
      json: dartDefineFromFiles,
      dartDefines:
          dartDefinesReader.fromConfigFile(path: dartDefineFromFilePath),
    );
  }

  return mergeKeys(json: dartDefineFromFiles, dartDefines: dartDefines);
}
