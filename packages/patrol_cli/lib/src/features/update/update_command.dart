import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:pub_updater/pub_updater.dart';

class UpdateCommand extends Command<int> {
  UpdateCommand({
    required PubUpdater pubUpdater,
    required ArtifactsRepository artifactsRepository,
    required Logger logger,
  })  : _pubUpdater = pubUpdater,
        _artifactsRepository = artifactsRepository,
        _logger = logger;

  final PubUpdater _pubUpdater;
  final ArtifactsRepository _artifactsRepository;
  final Logger _logger;

  @override
  String get name => 'update';

  @override
  String get description => 'Updates patrol CLI.';

  @override
  Future<int> run() async {
    final isLatestVersion = await _pubUpdater.isUpToDate(
      packageName: patrolCliPackage,
      currentVersion: version,
    );

    if (!isLatestVersion) {
      final latestVersion = await _pubUpdater.getLatestVersion(
        patrolCliPackage,
      );
      await _update(latestVersion);
      await _downloadArtifacts(latestVersion);
    } else {
      _logger.info(
        'You already have the newest version of $patrolCliPackage ($version)',
      );
    }

    return 0;
  }

  Future<void> _update(String latestVersion) async {
    final progress = _logger.progress(
      'Updating $patrolCliPackage to version $latestVersion',
    );

    try {
      await _pubUpdater.update(packageName: patrolCliPackage);
      progress.complete('Updated $patrolCliPackage to version $latestVersion');
    } catch (err) {
      progress.fail(
        'Failed to update $patrolCliPackage to version $latestVersion',
      );
      rethrow;
    }
  }

  Future<void> _downloadArtifacts(String latestVersion) async {
    final progress = _logger.progress(
      'Downloading artifacts for version $latestVersion',
    );

    try {
      await _artifactsRepository.downloadArtifacts() .update(packageName: patrolCliPackage);
      progress.complete('Download artifacts for version $latestVersion');
    } catch (err) {
      progress.fail(
        'Failed to download artifacts for version $latestVersion',
      );
      rethrow;
    }
  }
}
