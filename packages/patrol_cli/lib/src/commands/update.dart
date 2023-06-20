import 'dart:async';

import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/constants.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:pub_updater/pub_updater.dart';

class UpdateCommand extends PatrolCommand {
  UpdateCommand({
    required PubUpdater pubUpdater,
    required Analytics analytics,
    required Logger logger,
  })  : _pubUpdater = pubUpdater,
        _analytics = analytics,
        _logger = logger {
    argParser.addFlag(
      'pub-upgrade',
      defaultsTo: true,
      help: 'Whether to upgrade the patrol package in pubspec.yaml.',
    );
  }

  final PubUpdater _pubUpdater;

  final Analytics _analytics;
  final Logger _logger;

  static const _cli = 'patrol_cli';

  @override
  String get name => 'update';

  @override
  String get description => 'Update Patrol CLI to the latest version.';

  @override
  Future<int> run() async {
    unawaited(_analytics.sendCommand(name));

    await _updatePatrolCliPackage();

    return 0;
  }

  Future<void> _updatePatrolCliPackage() async {
    final progress = _logger.progress(
      'Checking if newer $_cli version is available',
    );

    final String newVersion;
    try {
      newVersion = await _pubUpdater.getLatestVersion(_cli);
    } catch (err) {
      throwToolExit('Failed to check if newer $_cli version is available');
    }

    final isUpToDate = version == newVersion;
    if (isUpToDate) {
      progress.complete("You're on the latest $_cli version ($version)");
      return;
    } else {
      progress.update('Updating $_cli to version $newVersion');
    }

    try {
      await _pubUpdater.update(packageName: _cli);
    } catch (err, st) {
      progress.fail('Failed to update $_cli to version $newVersion');
      _logger
        ..err('$err')
        ..err('$st');
      return;
    }

    progress.complete('Updated $_cli to version $newVersion');
  }
}
