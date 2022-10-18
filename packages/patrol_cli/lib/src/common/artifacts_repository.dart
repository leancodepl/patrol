import 'package:archive/archive.dart';
import 'package:file/file.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show join, dirname;
import 'package:patrol_cli/src/common/constants.dart' show globalVersion;
import 'package:platform/platform.dart';

part 'artifacts_repository.freezed.dart';

class Artifacts {
  const Artifacts._();

  // Android

  // The dummy app under test.
  static const androidApp = Artifact.file(
    name: 'server',
    version: globalVersion,
    ext: 'apk',
  );

  static const androidInstrumentation = Artifact.file(
    name: 'instrumentation',
    version: globalVersion,
    ext: 'apk',
  );

  // iOS

  @Deprecated('Remove once code signing for iosDevice works')
  static const ios = Artifact.archive(
    name: 'ios',
    version: globalVersion,
  );

  static const iosDevice = Artifact.archive(
    name: 'AutomatorServer-iphoneos-arm64',
    version: globalVersion,
    ext: 'app',
  );

  static const iosSimulatorArm = Artifact.archive(
    name: 'AutomatorServer-iphonesimulator-arm64',
    version: globalVersion,
    ext: 'app',
  );

  static const iosSimulatorAmd = Artifact.archive(
    name: 'AutomatorServer-iphonesimulator-x86_64',
    version: globalVersion,
    ext: 'app',
  );
}

@freezed
class Artifact with _$Artifact {
  const factory Artifact.file({
    required String name,
    String? version,
    String? ext,
  }) = _ArtifactFile;

  const factory Artifact.archive({
    required String name,
    String? version,
    String? ext,
  }) = _ArtifactArchive;

  const Artifact._();

  String get filename {
    var result = name;

    if (version != null) {
      result += '-$version';
    }

    if (ext != null) {
      result += '.$ext';
    }

    return result;
  }

  /// Name of the file that was originally downloaded.
  String get remoteName {
    return map(
      file: (artifact) => artifact.filename,
      archive: (archive) => '$name-$version.zip',
    );
  }

  String get archiveName {
    return map(
      file: (_) => throw StateError(
        'archiveName is not applicable for file artifacts',
      ),
      archive: (artifact) => '${artifact.name}-${artifact.version}.zip',
    );
  }

  /// Returns an unversioned (i.e debug) variant of this artifact.
  Artifact get debug => copyWith(version: null);

  /// Returns a URI where this artifact is hosted.
  Uri get uri {
    final version = this.version;
    if (version == null) {
      throw StateError('cannot get uri for an unversioned artifact');
    }

    const repo = 'https://github.com/leancodepl/patrol';

    return map(
      file: (file) {
        return Uri.parse(
          '$repo/releases/download/patrol_cli-v$version/$filename',
        );
      },
      archive: (archive) {
        return Uri.parse(
          '$repo/releases/download/patrol_cli-v$version/$name-$version.zip',
        );
      },
    );
  }
}

class ArtifactsRepository {
  ArtifactsRepository({
    required FileSystem fs,
    required this.platform,
    http.Client? httpClient,
    ZipDecoder? zipDecoder,
  })  : _fs = fs,
        _httpClient = httpClient ?? http.Client(),
        _zipDecoder = zipDecoder ?? ZipDecoder(),
        debug = false;

  static const artifactPathEnv = 'PATROL_CACHE';

  final FileSystem _fs;
  Platform platform;
  final http.Client _httpClient;
  final ZipDecoder _zipDecoder;
  bool debug;

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
    final artifact = debug ? Artifacts.androidApp.debug : Artifacts.androidApp;

    return join(artifactPath, artifact.filename);
  }

  String get instrumentationArtifactPath {
    final artifact = debug
        ? Artifacts.androidInstrumentation.debug
        : Artifacts.androidInstrumentation;

    return join(artifactPath, artifact.filename);
  }

  String get iosPath {
    final artifact = debug ? Artifacts.ios.debug : Artifacts.ios;

    return join(artifactPath, artifact.filename);
  }

  String get iosDevicePath {
    final artifact = debug ? Artifacts.iosDevice.debug : Artifacts.iosDevice;

    return join(artifactPath, artifact.filename);
  }

  String get iosSimulatorArmPath {
    final artifact =
        debug ? Artifacts.iosSimulatorArm.debug : Artifacts.iosSimulatorArm;

    return join(artifactPath, artifact.filename);
  }

  String get iosSimulatorAmdPath {
    final artifact =
        debug ? Artifacts.iosSimulatorAmd.debug : Artifacts.iosSimulatorAmd;

    return join(artifactPath, artifact.filename);
  }

  /// Returns true if artifacts for the current patrol_cli version are present
  /// in [artifactPath], false otherwise.
  bool areArtifactsPresent() {
    final serverApk = _fs.file(serverArtifactPath);
    final instrumentationApk = _fs.file(instrumentationArtifactPath);

    final androidArtifactsExist =
        serverApk.existsSync() && instrumentationApk.existsSync();

    if (platform.isMacOS) {
      final iosDir = _fs.directory(iosPath);
      final iosDeviceDir = _fs.directory(iosDevicePath);
      final iosSimArmDir = _fs.directory(iosSimulatorArmPath);
      final iosSimAmdDir = _fs.directory(iosSimulatorAmdPath);

      final iosArtifactsExist = iosDir.existsSync() &&
          iosDeviceDir.existsSync() &&
          iosSimArmDir.existsSync() &&
          iosSimAmdDir.existsSync();

      return androidArtifactsExist && iosArtifactsExist;
    } else {
      return androidArtifactsExist;
    }
  }

  /// Downloads artifacts for the current patrol_cli version.
  Future<void> downloadArtifacts({String? ver}) async {
    ver ??= globalVersion;

    await Future.wait<void>([
      _downloadArtifact(Artifacts.androidApp.copyWith(version: ver)),
      _downloadArtifact(
        Artifacts.androidInstrumentation.copyWith(version: ver),
      ),
      if (platform.isMacOS) ...[
        _downloadArtifact(Artifacts.ios),
        _downloadArtifact(Artifacts.iosDevice),
        _downloadArtifact(Artifacts.iosSimulatorArm),
        _downloadArtifact(Artifacts.iosSimulatorAmd),
      ],
    ]);

    if (platform.isMacOS) {
      await _extractArtifact(Artifacts.ios);
      await _extractArtifact(Artifacts.iosDevice);
      await _extractArtifact(Artifacts.iosSimulatorArm);
      await _extractArtifact(Artifacts.iosSimulatorAmd);
    }
  }

  Future<void> _downloadArtifact(Artifact artifact) async {
    final response = await _httpClient.get(artifact.uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to download $artifact from ${artifact.uri}');
    }

    final p = join(artifactPath, artifact.remoteName);
    _createFileRecursively(p).writeAsBytesSync(response.bodyBytes);
  }

  Future<void> _extractArtifact(Artifact artifact) async {
    final archievePath = join(artifactPath, artifact.archiveName);
    final bytes = await _fs.file(archievePath).readAsBytes();
    final archive = _zipDecoder.decodeBytes(bytes);

    for (final archiveFile in archive) {
      final filename = archiveFile.name;
      final extractPath = join(artifactPath, filename);
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

  /// Create a file at [fullPath], recursively creating non-existent
  /// directories.
  File _createFileRecursively(String fullPath) {
    final dirPath = dirname(fullPath);
    _fs.directory(dirPath).createSync(recursive: true);
    return _fs.file(fullPath)..createSync();
  }
}

/* class _ArtifactPaths {
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
 */
