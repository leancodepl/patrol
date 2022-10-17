import 'package:archive/archive.dart';
import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show join, dirname;
import 'package:patrol_cli/src/common/constants.dart' show version;
import 'package:platform/platform.dart';

class _Artifact {
  const _Artifact({
    required this.name,
    required this.version,
    required this.ext,
  });

  final String name;
  final String? version;
  final String ext;

  /// Returns a URI where this artifact is hosted.
  Uri get uri {
    final version = this.version;
    if (version == null) {
      throw StateError('cannot get uri for an unversioned artifact');
    }

    return Uri.parse(
      'https://github.com/leancodepl/patrol/releases/download/patrol_cli-v$version/$filename',
    );
  }

  String get filename {
    var result = name;
    if (version != null) {
      result += '-$version';
    }
    result += '.$ext';

    return result;
  }
}

const _androidArtifacts = [
  _Artifact(name: 'server', version: version, ext: '.apk'),
  _Artifact(name: 'instrumentation', version: version, ext: '.apk'),
];

const _iosArtifacts = [
  _Artifact(name: 'ios', version: version, ext: '.zip'),
  _Artifact(
    name: 'AutomatorServer-iphonesimulator-arm64',
    version: version,
    ext: '.zip',
  ),
  _Artifact(
    name: 'AutomatorServer-iphonesimulator-x86_64',
    version: version,
    ext: '.zip',
  ),
];

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
    _paths = _ArtifactPaths(artifactPath);
  }

  static const artifactPathEnv = 'PATROL_CACHE';

  final FileSystem _fs;
  Platform platform;
  final http.Client _httpClient;
  final ZipDecoder _zipDecoder;
  bool debug;

  late final _ArtifactPaths _paths;

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
    return debug ? _paths.iosDirDebugPath : _paths.iosDirPath;
  }

  /// Returns true if artifacts for the current patrol_cli version are present
  /// in [artifactPath], false otherwise.
  bool areArtifactsPresent() {
    final serverApk = _fs.file(serverArtifactPath);
    final instrumentationApk = _fs.file(instrumentationArtifactPath);

    if (platform.isMacOS) {
      final iosDir = _fs.directory(iosArtifactDirPath);
      //final iosSimArmApp = _fs.directory(ios)

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
      _downloadArtifact(_paths.androidServerFile),
      _downloadArtifact(_paths.androidInstrumentationFile),
      if (platform.isMacOS) ...[
        _downloadArtifact(_paths.iosProjectZip),
        _downloadArtifact(_paths.iosAutomatorSimAmdZip),
        _downloadArtifact(_paths.iosAutomatorSimArmZip),
      ],
    ]);

    if (!platform.isMacOS) {
      return;
    }

    final bytes = await _fs.file(_paths.iosZipPath).readAsBytes();
    final archive = _zipDecoder.decodeBytes(bytes);

    for (final archiveFile in archive) {
      final filename = archiveFile.name;
      final extractPath = _paths.iosDirPath + platform.pathSeparator + filename;
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

class _ArtifactPaths {
  const _ArtifactPaths(this._artifactPath);

  final String _artifactPath;

  /// Returns a URI where [artifact] can be downloaded from.
  ///
  /// [artifact] must be in the form of `$artifact-$version.$extension`, for
  /// example: `server-1.0.0.apk` or `ios-4.2.0.zip`.
  Uri getUriForArtifact(String artifact) {
    return Uri.parse(
      'https://github.com/leancodepl/patrol/releases/download/patrol_cli-v$version/$artifact',
    );
  }

  String get androidServerFile => 'server-$version.apk';

  String get androidInstrumentationFile => 'instrumentation-$version.apk';

  String get androidServerDebugFile => 'server.apk';

  String get androidInstrumentationDebugFile => 'instrumentation.apk';

  String get iosProjectDir => 'ios-$version';

  String get iosProjectZip => 'ios-$version.zip';

  String get iosProjectDebugDir => 'ios';

  String get iosAutomatorSimAmdZip {
    return 'AutomatorServer-iphonesimulator-x86_64-$version.zip';
  }

  String get iosAutomatorSimArmZip {
    return 'AutomatorServer-iphonesimulator-arm64-$version.zip';
  }

  String get serverArtifactPath {
    return join(_artifactPath, androidServerFile);
  }

  String get debugServerArtifactPath {
    return join(_artifactPath, androidServerDebugFile);
  }

  String get instrumentationArtifactPath {
    return join(_artifactPath, androidInstrumentationFile);
  }

  String get debugInstrumentationArtifactPath {
    return join(_artifactPath, androidInstrumentationDebugFile);
  }

  String get iosZipPath {
    return join(_artifactPath, iosProjectZip);
  }

  String get iosDirPath {
    return join(_artifactPath, iosProjectDir);
  }

  String get iosDirDebugPath {
    return join(_artifactPath, iosProjectDebugDir);
  }
}
