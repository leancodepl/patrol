import 'dart:io';

import 'package:maestro_cli/src/common/common.dart';
import 'package:path/path.dart' as path;

const maestroArtifactPathEnv = 'MAESTRO_ARTIFACT_PATH';

String get serverArtifact => 'server-$version';
String get instrumentationArtifact => 'instrumentation-$version';

String get serverArtifactFile => '$serverArtifact.apk';
String get instrumentationArtifactFile => '$instrumentationArtifact.apk';

/// [artifact] must be in the form of `$artifact-$version`, for example:
/// `server-1.0.0`.
Uri getUriForArtifact(String artifact) {
  return Uri.parse(
    'https://github.com/leancodepl/maestro/releases/download/maestro_cli-v$version/$artifact.apk',
  );
}

String get serverArtifactPath {
  return path.join(artifactPath, serverArtifactFile);
}

String get instrumentationArtifactPath {
  return path.join(artifactPath, instrumentationArtifactFile);
}

bool get artifactPathSetFromEnv {
  return Platform.environment.containsKey(maestroArtifactPathEnv);
}

String get artifactPath {
  final env = Platform.environment;
  String p;
  if (env.containsKey(maestroArtifactPathEnv)) {
    p = env[maestroArtifactPathEnv]!;
  } else {
    p = _defaultArtifactPath;
  }

  return p;
}

String get _defaultArtifactPath => path.join(_homePath, '.maestro');

String get _homePath {
  String? home;
  final envVars = Platform.environment;
  if (Platform.isMacOS) {
    home = envVars['HOME'];
  } else if (Platform.isLinux) {
    home = envVars['HOME'];
  } else if (Platform.isWindows) {
    home = envVars['UserProfile'];
  }

  return home!;
}
