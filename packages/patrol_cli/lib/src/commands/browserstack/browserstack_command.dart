import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/browserstack/bs_android_command.dart';
import 'package:patrol_cli/src/commands/browserstack/bs_ios_command.dart';
import 'package:patrol_cli/src/commands/browserstack/bs_outputs_command.dart';
import 'package:patrol_cli/src/commands/build_android.dart';
import 'package:patrol_cli/src/commands/build_ios.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

/// BrowserStack command for patrol CLI.
///
/// Usage:
///   patrol bs android --target patrol_test/main_patrol.dart
///   patrol bs ios --target patrol_test/main_patrol.dart
///   patrol bs outputs `<build_id>`
class BrowserStackCommand extends PatrolCommand {
  BrowserStackCommand({
    required BuildAndroidCommand buildAndroidCommand,
    required BuildIOSCommand buildIOSCommand,
    required Analytics analytics,
    required Logger logger,
  }) {
    final bsOutputsCommand = BsOutputsCommand(logger: logger);

    addSubcommand(
      BsAndroidCommand(
        buildAndroidCommand: buildAndroidCommand,
        bsOutputsCommand: bsOutputsCommand,
        analytics: analytics,
        logger: logger,
      ),
    );
    addSubcommand(
      BsIosCommand(
        buildIOSCommand: buildIOSCommand,
        bsOutputsCommand: bsOutputsCommand,
        analytics: analytics,
        logger: logger,
      ),
    );
    addSubcommand(bsOutputsCommand);
  }

  @override
  String get name => 'bs';

  @override
  String get description =>
      'Build, upload, and test on BrowserStack App Automate.';

  @override
  String? get usageFooter => '''
Read detailed docs at https://patrol.leancode.co/cli-commands/bs

Environment variables:
  PATROL_BS_CREDENTIALS         BrowserStack credentials (username:access_key)
  PATROL_BS_ANDROID_DEVICES     JSON array of Android devices
  PATROL_BS_IOS_DEVICES         JSON array of iOS devices
  PATROL_BS_ANDROID_API_PARAMS  Extra API params for Android (JSON)
  PATROL_BS_IOS_API_PARAMS      Extra API params for iOS (JSON)
''';

  @override
  String? get docsName => 'bs';
}
