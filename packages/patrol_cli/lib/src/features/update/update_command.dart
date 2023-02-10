import 'package:args/command_runner.dart';
import 'package:patrol_cli/src/common/constants.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:pub_updater/pub_updater.dart';

class UpdateCommand extends Command<int> {
  UpdateCommand({
    required PubUpdater pubUpdater,
    required Logger logger,
  })  : _pubUpdater = pubUpdater,
        _logger = logger;

  final PubUpdater _pubUpdater;
  final Logger _logger;

  @override
  String get name => 'update';

  @override
  String get description => 'Updates patrol CLI.';

  @override
  Future<int> run() async {
    var progress =
        _logger.progress('Checking if newer patrol_cli version is available');

    final String latestVersion;
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

    return 0;
  }
}
