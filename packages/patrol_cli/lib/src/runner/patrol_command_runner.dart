import 'dart:io' show ProcessSignal;

import 'package:adb/adb.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:patrol_cli/src/base/constants.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/commands/build_command.dart';
import 'package:patrol_cli/src/commands/devices_command.dart';
import 'package:patrol_cli/src/commands/doctor_command.dart';
import 'package:patrol_cli/src/commands/test_command.dart';
import 'package:patrol_cli/src/commands/update_command.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/run_commons/dart_defines_reader.dart';
import 'package:patrol_cli/src/features/run_commons/test_finder.dart';
import 'package:patrol_cli/src/features/test/android_test_backend.dart';
import 'package:patrol_cli/src/features/test/ios_deploy.dart';
import 'package:patrol_cli/src/features/test/ios_test_backend.dart';
import 'package:patrol_cli/src/features/test/native_test_runner.dart';
import 'package:patrol_cli/src/features/test/pubspec_reader.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:pub_updater/pub_updater.dart';

Future<int> patrolCommandRunner(List<String> args) async {
  final logger = Logger();
  final runner = PatrolCommandRunner(logger: logger);

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

class PatrolCommandRunner extends CompletionCommandRunner<int> {
  PatrolCommandRunner({
    required Logger logger,
    PubUpdater? pubUpdater,
    FileSystem? fs,
    ProcessManager? processManager,
    Platform? platform,
  })  : _disposeScope = DisposeScope(),
        _platform = platform ?? const LocalPlatform(),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        _fs = fs ?? const LocalFileSystem(),
        _processManager = processManager ??
            LoggingLocalProcessManager(
              logger: logger,
            ),
        _logger = logger,
        super(
          'patrol',
          'Tool for running Flutter-native UI tests with superpowers',
        ) {
    addCommand(
      BuildCommand(
        testFinder: TestFinder(testDir: _fs.directory('integration_test')),
        dartDefinesReader: DartDefinesReader(projectRoot: _fs.currentDirectory),
        pubspecReader: PubspecReader(projectRoot: _fs.currentDirectory),
        androidTestBackend: AndroidTestBackend(
          adb: Adb(),
          processManager: _processManager,
          platform: _platform,
          fs: _fs,
          parentDisposeScope: _disposeScope,
          logger: _logger,
        ),
        iosTestBackend: IOSTestBackend(
          processManager: _processManager,
          fs: _fs,
          iosDeploy: IOSDeploy(
            processManager: _processManager,
            parentDisposeScope: _disposeScope,
            fs: _fs,
            logger: _logger,
          ),
          parentDisposeScope: _disposeScope,
          logger: _logger,
        ),
        logger: _logger,
      ),
    );

    addCommand(
      TestCommand(
        deviceFinder: DeviceFinder(
          processManager: _processManager,
          parentDisposeScope: _disposeScope,
          logger: _logger,
        ),
        testFinder: TestFinder(testDir: _fs.directory('integration_test')),
        testRunner: NativeTestRunner(),
        dartDefinesReader: DartDefinesReader(projectRoot: _fs.currentDirectory),
        pubspecReader: PubspecReader(projectRoot: _fs.currentDirectory),
        androidTestBackend: AndroidTestBackend(
          adb: Adb(),
          processManager: _processManager,
          platform: _platform,
          fs: _fs,
          parentDisposeScope: _disposeScope,
          logger: _logger,
        ),
        iosTestBackend: IOSTestBackend(
          processManager: _processManager,
          fs: _fs,
          iosDeploy: IOSDeploy(
            processManager: _processManager,
            parentDisposeScope: _disposeScope,
            fs: _fs,
            logger: _logger,
          ),
          parentDisposeScope: _disposeScope,
          logger: _logger,
        ),
        parentDisposeScope: _disposeScope,
        logger: _logger,
      ),
    );

    addCommand(
      DevicesCommand(
        deviceFinder: DeviceFinder(
          processManager: _processManager,
          parentDisposeScope: _disposeScope,
          logger: _logger,
        ),
        logger: _logger,
      ),
    );
    addCommand(
      DoctorCommand(
        logger: _logger,
        platform: _platform,
      ),
    );
    addCommand(UpdateCommand(logger: _logger, pubUpdater: _pubUpdater));

    argParser
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

  // Context of the tool, used through the codebase
  // TODO: Encapsulate these objects in a context object

  final DisposeScope _disposeScope;
  final Platform _platform;
  final FileSystem _fs;
  final ProcessManager _processManager;
  final Logger _logger;

  final PubUpdater _pubUpdater;

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
  String? get usageFooter => '''
Read documentation at https://patrol.leancode.pl
Report bugs, request features at https://github.com/leancodepl/patrol/issues
Ask questions, get support at https://github.com/leancodepl/patrol/discussions''';

  @override
  Future<int?> run(Iterable<String> args) async {
    var verbose = false;

    int exitCode;
    try {
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
      exitCode = err.exitCode;
    } on ToolInterrupted catch (err, st) {
      if (verbose) {
        _logger
          ..err('$err')
          ..err('$st');
      } else {
        _logger.err(err.message);
      }
      exitCode = err.exitCode;
    } on FormatException catch (err, st) {
      _logger
        ..err(err.message)
        ..err('$st')
        ..info('')
        ..info(usage);
      exitCode = 1;
    } on UsageException catch (err) {
      _logger
        ..err(err.message)
        ..info('')
        ..info(err.usage);
      exitCode = 1;
    } on FileSystemException catch (err, st) {
      _logger
        ..err('${err.message}: ${err.path}')
        ..err('$err')
        ..err('$st');
      exitCode = 1;
    } catch (err, st) {
      _logger
        ..err('$err')
        ..err('$st');
      exitCode = 1;
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
      _logger.info('patrol_cli v$version');
      exitCode = 0;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }

    return exitCode;
  }

  @override
  void printUsage() => _logger.info(usage);

  bool _wantsUpdateCheck(String? commandName) {
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
    final isUpToDate = version == latestVersion;

    if (isUpToDate) {
      return;
    }

    _logger
      ..info('')
      ..info(
        '''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(version)} \u2192 ${lightCyan.wrap(latestVersion)}
Run ${lightCyan.wrap('patrol update')} to update''',
      )
      ..info('');
  }
}
