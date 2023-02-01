import 'dart:io' show Process;

import 'package:archive/archive.dart';
import 'package:file/file.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show dirname, join;
import 'package:patrol_cli/src/common/constants.dart' show globalVersion;
import 'package:patrol_cli/src/common/extensions/process.dart';
import 'package:platform/platform.dart';

part 'artifacts_repository.freezed.dart';

class Artifacts {
  const Artifacts._();

  // Android

  /// The dummy app under test.
  ///
  /// See also:
  ///  * https://github.com/leancodepl/patrol/pull/465
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

  /// Name of the file once downloaded and extracted.
  String get localFileName {
    var result = name;

    if (version != null) {
      result += '-$version';
    }

    if (ext != null) {
      result += '.$ext';
    }

    return result;
  }

  /// Name of the file while hosted.
  String get remoteFileName {
    if (version == null) {
      throw StateError('unversioned artifacts do not have remoteFileName');
    }

    return map(
      file: (artifact) => artifact.localFileName,
      archive: (archive) => '$name-$version.zip',
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
    return Uri.parse(
      '$repo/releases/download/patrol_cli-v$version/$remoteFileName',
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

  bool get artifactPathSetFromEnv {
    return platform.environment.containsKey(artifactPathEnv);
  }

  String get artifactPath {
    final env = platform.environment;
    String p;
    if (artifactPathSetFromEnv) {
      p = env[artifactPathEnv]!;
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

  String get serverArtifactPath {
    final artifact = debug ? Artifacts.androidApp.debug : Artifacts.androidApp;

    return join(artifactPath, artifact.localFileName);
  }

  String get instrumentationArtifactPath {
    final artifact = debug
        ? Artifacts.androidInstrumentation.debug
        : Artifacts.androidInstrumentation;

    return join(artifactPath, artifact.localFileName);
  }

  String get iosPath {
    final artifact = debug ? Artifacts.ios.debug : Artifacts.ios;

    return join(artifactPath, artifact.localFileName);
  }

  String get iosDevicePath {
    final artifact = debug ? Artifacts.iosDevice.debug : Artifacts.iosDevice;

    return join(artifactPath, artifact.localFileName);
  }

  /// Returns path to the iOS artifact appropriate for the architecture of the
  /// machine.
  ///
  /// Known issues on Apple Silicon:
  ///
  /// * If Simulator.app is run with Rosetta 2, then artifact for x86_64
  ///   architecture is used, and it won't work
  ///
  /// * If Terminal.app is run with Rosetta 2, then artifact for x86_64
  ///   architecture is used even if the Simulator.app is running without
  ///   Rosetta 2, and it won't work
  String get iosSimulatorPath {
    final processResult = Process.runSync('uname', ['-m']);
    final arch = processResult.stdOut.trim();
    if (arch == 'arm64') {
      return iosSimulatorArmPath;
    } else if (arch == 'x86_64') {
      return iosSimulatorAmdPath;
    } else {
      throw StateError('architecture $arch is not supported');
    }
  }

  String get iosSimulatorArmPath {
    final artifact =
        debug ? Artifacts.iosSimulatorArm.debug : Artifacts.iosSimulatorArm;

    return join(artifactPath, artifact.localFileName);
  }

  String get iosSimulatorAmdPath {
    final artifact =
        debug ? Artifacts.iosSimulatorAmd.debug : Artifacts.iosSimulatorAmd;

    return join(artifactPath, artifact.localFileName);
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

  /// Downloads and extracts artifacts for [version] of patrol_cli.
  Future<void> downloadArtifacts({String? version = globalVersion}) async {
    final androidArtifacts = [
      Artifacts.androidApp,
      Artifacts.androidInstrumentation,
    ].map((artifact) => artifact.copyWith(version: version));

    final iosArtifacts = [
      Artifacts.ios,
      Artifacts.iosDevice,
      Artifacts.iosSimulatorArm,
      Artifacts.iosSimulatorAmd,
    ].map((artifact) => artifact.copyWith(version: version));

    await Future.wait<void>([
      ...androidArtifacts.map(_downloadArtifact),
      if (platform.isMacOS) ...[
        ...iosArtifacts.map(_downloadArtifact),
      ],
    ]);

    if (platform.isMacOS) {
      await Future.wait<void>(iosArtifacts.map(_extractArtifact));
    }
  }

  Future<void> _downloadArtifact(Artifact artifact) async {
    final response = await _httpClient.get(artifact.uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to download $artifact from ${artifact.uri}');
    }

    final p = join(artifactPath, artifact.remoteFileName);
    _createFileRecursively(p).writeAsBytesSync(response.bodyBytes);
  }

  /// Extract the artifact and removes the archive upon completion.
  Future<void> _extractArtifact(Artifact artifact) async {
    final archivePath = join(artifactPath, artifact.remoteFileName);
    final archiveFile = _fs.file(archivePath);
    final bytes = await archiveFile.readAsBytes();
    final archive = _zipDecoder.decodeBytes(bytes);

    var newArtifactPath = artifactPath;
    if (artifact.remoteFileName.startsWith('ios-')) {
      newArtifactPath = join(artifactPath, artifact.localFileName);
    }

    for (final archiveFile in archive) {
      final filename = archiveFile.name;
      final extractPath = join(newArtifactPath, filename);
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

    await archiveFile.delete();
  }

  /// Create a file at [fullPath], recursively creating non-existent
  /// directories.
  File _createFileRecursively(String fullPath) {
    final dirPath = dirname(fullPath);
    _fs.directory(dirPath).createSync(recursive: true);
    return _fs.file(fullPath)..createSync();
  }
}
