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
      currentVersion: globalVersion,
    );

    if (!isLatestVersion) {
      final latestVersion =
          await _pubUpdater.getLatestVersion(patrolCliPackage);
      await _updateTool(latestVersion);
      await _downloadArtifacts(latestVersion);
    } else {
      _logger.info(
        'You already have the newest version of $patrolCliPackage ($globalVersion)',
      );
    }

    return 0;
  }

  Future<void> _updateTool(String ver) async {
    final progress = _logger.progress(
      'Updating $patrolCliPackage to version $ver',
    );

    try {
      await _pubUpdater.update(packageName: patrolCliPackage);
      progress.complete('Updated $patrolCliPackage to version $ver');
    } catch (err) {
      progress.fail('Failed to update $patrolCliPackage to version $ver');
      rethrow;
    }
  }

  Future<void> _downloadArtifacts(String ver) async {
    final progress = _logger.progress('Downloading artifacts for version $ver');
    try {
      await _artifactsRepository.downloadArtifacts(version: ver);
      progress.complete('Downloaded artifacts for version $ver');
    } catch (err) {
      progress.fail('Failed to download artifacts for version $ver');
      rethrow;
    }
  }
}
