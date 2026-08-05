import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/setup_validator/presenter.dart';
import 'package:patrol_cli/src/setup_validator/setup_validator.dart';
import 'package:platform/platform.dart';

class ValidateCommand extends PatrolCommand {
  ValidateCommand({
    required Directory projectRoot,
    required Platform platform,
    required Logger logger,
    @visibleForTesting SetupValidator? setupValidator,
  }) : _projectRoot = projectRoot,
       _platform = platform,
       _logger = logger,
       _setupValidator = setupValidator {
    argParser
      ..addMultiOption(
        'platform',
        aliases: ['platforms'],
        help: 'Platforms to validate. If empty, all declared are validated.',
        allowed: ['android', 'ios', 'macos'],
        valueHelp: 'android,ios',
      )
      ..addFlag(
        'quiet',
        help: 'Suppress notices; print only errors and warnings.',
        negatable: false,
      );
  }

  final Directory _projectRoot;
  final Platform _platform;
  final Logger _logger;
  final SetupValidator? _setupValidator;

  @override
  String get name => 'validate';

  @override
  String get description =>
      'Validate that this project completed the Patrol setup.';

  @override
  Future<int> run() async {
    if (!_projectRoot.childFile('pubspec.yaml').existsSync()) {
      _logger.err(
        'No pubspec.yaml found. Run `patrol validate` inside a Flutter '
        'project.',
      );
      return 1;
    }

    final platforms = stringsArg('platform');
    final validator =
        _setupValidator ??
        SetupValidator(
          projectRoot: _projectRoot,
          platform: _platform,
          flutterExecutable: flutterCommand.executable,
        );
    final report = validator.validate(
      platformFilter: platforms.isEmpty ? null : platforms.toSet(),
    );

    ValidationPresenter(
      logger: _logger,
    ).present(report, quiet: boolArg('quiet'));

    return report.hasErrors ? 1 : 0;
  }
}
