import 'dart:io';

import 'package:args/command_runner.dart';

import '../common/common.dart';

class CleanCommand extends Command<int> {
  @override
  String get name => 'clean';

  @override
  String get description => 'Remove all downloaded artifacts';

  @override
  Future<int> run() async {
    final progress = log.progress('Removing $artifactPath');

    try {
      await Directory(artifactPath).delete(recursive: true);
    } catch (err, st) {
      progress.fail('Failed to remove $artifactPath');
      log.severe(null, err, st);
      return 1;
    }

    progress.complete('Deleted $artifactPath');
    return 0;
  }
}
