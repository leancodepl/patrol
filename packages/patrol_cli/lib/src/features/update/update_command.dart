import 'package:args/command_runner.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/common/logger.dart';
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
    var progress =
        _logger.progress('Checking if newer patrol_cli version is available');

    late final String latestVersion;
    try {
      latestVersion = await _pubUpdater.getLatestVersion(patrolCliPackage);
    } catch (err, st) {
      progress.fail(
        'Failed to check if newer patrol_cli version is available',
      );
      _logger
        ..err('$err')
        ..err('$st');
      return 1;
    }

    final isUpToDate = globalVersion == latestVersion;
    if (isUpToDate) {
      progress.complete(
        "You're already using the latest patrol_cli version ($globalVersion)",
      );
      return 0;
    }

    progress.complete('New patrol_cli version is available ($latestVersion)');

    // Update CLI

    progress = _logger.progress(
      'Updating $patrolCliPackage to version $latestVersion',
    );
    try {
      await _pubUpdater.update(packageName: patrolCliPackage);
    } catch (err, st) {
      progress
          .fail('Failed to update $patrolCliPackage to version $latestVersion');
      _logger
        ..err('$err')
        ..err('$st');
      return 1;
    }
    progress.complete('Updated $patrolCliPackage to version $latestVersion');

    // Update artifacts

    progress =
        _logger.progress('Downloading artifacts for version $latestVersion');
    try {
      await _artifactsRepository.downloadArtifacts(version: latestVersion);
      progress.complete('Downloaded artifacts for version $latestVersion');
    } catch (err, st) {
      progress.fail('Failed to download artifacts for version $latestVersion');
      _logger
        ..err('$err')
        ..err('$st');
      return 1;
    }

    return 0;
  }
}
