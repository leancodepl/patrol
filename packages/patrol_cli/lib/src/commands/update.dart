import 'dart:async';

import 'package:patrol_cli/src/base/constants.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:usage/usage.dart';

class UpdateCommand extends PatrolCommand {
  UpdateCommand({
    required PubUpdater pubUpdater,
    required Analytics analytics,
    required Logger logger,
  })  : _pubUpdater = pubUpdater,
        _analytics = analytics,
        _logger = logger;

  final PubUpdater _pubUpdater;

  final Analytics _analytics;
  final Logger _logger;

  static const _pkg = 'patrol_cli';

  @override
  String get name => 'update';

  @override
  String get description => 'Update Patrol CLI to the latest version.';

  @override
  Future<int> run() async {
    unawaited(_analytics.sendEvent('command', name));

    Progress progress;

    progress = _logger.progress('Checking if newer $_pkg version is available');

    final String newVersion;
    try {
      newVersion = await _pubUpdater.getLatestVersion(_pkg);
    } catch (err, st) {
      progress.fail('Failed to check if newer $_pkg version is available');
      _logger
        ..err('$err')
        ..err('$st');
      return 1;
    }

    final isUpToDate = version == newVersion;
    if (isUpToDate) {
      progress.complete("You're on the latest $_pkg version ($version)");
      return 0;
    }

    progress.complete('New $_pkg version is available ($newVersion)');
    progress = _logger.progress('Updating $_pkg to version $newVersion');
    try {
      await _pubUpdater.update(packageName: _pkg);
    } catch (err, st) {
      progress.fail('Failed to update $_pkg to version $newVersion');
      _logger
        ..err('$err')
        ..err('$st');
      return 1;
    }
    progress.complete('Updated $_pkg to version $newVersion');

    return 0;
  }
}
