import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';

String get serverArtifact => 'server-$version';
String get serverArtifactFile => '$serverArtifact.apk';

String get instrumentationArtifact => 'instrumentation-$version';
String get instrumentationArtifactFile => '$instrumentationArtifact.apk';

String get iosArtifactDir => 'ios-$version';
String get iosArtifactZip => 'ios-$version.zip';

String get debugServerArtifactFile => 'server.apk';
String get debugInstrumentationArtifactFile => 'instrumentation.apk';
String get debugIOSArtifactDir => 'ios';

/// Returns a URI where [artifact] can be downloaded from.
///
/// [artifact] must be in the form of `$artifact-$version.$extension`, for
/// example: `server-1.0.0.apk` or `ios-4.2.0.zip`.
Uri getUriForArtifact(String artifact) {
  return Uri.parse(
    'https://lncdmaestrostorage.blob.core.windows.net/artifacts/$artifact',
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

String get iosArtifactZipPath {
  return path.join(artifactPath, iosArtifactZip);
}

String get iosArtifactDirPath {
  return path.join(artifactPath, iosArtifactDir);
}

String get debugIOSArtifactDirPath {
  return path.join(artifactPath, debugIOSArtifactDir);
}



String get artifactPath {
  final env = Platform.environment;
  String p;
  if (env.containsKey(env)) {
    p = env[env]!;
  } else {
    p = _defaultArtifactPath;
  }

  return p;
}

String get _defaultArtifactPath {
  return path.join(_homeDirPath, '.cache', 'patrol');
}

String get _homeDirPath {
  final envVars = Platform.environment;
  if (Platform.isMacOS) {
    return envVars['HOME']!;
  } else if (Platform.isLinux) {
    return envVars['HOME']!;
  } else if (Platform.isWindows) {
    return envVars['UserProfile']!;
  } else {
    throw Exception('Cannot find home directory. Unsupported platform');
  }
}
