import 'dart:io';

import 'package:path/path.dart' as path;

String getArtifactPath() {
  final home = getHomePath();
  final installPath = path.join(home, '.maestro');

  if (!Directory(installPath).existsSync()) {
    Directory(installPath).createSync();
  }

  return installPath;
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
