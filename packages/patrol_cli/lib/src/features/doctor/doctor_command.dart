import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';

class DoctorCommand extends Command<int> {
  DoctorCommand({
    required ArtifactsRepository artifactsRepository,
    required Logger logger,
  })  : _artifactsRepository = artifactsRepository,
        _logger = logger {
    argParser.addFlag(
      'artifact-path',
      help: 'Print only artifact path.',
      negatable: false,
    );
  }

  final ArtifactsRepository _artifactsRepository;
  final Logger _logger;

  @override
  String get name => 'doctor';

  @override
  String get description => 'Print configuration.';

  @override
  Future<int> run() async {
    final artifactPath = _artifactsRepository.artifactPath;

    final artifactPathFlag = argResults?['artifact-path'] as bool?;

    if (artifactPathFlag ?? false) {
      _logger.info(artifactPath);
      return 0;
    }

    final extra = _artifactsRepository.artifactPathSetFromEnv
        ? '(set from ${ArtifactsRepository.artifactPathEnv})'
        : '(default)';

    _logger.info('artifact path: $artifactPath $extra');
    return 0;
  }
}
