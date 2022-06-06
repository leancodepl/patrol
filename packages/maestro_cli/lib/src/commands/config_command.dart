import 'package:args/command_runner.dart';

import '../common/common.dart';

class ConfigCommand extends Command<int> {
  @override
  String get name => 'config';

  @override
  String get description => 'Show configuration.';

  @override
  Future<int> run() async {
    final extra = artifactPathSetFromEnv
        ? '(set from $maestroArtifactPathEnv)'
        : '(default)';

    log.info('artifact path: $artifactPath $extra');
    return 0;
  }
}
