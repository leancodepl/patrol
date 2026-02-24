import 'dart:async';

import 'package:adb/adb.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/local.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/develop_service.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart' hide BuildMode;
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';
import 'package:patrol_cli/src/web/web_test_backend.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

/// Creates a fully-wired [DevelopService] with all its dependencies.
///
/// This factory consolidates the boilerplate of constructing test backends,
/// device finders, and other CLI components so that both the CLI command
/// runner and the MCP server can create a [DevelopService] without
/// duplicating the wiring logic.
class DevelopSessionFactory {
  /// Creates all required CLI components and returns a [DevelopService].
  ///
  /// [projectRoot] is the path to the Flutter project directory.
  /// [disposeScope] manages the lifecycle of spawned processes.
  /// [stdin] is the stream that [FlutterTool] reads for interactive commands
  /// (hot restart, quit, etc.).
  /// [onExit] replaces the default `exit(0)` in [FlutterTool] -- useful for
  /// keeping the host process alive (e.g. in an MCP server).
  /// [onTestsCompleted] is forwarded to [DevelopService] for test completion
  /// notifications.
  static DevelopService create({
    required String projectRoot,
    required DisposeScope disposeScope,
    required Stream<List<int>> stdin,
    Future<void> Function()? onExit,
    void Function(TestCompletionResult result)? onTestsCompleted,
    void Function(Entry entry)? onLogEntry,
  }) {
    const fs = LocalFileSystem();
    const platform = LocalPlatform();
    const processManager = LocalProcessManager();
    final rootDirectory = fs.directory(projectRoot);
    final logger = Logger();

    final flutterTool = FlutterTool(
      stdin: stdin,
      processManager: processManager,
      platform: platform,
      parentDisposeScope: disposeScope,
      logger: logger,
      onExit: onExit,
    );

    return DevelopService(
      deviceFinder: DeviceFinder(
        processManager: processManager,
        parentDisposeScope: disposeScope,
        logger: logger,
      ),
      testFinderFactory: TestFinderFactory(rootDirectory: rootDirectory),
      testBundler: TestBundler(
        projectRoot: rootDirectory,
        logger: logger,
      ),
      dartDefinesReader: DartDefinesReader(projectRoot: rootDirectory),
      compatibilityChecker: CompatibilityChecker(
        projectRoot: rootDirectory,
        processManager: processManager,
        logger: logger,
      ),
      pubspecReader: PubspecReader(projectRoot: rootDirectory),
      androidTestBackend: AndroidTestBackend(
        adb: Adb(),
        processManager: processManager,
        platform: platform,
        rootDirectory: rootDirectory,
        parentDisposeScope: disposeScope,
        logger: logger,
      ),
      iosTestBackend: IOSTestBackend(
        processManager: processManager,
        platform: platform,
        fs: fs,
        rootDirectory: rootDirectory,
        parentDisposeScope: disposeScope,
        logger: logger,
      ),
      macosTestBackend: MacOSTestBackend(
        processManager: processManager,
        platform: platform,
        fs: fs,
        rootDirectory: rootDirectory,
        parentDisposeScope: disposeScope,
        logger: logger,
      ),
      webTestBackend: WebTestBackend(
        processManager: processManager,
        parentDisposeScope: disposeScope,
        logger: logger,
      ),
      flutterTool: flutterTool,
      logger: logger,
      stdin: stdin,
      onTestsCompleted: onTestsCompleted,
      onLogEntry: onLogEntry,
    );
  }
}
