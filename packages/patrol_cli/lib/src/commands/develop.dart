import 'dart:async';

import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/develop_arg_parser.dart';
import 'package:patrol_cli/src/commands/develop_options.dart';
import 'package:patrol_cli/src/commands/develop_service.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';
import 'package:patrol_cli/src/web/web_test_backend.dart';

class DevelopCommand extends PatrolCommand {
  DevelopCommand({
    required DeviceFinder deviceFinder,
    required TestFinderFactory testFinderFactory,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required CompatibilityChecker compatibilityChecker,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required MacOSTestBackend macosTestBackend,
    required WebTestBackend webTestBackend,
    required FlutterTool flutterTool,
    required Analytics analytics,
    required Logger logger,
    required Stream<List<int>> stdin,
  }) : _analytics = analytics,
       _developService = DevelopService(
         deviceFinder: deviceFinder,
         testFinderFactory: testFinderFactory,
         testBundler: testBundler,
         dartDefinesReader: dartDefinesReader,
         compatibilityChecker: compatibilityChecker,
         pubspecReader: pubspecReader,
         androidTestBackend: androidTestBackend,
         iosTestBackend: iosTestBackend,
         macosTestBackend: macosTestBackend,
         webTestBackend: webTestBackend,
         flutterTool: flutterTool,
         logger: logger,
         stdin: stdin,
       ) {
    configureDevelopArgParser(this);
  }

  final Analytics _analytics;
  final DevelopService _developService;

  @override
  String get name => 'develop';

  @override
  String get description => 'Develop integration tests with Hot Restart.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(FlutterVersion.fromCLI(flutterCommand), name),
    );

    final targets = stringsArg('target');
    if (targets.isEmpty) {
      throwToolExit('No target provided with --target');
    } else if (targets.length > 1) {
      throwToolExit('Only one target can be provided with --target');
    }

    final options = DevelopOptions.fromArgResults(
      argResults!,
      target: targets.first,
      flutterCommand: flutterCommand,
    );

    await _developService.run(options);

    return 0; // for now, all exit codes are 0
  }
}
