import 'dart:io';

import 'package:chase/src/cli/chase_command_runner.dart';

Future<void> main(List<String> args) async {
  final exitCode = await ChaseCommandRunner().run(args);
  exit(exitCode);
}
