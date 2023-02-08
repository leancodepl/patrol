import 'package:args/command_runner.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/logger.dart';

@Deprecated('Scheduled for removal in 1.0')
class CleanCommand extends Command<int> {
  @Deprecated('Scheduled for removal in 1.0')
  CleanCommand({
    required ArtifactsRepository artifactsRepository,
    required Logger logger,
  })  : _artifactsRepository = artifactsRepository,
        _logger = logger;

  final ArtifactsRepository _artifactsRepository;
  final Logger _logger;

  @override
  String get name => 'clean';

  @override
  String get description => '[DEPRECATED] Delete all downloaded artifacts.';

  @override
  Future<int> run() async {
    final artifactPath = _artifactsRepository.artifactPath;

    final progress = _logger.progress('Deleting $artifactPath');

    try {
      final dir = _artifactsRepository.artifactPathDir;
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
