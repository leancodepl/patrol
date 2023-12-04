import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/build_android.dart';
import 'package:patrol_cli/src/commands/build_ios.dart';
import 'package:patrol_cli/src/commands/build_macos.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';

class BuildCommand extends PatrolCommand {
  BuildCommand({
    required TestFinder testFinder,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required MacOSTestBackend macosTestBackend,
    required Analytics analytics,
    required Logger logger,
  }) {
    addSubcommand(
      BuildAndroidCommand(
        testFinder: testFinder,
        testBundler: testBundler,
        dartDefinesReader: dartDefinesReader,
        pubspecReader: pubspecReader,
        androidTestBackend: androidTestBackend,
        analytics: analytics,
        logger: logger,
      ),
    );
    addSubcommand(
      BuildIOSCommand(
        testFinder: testFinder,
        testBundler: testBundler,
        dartDefinesReader: dartDefinesReader,
        pubspecReader: pubspecReader,
        iosTestBackend: iosTestBackend,
        analytics: analytics,
        logger: logger,
      ),
    );
    addSubcommand(
      BuildMacOSCommand(
        testFinder: testFinder,
        testBundler: testBundler,
        dartDefinesReader: dartDefinesReader,
        pubspecReader: pubspecReader,
        macosTestBackend: macosTestBackend,
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
