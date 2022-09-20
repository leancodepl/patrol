import 'package:args/command_runner.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';

class DoctorCommand extends Command<int> {
  DoctorCommand() {
    argParser.addFlag('artifact-path', help: 'Show only artifact path.');
  }

  @override
  String get name => 'doctor';

  @override
  String get description => 'Print configuration.';

  @override
  Future<int> run() async {
    final artifactPathFlag = argResults?['artifact-path'] as bool?;

    if (artifactPathFlag ?? false) {
      log.info(artifactPath);
      return 0;
    }

    final extra = artifactPathSetFromEnv
        ? '(set from ${ArtifactsRepository.artifactPathEnv})'
        : '(default)';

    log.info('artifact path: $artifactPath $extra');
    return 0;
  }
}
