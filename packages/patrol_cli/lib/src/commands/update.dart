import 'dart:async';
import 'dart:io' show ProcessResult;

import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:pub_updater/pub_updater.dart';

class UpdateCommand extends PatrolCommand {
  UpdateCommand({
    required PubUpdater pubUpdater,
    required Analytics analytics,
    required Logger logger,
  }) : _pubUpdater = pubUpdater,
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
    unawaited(
      _analytics.sendCommand(FlutterVersion.fromCLI(flutterCommand), name),
    );

    final updated = await _updatePatrolCliPackage();

    return updated ? 0 : 1;
  }

  /// Returns whether the latest version of `patrol_cli` is active afterwards.
  Future<bool> _updatePatrolCliPackage() async {
    final progress = _logger.progress(
      'Checking if newer $_cli version is available',
    );

    final String newVersion;
    try {
      newVersion = await _pubUpdater.getLatestVersion(_cli);
    } catch (err) {
      throwToolExit('Failed to check if newer $_cli version is available');
    }

    final isUpToDate = constants.version == newVersion;
    if (isUpToDate) {
      progress.complete(
        "You're on the latest $_cli version (${constants.version})",
      );
      return true;
    } else {
      progress.update('Updating $_cli to version $newVersion');
    }

    final ProcessResult result;
    try {
      // Pin the version, so that pub fails and explains why when it can't be
      // activated (e.g. it requires a newer Dart SDK), instead of silently
      // activating an older version.
      result = await _pubUpdater.update(
        packageName: _cli,
        versionConstraint: newVersion,
      );
    } catch (err, st) {
      progress.fail('Failed to update $_cli to version $newVersion');
      _logger
        ..err('$err')
        ..err('$st');
      return false;
    }

    if (result.exitCode != 0) {
      progress.fail('Failed to update $_cli to version $newVersion');
      for (final output in [result.stdout, result.stderr]) {
        final text = '$output'.trim();
        if (text.isNotEmpty) {
          _logger.err(text);
        }
      }
      return false;
    }

    progress.complete('Updated $_cli to version $newVersion');
    return true;
  }
}
