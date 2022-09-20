import 'package:archive/archive.dart';
import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show join, dirname;
import 'package:platform/platform.dart';

import 'paths.dart' as paths;

class ArtifactsRepository {
  ArtifactsRepository({
    required FileSystem fs,
    required Platform platform,
    required this.useDebugArtifacts,
  })  : _fs = fs,
        _platform = platform;

  static const artifactPathEnv = 'PATROL_CACHE';

  final FileSystem _fs;
  final Platform _platform;
  final bool useDebugArtifacts;

  String get serverArtifactPath {
    return useDebugArtifacts
        ? paths.debugServerArtifactPath
        : paths.serverArtifactPath;
  }

  String get instrumentationArtifactPath {
    return useDebugArtifacts
        ? paths.debugInstrumentationArtifactPath
        : paths.instrumentationArtifactPath;
  }

  String get iosArtifactDirPath {
    return useDebugArtifacts
        ? paths.debugIOSArtifactDirPath
        : paths.iosArtifactDirPath;
  }

  /// Returns true if artifacts for the current patrol_cli version are present
  /// in [paths.artifactPath], false otherwise.
  bool areArtifactsPresent() {
    final serverApk = _fs.file(paths.serverArtifactPath);
    final instrumentationApk = _fs.file(paths.instrumentationArtifactPath);
    final iosDir = _fs.directory(paths.iosArtifactDirPath);

    return serverApk.existsSync() &&
        instrumentationApk.existsSync() &&
        iosDir.existsSync();
  }

  /// Same as [areArtifactsPresent] but looks for unversioned artifacts instead.
  bool areDebugArtifactsPresent() {
    final serverApk = _fs.file(paths.debugServerArtifactPath);
    final instrumentationApk = _fs.file(paths.debugInstrumentationArtifactPath);
    final iosDir = _fs.directory(paths.debugIOSArtifactDirPath);

    return serverApk.existsSync() &&
        instrumentationApk.existsSync() &&
        iosDir.existsSync();
  }

  /// Downloads artifacts for the current patrol_cli version.
  Future<void> downloadArtifacts() async {
    final wantsIos = _platform.isMacOS;

    await Future.wait<void>([
      _downloadArtifact(paths.serverArtifactFile),
      _downloadArtifact(paths.instrumentationArtifactFile),
      if (wantsIos) _downloadArtifact(paths.iosArtifactZip),
    ]);

    if (!wantsIos) {
      return;
    }

    final bytes = await _fs.file(paths.iosArtifactZipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final archiveFile in archive) {
      final filename = archiveFile.name;
      final extractPath =
          paths.iosArtifactDirPath + _platform.pathSeparator + filename;
      if (archiveFile.isFile) {
        final data = archiveFile.content as List<int>;
        final newFile = _fs.file(extractPath);
        await newFile.create(recursive: true);
        await newFile.writeAsBytes(data);
      } else {
        final directory = _fs.directory(extractPath);
        await directory.create(recursive: true);
      }
    }
  }

  Future<void> _downloadArtifact(String artifact) async {
    final uri = paths.getUriForArtifact(artifact);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to download $artifact from $uri');
    }

    final p = join(paths.artifactPath, artifact);
    _createFileRecursively(p).writeAsBytesSync(response.bodyBytes);
  }

  /// Create a file at [fullPath], recursively creating non-existent
  /// directories.
  File _createFileRecursively(String fullPath) {
    final dirPath = dirname(fullPath);
    _fs.directory(dirPath).createSync(recursive: true);
    return _fs.file(fullPath)..createSync();
  }
}
