import 'dart:io';

import 'package:patrol_cli/src/command_runner.dart';

Future<int> main(List<String> args) async {
  final exitCode = await patrolCommandRunner(args);

  exit(exitCode);
}
