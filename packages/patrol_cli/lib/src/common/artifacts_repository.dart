import 'package:archive/archive.dart';
import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show join, dirname;
import 'package:patrol_cli/src/common/constants.dart' show version;
import 'package:patrol_cli/src/top_level_flags.dart';
import 'package:platform/platform.dart';

class ArtifactsRepository {
  ArtifactsRepository({
    required FileSystem fs,
    required Platform platform,
    required TopLevelFlags topLevelFlags,
  })  : _fs = fs,
        _platform = platform,
        _topLevelFlags = topLevelFlags {
    _paths = _Paths(artifactPath);
  }

  static const artifactPathEnv = 'PATROL_CACHE';

  final FileSystem _fs;
  final Platform _platform;
  final TopLevelFlags _topLevelFlags;

  late final _Paths _paths;

  String get artifactPath {
    final env = _platform.environment;
    String p;
    if (env.containsKey(env)) {
      p = env[env]!;
    } else {
      p = _defaultArtifactPath;
    }

    return p;
  }

  String get _defaultArtifactPath => join(_homeDirPath, '.cache', 'patrol');

  String get _homeDirPath {
    final envVars = _platform.environment;
    if (_platform.isMacOS) {
      return envVars['HOME']!;
    } else if (_platform.isLinux) {
      return envVars['HOME']!;
    } else if (_platform.isWindows) {
      return envVars['UserProfile']!;
    } else {
      throw Exception('Cannot find home directory. Unsupported platform');
    }
  }

  bool get artifactPathSetFromEnv {
    return _platform.environment.containsKey(artifactPathEnv);
  }

  String get serverArtifactPath {
    return _topLevelFlags.debug
        ? _paths.debugServerArtifactPath
        : _paths.serverArtifactPath;
  }

  String get instrumentationArtifactPath {
    return _topLevelFlags.debug
        ? _paths.debugInstrumentationArtifactPath
        : _paths.instrumentationArtifactPath;
  }

  String get iosArtifactDirPath {
    return _topLevelFlags.debug
        ? _paths.debugIOSArtifactDirPath
        : _paths.iosArtifactDirPath;
  }

  /// Returns true if artifacts for the current patrol_cli version are present
  /// in [artifactPath], false otherwise.
  bool areArtifactsPresent() {
    final serverApk = _fs.file(_paths.serverArtifactPath);
    final instrumentationApk = _fs.file(_paths.instrumentationArtifactPath);
    final iosDir = _fs.directory(_paths.iosArtifactDirPath);

    return serverApk.existsSync() &&
        instrumentationApk.existsSync() &&
        iosDir.existsSync();
  }

  /// Same as [areArtifactsPresent] but looks for unversioned artifacts instead.
  bool areDebugArtifactsPresent() {
    final serverApk = _fs.file(_paths.debugServerArtifactPath);
    final instrumentationApk = _fs.file(
      _paths.debugInstrumentationArtifactPath,
    );
    final iosDir = _fs.directory(_paths.debugIOSArtifactDirPath);

    return serverApk.existsSync() &&
        instrumentationApk.existsSync() &&
        iosDir.existsSync();
  }

  /// Downloads artifacts for the current patrol_cli version.
  Future<void> downloadArtifacts() async {
    final wantsIos = _platform.isMacOS;

    await Future.wait<void>([
      _downloadArtifact(_paths.serverArtifactFile),
      _downloadArtifact(_paths.instrumentationArtifactFile),
      if (wantsIos) _downloadArtifact(_paths.iosArtifactZip),
    ]);

    if (!wantsIos) {
      return;
    }

    final bytes = await _fs.file(_paths.iosArtifactZipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final archiveFile in archive) {
      final filename = archiveFile.name;
      final extractPath =
          _paths.iosArtifactDirPath + _platform.pathSeparator + filename;
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
    final uri = _paths.getUriForArtifact(artifact);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to download $artifact from $uri');
    }

    final p = join(artifactPath, artifact);
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

class _Paths {
  const _Paths(this._artifactPath);

  final String _artifactPath;

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
    return join(_artifactPath, serverArtifactFile);
  }

  String get debugServerArtifactPath {
    return join(_artifactPath, debugServerArtifactFile);
  }

  String get instrumentationArtifactPath {
    return join(_artifactPath, instrumentationArtifactFile);
  }

  String get debugInstrumentationArtifactPath {
    return join(_artifactPath, debugInstrumentationArtifactFile);
  }

  String get iosArtifactZipPath {
    return join(_artifactPath, iosArtifactZip);
  }

  String get iosArtifactDirPath {
    return join(_artifactPath, iosArtifactDir);
  }

  String get debugIOSArtifactDirPath {
    return join(_artifactPath, debugIOSArtifactDir);
  }
}
