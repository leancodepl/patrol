import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/common/paths.dart';

class CleanCommand extends Command<int> {
  @override
  String get name => 'clean';

  @override
  String get description => 'Remove all downloaded artifacts';

  @override
  Future<int> run() async {
    Directory(artifactsPath).deleteSync(recursive: true);
    return 0;
  }
}
