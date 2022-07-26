import 'dart:io';

import 'package:maestro_cli/src/common/common.dart';
import 'package:path/path.dart' as path;

const maestroArtifactPathEnv = 'MAESTRO_CACHE';

String get serverArtifact => 'server-$version';
String get instrumentationArtifact => 'instrumentation-$version';
String get serverArtifactFile => '$serverArtifact.apk';
String get instrumentationArtifactFile => '$instrumentationArtifact.apk';

String get debugServerArtifactFile => 'server.apk';
String get debugInstrumentationArtifactFile => 'instrumentation.apk';

/// [artifact] must be in the form of `$artifact-$version`, for example:
/// `server-1.0.0`.
Uri getUriForArtifact(String artifact) {
  return Uri.parse(
    'https://lncdmaestrostorage.blob.core.windows.net/artifacts/$artifact.apk',
  );
}

String get serverArtifactPath {
  return path.join(artifactPath, serverArtifactFile);
}

String get debugServerArtifactPath {
  return path.join(artifactPath, debugServerArtifactFile);
}

String get instrumentationArtifactPath {
  return path.join(artifactPath, instrumentationArtifactFile);
}

String get debugInstrumentationArtifactPath {
  return path.join(artifactPath, debugInstrumentationArtifactFile);
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
