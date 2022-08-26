import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:maestro_cli/src/top_level_flags.dart';
import 'package:path/path.dart' as path;

import 'paths.dart' as paths;

class ArtifactsRepository {
  ArtifactsRepository(this._topLevelFlags);

  static const artifactPathEnv = 'MAESTRO_CACHE';

  final TopLevelFlags _topLevelFlags;

  String get serverArtifactPath {
    return _topLevelFlags.debug
        ? paths.debugServerArtifactPath
        : paths.serverArtifactPath;
  }

  String get instrumentationArtifactPath {
    return _topLevelFlags.debug
        ? paths.debugInstrumentationArtifactPath
        : paths.instrumentationArtifactPath;
  }

  String get iosArtifactDirPath {
    return _topLevelFlags.debug
        ? paths.debugIOSArtifactDirPath
        : paths.iosArtifactDirPath;
  }

  /// Returns true if artifacts for the current maestro_cli version are present
  /// in [paths.artifactPath], false otherwise.
  bool areArtifactsPresent() {
    final serverApk = File(paths.serverArtifactPath);
    final instrumentationApk = File(paths.instrumentationArtifactPath);
    final iosDir = Directory(paths.iosArtifactDirPath);

    return serverApk.existsSync() &&
        instrumentationApk.existsSync() &&
        iosDir.existsSync();
  }

  /// Same as [areArtifactsPresent] but looks for unversioned artifacts instead.
  bool areDebugArtifactsPresent() {
    final serverApk = File(paths.debugServerArtifactPath);
    final instrumentationApk = File(paths.debugInstrumentationArtifactPath);
    final iosDir = Directory(paths.debugIOSArtifactDirPath);

    return serverApk.existsSync() &&
        instrumentationApk.existsSync() &&
        iosDir.existsSync();
  }

  /// Downloads artifacts for the current maestro_cli version.
  ///
  /// On iOS, this also does `pod install`.
  Future<void> downloadArtifacts() async {
    final wantsIos = Platform.isMacOS;

    await Future.wait<void>([
      _downloadArtifact(paths.serverArtifactFile),
      _downloadArtifact(paths.instrumentationArtifactFile),
      if (wantsIos) _downloadArtifact(paths.iosArtifactZip),
    ]);

    if (!wantsIos) {
      return;
    }

    final bytes = await File(paths.iosArtifactZipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final archiveFile in archive) {
      final filename = archiveFile.name;
      final extractPath =
          paths.iosArtifactDirPath + Platform.pathSeparator + filename;
      if (archiveFile.isFile) {
        final data = archiveFile.content as List<int>;
        final newFile = File(extractPath);
        await newFile.create(recursive: true);
        await newFile.writeAsBytes(data);
      } else {
        final directory = Directory(extractPath);
        await directory.create(recursive: true);
      }
    }

    await Process.run(
      'pod',
      ['install'],
      runInShell: true,
      workingDirectory: paths.iosArtifactDirPath,
    );
  }

  Future<void> _downloadArtifact(String artifact) async {
    final uri = paths.getUriForArtifact(artifact);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw HttpException('Failed to download file from $uri');
    }

    final p = path.join(paths.artifactPath, artifact);
    _createFileRecursively(p).writeAsBytesSync(response.bodyBytes);
  }

  /// Create a file at [fullPath], recursively creating non-existent
  /// directories.
  File _createFileRecursively(String fullPath) {
    final dirPath = path.dirname(fullPath);
    Directory(dirPath).createSync(recursive: true);
    return File(fullPath)..createSync();
  }
}
