import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';

class CleanCommand extends Command<int> {
  CleanCommand({
    required ArtifactsRepository artifactsRepository,
  }) : _artifactsRepository = artifactsRepository;

  final ArtifactsRepository _artifactsRepository;

  @override
  String get name => 'clean';

  @override
  String get description => 'Delete all downloaded artifacts.';

  @override
  Future<int> run() async {
    final artifactPath = _artifactsRepository.artifactPath;

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
