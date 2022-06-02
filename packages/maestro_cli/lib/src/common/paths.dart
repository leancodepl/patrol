import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:maestro_cli/src/common/common.dart';
import 'package:path/path.dart' as path;

String get serverArtifact => 'server-$version';
String get instrumentationArtifact => 'instrumentation-$version';

String get serverArtifactFile => '$serverArtifact.apk';
String get instrumentationArtifactFile => '$instrumentationArtifact.apk';

String get serverArtifactPath {
  return path.join(artifactsPath, serverArtifactFile);
}

String get instrumentationArtifactPath {
  return path.join(artifactsPath, instrumentationArtifactFile);
}

/// Returns true if artifacts for the current [version] are present in
/// [artifactsPath], false otherwise.
bool areArtifactsPresent() {
  final serverApk = File(serverArtifactPath);
  final instrumentationApk = File(instrumentationArtifactPath);

  return serverApk.existsSync() && instrumentationApk.existsSync();
}

/// Downloads artifacts for the current maestro [version].
Future<void> downloadArtifacts() async {
  await _downloadArtifact(serverArtifact);
  await _downloadArtifact(instrumentationArtifact);
}

Future<void> _downloadArtifact(String artifact) async {
  final uri = _getArtifactUriForVersion(artifact);
  final response = await http.get(uri);

  final artifactPath = path.join(artifactsPath, '$artifact.apk');
  File(artifactPath).writeAsBytesSync(response.bodyBytes);
}

String get artifactsPath {
  final home = _getHomePath();
  final installPath = path.join(home, '.maestro');

  if (!Directory(installPath).existsSync()) {
    Directory(installPath).createSync();
  }

  return installPath;
}

String _getHomePath() {
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

/// [artifact] must be in the form of `$artifact-$version`, for example:
/// `server-1.0.0`.
Uri _getArtifactUriForVersion(String artifact) {
  return Uri.parse(
    'https://lncdmaestrostorage.blob.core.windows.net/artifacts/$artifact.apk',
  );
}
