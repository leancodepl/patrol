import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:maestro_cli/src/common/constants.dart';
import 'package:maestro_cli/src/common/paths.dart' as paths;
import 'package:path/path.dart' as path;

/// Returns true if artifacts for the current [version] are present in
/// `artifactPath`, false otherwise.
bool areArtifactsPresent() {
  final serverApk = File(paths.serverArtifactPath);
  final instrumentationApk = File(paths.instrumentationArtifactPath);

  return serverApk.existsSync() && instrumentationApk.existsSync();
}

/// Downloads artifacts for the current maestro [version].
Future<void> downloadArtifacts() async {
  await Future.wait<void>([
    _downloadArtifact(paths.serverArtifact),
    _downloadArtifact(paths.instrumentationArtifact)
  ]);
}

Future<void> _downloadArtifact(String artifact) async {
  final uri = paths.getUriForArtifact(artifact);
  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw HttpException('Failed to download file from $uri');
  }

  final p = path.join(paths.artifactPath, '$artifact.apk');
  _createFileRecursively(p).writeAsBytesSync(response.bodyBytes);
}

/// Create a file at [fullPath], recursively creating non-existent directories.
File _createFileRecursively(String fullPath) {
  final dirPath = path.dirname(fullPath);
  Directory(dirPath).createSync(recursive: true);
  return File(fullPath)..createSync();
}
