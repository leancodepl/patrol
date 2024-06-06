import 'dart:io' show ProcessSignal, stdin;

import 'package:adb/adb.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:ci/ci.dart' as ci;
import 'package:cli_completion/cli_completion.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/commands/build.dart';
import 'package:patrol_cli/src/commands/develop.dart';
import 'package:patrol_cli/src/commands/devices.dart';
import 'package:patrol_cli/src/commands/doctor.dart';
import 'package:patrol_cli/src/commands/test.dart';
import 'package:patrol_cli/src/commands/update.dart';
import 'package:patrol_cli/src/compatibility_checker.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:pub_updater/pub_updater.dart';

Future<int> patrolCommandRunner(List<String> args) async {
  final pubUpdater = PubUpdater();
  final logger = Logger();
  const fs = LocalFileSystem();
  const platform = LocalPlatform();
  final processManager = LoggingLocalProcessManager(logger: logger);
  final isCI = ci.isCI;

  final runner = PatrolCommandRunner(
    pubUpdater: pubUpdater,
    platform: platform,
    fs: fs,
    logger: logger,
    analytics: Analytics(
      measurementId: _gaTrackingId,
      apiSecret: _gaApiSecret,
      fs: fs,
      platform: platform,
      isCI: isCI,
    ),
    processManager: processManager,
    isCI: isCI,
  );

  ProcessSignal.sigint.watch().listen((signal) async {
    logger.detail('Caught SIGINT, exiting...');
    await runner.dispose().onError((err, st) {
      logger
        ..err('error while disposing')
        ..err('$err')
        ..err('$st');
    });
  });

  final exitCode = await runner.run(args) ?? 0;

  if (!runner._disposeScope.disposed) {
    await runner.dispose();
  }

  return exitCode;
}

const _gaTrackingId = 'G-W8XN8GS5BC';
const _gaApiSecret = 'CUIwI1nCQWGJQAK8E0AIfg';

class PatrolCommandRunner extends CompletionCommandRunner<int> {
  PatrolCommandRunner({
    required PubUpdater pubUpdater,
    required Platform platform,
    required FileSystem fs,
    required ProcessManager processManager,
    required Analytics analytics,
    required Logger logger,
    required bool isCI,
  })  : _platform = platform,
        _pubUpdater = pubUpdater,
        _fs = fs,
        _analytics = analytics,
        _processManager = processManager,
        _disposeScope = DisposeScope(),
        _logger = logger,
        _isCI = isCI,
        super(
          'patrol',
          'Tool for running Flutter-native UI tests with superpowers',
        ) {
    final androidTestBackend = AndroidTestBackend(
      adb: Adb(),
      processManager: _processManager,
      platform: _platform,
      fs: _fs,
      parentDisposeScope: _disposeScope,
      logger: _logger,
    );

    final iosTestBackend = IOSTestBackend(
      processManager: _processManager,
      platform: _platform,
      fs: _fs,
      parentDisposeScope: _disposeScope,
      logger: _logger,
    );

    final macosTestBackend = MacOSTestBackend(
      processManager: _processManager,
      platform: _platform,
      fs: _fs,
      parentDisposeScope: _disposeScope,
      logger: _logger,
    );

    final testBundler = TestBundler(
      projectRoot: _fs.currentDirectory,
      logger: _logger,
    );
    final testFinder = TestFinder(testDir: _fs.directory('integration_test'));

    final deviceFinder = DeviceFinder(
      processManager: _processManager,
      parentDisposeScope: _disposeScope,
      logger: _logger,
    );

    addCommand(
      BuildCommand(
        testFinder: testFinder,
        testBundler: testBundler,
        dartDefinesReader: DartDefinesReader(projectRoot: _fs.currentDirectory),
        pubspecReader: PubspecReader(projectRoot: _fs.currentDirectory),
        androidTestBackend: androidTestBackend,
        iosTestBackend: iosTestBackend,
        macosTestBackend: macosTestBackend,
        analytics: _analytics,
        logger: _logger,
      ),
    );

    addCommand(
      DevelopCommand(
        deviceFinder: deviceFinder,
        testFinder: testFinder,
        testBundler: testBundler,
        dartDefinesReader: DartDefinesReader(projectRoot: _fs.currentDirectory),
        compatibilityChecker: CompatibilityChecker(
          projectRoot: _fs.currentDirectory,
          processManager: _processManager,
          logger: _logger,
        ),
        pubspecReader: PubspecReader(projectRoot: _fs.currentDirectory),
        flutterTool: FlutterTool(
          stdin: stdin,
          processManager: _processManager,
          platform: _platform,
          parentDisposeScope: _disposeScope,
          logger: _logger,
        ),
        androidTestBackend: androidTestBackend,
        iosTestBackend: iosTestBackend,
        macosTestBackend: macosTestBackend,
        analytics: _analytics,
        logger: _logger,
      ),
    );

    addCommand(
      TestCommand(
        deviceFinder: deviceFinder,
        testBundler: testBundler,
        testFinder: testFinder,
        dartDefinesReader: DartDefinesReader(projectRoot: _fs.currentDirectory),
        compatibilityChecker: CompatibilityChecker(
          projectRoot: _fs.currentDirectory,
          processManager: _processManager,
          logger: _logger,
        ),
        pubspecReader: PubspecReader(projectRoot: _fs.currentDirectory),
        androidTestBackend: androidTestBackend,
        iosTestBackend: iosTestBackend,
        macOSTestBackend: macosTestBackend,
        packageDirectory: _fs.currentDirectory,
        analytics: _analytics,
        logger: _logger,
      ),
    );

    addCommand(
      DevicesCommand(
        deviceFinder: deviceFinder,
        logger: _logger,
      ),
    );

    addCommand(
      DoctorCommand(
        logger: _logger,
        platform: _platform,
      ),
    );

    addCommand(
      UpdateCommand(
        pubUpdater: _pubUpdater,
        analytics: _analytics,
        logger: _logger,
      ),
    );

    argParser
      ..addOption(
        'flutter-command',
        help:
            'Command to use to run the Flutter CLI. Alternatively set the PATROL_FLUTTER_COMMAND environment variable.',
        valueHelp: 'fvm flutter',
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Print more logs.',
        negatable: false,
      )
      ..addFlag(
        'version',
        abbr: 'V',
        help: 'Print version of this program.',
        negatable: false,
      );
  }

  final PubUpdater _pubUpdater;
  final Platform _platform;
  final FileSystem _fs;
  final ProcessManager _processManager;
  final Analytics _analytics;

  final DisposeScope _disposeScope;
  final Logger _logger;
  final bool _isCI;

  Future<void> dispose() async {
    try {
      await _disposeScope.dispose();
    } catch (err, st) {
      _logger
        ..err('error while disposing')
        ..err('$err')
        ..err('$st');
    }
  }

  @override
  bool get enableAutoInstall {
    return !_platform.environment.containsKey('PATROL_NO_COMPLETION');
  }

  @override
  String? get usageFooter => '''
Read documentation at https://patrol.leancode.pl
Report bugs, request features at https://github.com/leancodepl/patrol/issues
Ask questions, get support at https://github.com/leancodepl/patrol/discussions''';

  @override
  Future<int?> run(Iterable<String> args) async {
    var verbose = false;

    var exitCode = 1;
    try {
      _handleFirstRun();

      final topLevelResults = parse(args);
      verbose = topLevelResults['verbose'] == true;

      if (verbose) {
        _logger
          ..level = Level.verbose
          ..info('Verbose mode enabled. More logs will be printed.');
      }
      exitCode = await runCommand(topLevelResults) ?? 0;
    } on ToolExit catch (err, st) {
      if (verbose) {
        _logger
          ..err('$err')
          ..err('$st');
      } else {
        _logger.err('$err');
      }
    } on ToolInterrupted catch (err, st) {
      if (verbose) {
        _logger
          ..err('$err')
          ..err('$st');
      } else {
        _logger.err(err.message);
      }
    } on FormatException catch (err, st) {
      _logger
        ..err(err.message)
        ..err('source: ${err.source}')
        ..err('$st')
        ..info('')
        ..info(usage);
    } on UsageException catch (err) {
      _logger
        ..err(err.message)
        ..info('')
        ..info(err.usage);
    } on FileSystemException catch (err, st) {
      _logger
        ..err('${err.message}: ${err.path}')
        ..err('$err')
        ..err('$st');
    } catch (err, st) {
      _logger
        ..err('$err')
        ..err('$st');
    }

    return exitCode;
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    final commandName = topLevelResults.command?.name;

    if (_wantsUpdateCheck(commandName)) {
      await _checkForUpdate(commandName);
    }

    final int? exitCode;
    if (topLevelResults['version'] == true) {
      _logger.info('patrol_cli v${constants.version}');
      exitCode = 0;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }

    return exitCode;
  }

  @override
  void printUsage() => _logger.info(usage);

  void _handleFirstRun() {
    if (_analytics.firstRun && !_isCI) {
      _handleAnalytics();
      _runDoctor();
    }
  }

  void _handleAnalytics() {
    _logger.info(
      '''
\n
+---------------------------------------------------+
|             Patrol - Ready for action!            |
+---------------------------------------------------+
| We would like to collect anonymous usage data     |
| to improve Patrol CLI. No sensitive or private    |
| information will ever leave your machine.         |
+---------------------------------------------------+
\n''',
    );
    final analyticsEnabled = _logger.confirm(
      'Enable analytics?',
      defaultValue: true,
    );
    _analytics.enabled = analyticsEnabled;
    if (analyticsEnabled) {
      _logger.info('Analytics enabled. Thank you!');
    } else {
      _logger.info('Analytics disabled.');
    }
  }

  void _runDoctor() {
    DoctorCommand(logger: _logger, platform: _platform).run();
  }

  bool _wantsUpdateCheck(String? commandName) {
    if (_isCI) {
      // We don't want to check for updates on CI because of #1282
      return false;
    }

    if (commandName == 'update' || commandName == 'doctor') {
      return false;
    }

    return true;
  }

  /// Checks if the current version (set by the build runner on the version.dart
  /// file) is the most recent one. If not, shows a prompt to the user.
  Future<void> _checkForUpdate(String? commandName) async {
    if (commandName == 'update' || commandName == 'doctor') {
      return;
    }

    final latestVersion = await _pubUpdater.getLatestVersion('patrol_cli');
    final isUpToDate = constants.version == latestVersion;

    if (isUpToDate) {
      return;
    }

    _logger
      ..info('')
      ..info(
        '''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(constants.version)} \u2192 ${lightCyan.wrap(latestVersion)}
Run ${lightCyan.wrap('patrol update')} to update''',
      )
      ..info('');
  }
}
