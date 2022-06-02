import 'dart:io';

import 'package:path/path.dart' as path;

const serverApkFileName = 'server.apk';
const instrumentationApkFileName = 'instrumentation.apk';

String getArtifactPath() {
  final home = getHomePath();
  final installPath = path.join(home, '.maestro');

  if (!Directory(installPath).existsSync()) {
    Directory(installPath).createSync();
  }

  return installPath;
}

bool areArtifactsPresent() {
  final artifactPath = getArtifactPath();

  final serverApk = File(path.join(artifactPath, serverApkFileName));

  final instrumentationApk = File(
    path.join(artifactPath, instrumentationApkFileName),
  );

  return serverApk.existsSync() && instrumentationApk.existsSync();
}

String getHomePath() {
  String? home = '';
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
