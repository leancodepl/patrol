import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/common/common.dart';

class CleanCommand extends Command<int> {
  @override
  String get name => 'clean';

  @override
  String get description => 'Delete all downloaded artifacts.';

  @override
  Future<int> run() async {
    final progress = log.progress('Deleting $artifactPath');

    try {
      final dir = Directory(artifactPath);
      if (!dir.existsSync()) {
        progress.complete("Nothing to clean, $artifactPath doesn't exist");
        return 1;
      }

      await dir.delete(recursive: true);
    } catch (err) {
      progress.fail('Failed to delete $artifactPath');
      rethrow;
    }

    progress.complete('Deleted $artifactPath');
    return 0;
  }
}
