import 'package:archive/archive.dart';
import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show join, dirname;
import 'package:patrol_cli/src/common/constants.dart' show version;
import 'package:platform/platform.dart';

class ArtifactsRepository {
  ArtifactsRepository({
    required FileSystem fs,
    required this.platform,
    http.Client? httpClient,
    ZipDecoder? zipDecoder,
  })  : _fs = fs,
        _httpClient = httpClient ?? http.Client(),
        _zipDecoder = zipDecoder ?? ZipDecoder(),
        debug = false {
    _paths = _Paths(artifactPath);
  }

  static const artifactPathEnv = 'PATROL_CACHE';

  final FileSystem _fs;
  Platform platform;
  final http.Client _httpClient;
  final ZipDecoder _zipDecoder;
  bool debug;

  late final _Paths _paths;

  String get artifactPath {
    final env = platform.environment;
    String p;
    if (env.containsKey(env)) {
      p = env[env]!;
    } else {
      p = _defaultArtifactPath;
    }

    return p;
  }

  Directory get artifactPathDir => _fs.directory(artifactPath);

  String get _defaultArtifactPath => join(_homeDirPath, '.cache', 'patrol');

  String get _homeDirPath {
    final envVars = platform.environment;
    if (platform.isMacOS) {
      return envVars['HOME']!;
    } else if (platform.isLinux) {
      return envVars['HOME']!;
    } else if (platform.isWindows) {
      return envVars['UserProfile']!;
    } else {
      throw Exception('Cannot find home directory. Unsupported platform');
    }
  }

  bool get artifactPathSetFromEnv {
    return platform.environment.containsKey(artifactPathEnv);
  }

  String get serverArtifactPath {
    return debug ? _paths.debugServerArtifactPath : _paths.serverArtifactPath;
  }

  String get instrumentationArtifactPath {
    return debug
        ? _paths.debugInstrumentationArtifactPath
        : _paths.instrumentationArtifactPath;
  }

  String get iosArtifactDirPath {
    return debug ? _paths.debugIOSArtifactDirPath : _paths.iosArtifactDirPath;
  }

  /// Returns true if artifacts for the current patrol_cli version are present
  /// in [artifactPath], false otherwise.
  bool areArtifactsPresent() {
    final serverApk = _fs.file(serverArtifactPath);
    final instrumentationApk = _fs.file(instrumentationArtifactPath);

    if (platform.isMacOS) {
      final iosDir = _fs.directory(iosArtifactDirPath);
      return serverApk.existsSync() &&
          instrumentationApk.existsSync() &&
          iosDir.existsSync();
    } else {
      return serverApk.existsSync() && instrumentationApk.existsSync();
    }
  }

  /// Downloads artifacts for the current patrol_cli version.
  Future<void> downloadArtifacts() async {
    await Future.wait<void>([
      _downloadArtifact(_paths.serverArtifactFile),
      _downloadArtifact(_paths.instrumentationArtifactFile),
      if (platform.isMacOS) _downloadArtifact(_paths.iosArtifactZip),
    ]);

    if (!platform.isMacOS) {
      return;
    }

    final bytes = await _fs.file(_paths.iosArtifactZipPath).readAsBytes();
    final archive = _zipDecoder.decodeBytes(bytes);

    for (final archiveFile in archive) {
      final filename = archiveFile.name;
      final extractPath =
          _paths.iosArtifactDirPath + platform.pathSeparator + filename;
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
    final response = await _httpClient.get(uri);

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
  Uri getUriForArtifact(
    String artifact,
  ) {
    return Uri.parse(
      'https://github.com/leancodepl/patrol/releases/download/patrol_cli-v$version/$artifact',
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
