import 'dart:io';

import 'package:maestro_cli/src/command_runner.dart';

Future<int> main(List<String> args) async {
  final exitCode = await maestroCommandRunner(args);

  exit(exitCode);

  // trigger CI
}
