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
    var progress = _logger.progress('Checking for updates');
    late final String latestVersion;
    try {
      latestVersion = await _pubUpdater.getLatestVersion(patrolCliPackage);
    } catch (err, st) {
      progress.fail('Failed to check for updates');
      _logger.severe(null, err, st);
      return 1;
    }
    progress.complete('New version is available ($latestVersion)');

    final isUpToDate = globalVersion == latestVersion;
    if (isUpToDate) {
      _logger.info(
        'You already have the newest version of $patrolCliPackage ($globalVersion)',
      );
      return 0;
    }

    // Update CLI

    progress = _logger.progress(
      'Updating $patrolCliPackage to version $latestVersion',
    );
    try {
      await _pubUpdater.update(packageName: patrolCliPackage);
    } catch (err, st) {
      progress
          .fail('Failed to update $patrolCliPackage to version $latestVersion');
      _logger.severe(null, err, st);
      return 1;
    }
    progress.complete('Updated $patrolCliPackage to $latestVersion');

    // Update artifacts

    progress =
        _logger.progress('Downloading artifacts for version $latestVersion');
    try {
      await _artifactsRepository.downloadArtifacts(version: latestVersion);
      progress.complete('Downloaded artifacts for version $latestVersion');
    } catch (err, st) {
      progress.fail('Failed to download artifacts for version $latestVersion');
      _logger.severe(null, err, st);
      rethrow;
    }

    return 0;
  }
}
