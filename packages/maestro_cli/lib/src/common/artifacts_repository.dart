import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'paths.dart' as paths;

class ArtifactsRepository {
  static const artifactPathEnv = 'MAESTRO_CACHE';

  String get artifactPath {
    final environment = Platform.environment;
    String p;
    if (environment.containsKey(artifactPathEnv)) {
      p = environment[artifactPathEnv]!;
    } else {
      p = _defaultArtifactPath;
    }

    return p;
  }

  /// Returns true if artifacts for the current maestro_cli version are present
  /// in [artifactPath], false otherwise.
  bool areArtifactsPresent() {
    final serverApk = File(paths.serverArtifactPath);
    final instrumentationApk = File(paths.instrumentationArtifactPath);

    return serverApk.existsSync() && instrumentationApk.existsSync();
  }

  /// Same as [areArtifactsPresent] but looks for unversioned artifacts instead.
  bool areDebugArtifactsPresent() {
    final serverApk = File(paths.debugServerArtifactPath);
    final instrumentationApk = File(paths.debugInstrumentationArtifactPath);

    return serverApk.existsSync() && instrumentationApk.existsSync();
  }

  /// Downloads artifacts for the current maestro_cli version.
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

  String get _defaultArtifactPath => path.join(_homeDirPath, '.maestro');

  String get _homeDirPath {
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

  /// Create a file at [fullPath], recursively creating non-existent
  /// directories.
  File _createFileRecursively(String fullPath) {
    final dirPath = path.dirname(fullPath);
    Directory(dirPath).createSync(recursive: true);
    return File(fullPath)..createSync();
  }
}
