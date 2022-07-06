import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:pub_updater/pub_updater.dart';

class UpdateCommand extends Command<int> {
  UpdateCommand() : _pubUpdater = PubUpdater();

  final PubUpdater _pubUpdater;

  @override
  String get name => 'update';

  @override
  String get description => 'Updates maestro CLI.';

  @override
  Future<int> run() async {
    final isLatestVersion = await _pubUpdater.isUpToDate(
      packageName: maestroCliPackage,
      currentVersion: version,
    );

    if (!isLatestVersion) {
      final latestVersion = await _pubUpdater.getLatestVersion(
        maestroCliPackage,
      );
      await _update(latestVersion);
    } else {
      log.info(
        'You already have the newest version of $maestroCliPackage ($version)',
      );
    }

    return 0;
  }

  Future<void> _update(String latestVersion) async {
    final progress = log.progress(
      'Updating $maestroCliPackage to version $latestVersion',
    );

    try {
      await _pubUpdater.update(packageName: maestroCliPackage);
      progress.complete('Updated $maestroCliPackage to version $latestVersion');
    } catch (err) {
      progress.fail(
        'Failed to update $maestroCliPackage to version $latestVersion',
      );
      rethrow;
    }
  }
}
