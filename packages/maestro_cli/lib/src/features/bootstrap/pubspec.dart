import 'dart:io';

import 'package:maestro_cli/src/common/constants.dart';
import 'package:yaml/yaml.dart';

/// Returns name of the project as it appears in pubspec.yaml file.
String getName() {
  final file = File(pubspecFileName);

  final contents = file.readAsStringSync();

  final dynamic yaml = loadYaml(contents);
  final name = (yaml as YamlMap)['name'] as String;

  return name;
}
