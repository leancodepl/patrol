import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/build_android.dart';
import 'package:patrol_cli/src/commands/build_ios.dart';
import 'package:patrol_cli/src/commands/build_macos.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';

class BuildCommand extends PatrolCommand {
  BuildCommand({
    required BuildAndroidCommand buildAndroidCommand,
    required BuildIOSCommand buildIOSCommand,
    required MacOSTestBackend macosTestBackend,
    required TestFinderFactory testFinderFactory,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required CompatibilityChecker compatibilityChecker,
    required Analytics analytics,
    required Logger logger,
  }) {
    addSubcommand(buildAndroidCommand);
    addSubcommand(buildIOSCommand);
    addSubcommand(
      BuildMacOSCommand(
        testFinderFactory: testFinderFactory,
        testBundler: testBundler,
        dartDefinesReader: dartDefinesReader,
        pubspecReader: pubspecReader,
        macosTestBackend: macosTestBackend,
        compatibilityChecker: compatibilityChecker,
        analytics: analytics,
        logger: logger,
      ),
    );
  }

  @override
  String get name => 'build';

  @override
  String get description => 'Build app binaries for integration testing.';
}
