import 'package:patrol_cli/src/dart_defines_reader.dart';

/// Merge two map with overriding values for duplicated keys, by [dartDefines] values.
Map<String, String> mergeKeys({
  required Map<String, dynamic> json,
  required Map<String, dynamic> dartDefines,
}) {
  final modified = json.map((key, value) => MapEntry(key, value.toString()));

  if (dartDefines.isNotEmpty) {
    dartDefines.forEach((key, value) => modified[key] = value.toString());
  }
  return modified;
}

/// Merge dart defines from files and from cli arguments.
Map<String, String> mergeDartDefines(
  List<String> dartDefineFromFilePaths,
  Map<String, String> dartDefines,
  DartDefinesReader dartDefinesReader,
) {
  final dartDefineConfigJsonMap =
      dartDefinesReader.extractDartDefineConfigJsonMap(dartDefineFromFilePaths);

  return mergeKeys(json: dartDefineConfigJsonMap, dartDefines: dartDefines);
}
