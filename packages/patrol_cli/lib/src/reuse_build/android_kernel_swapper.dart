import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:version/version.dart';

/// The app and androidTest APKs of one Android build.
class AndroidApks {
  const AndroidApks({required this.app, required this.test});

  final File app;
  final File test;

  /// Finds the APKs `patrol build android` (or `patrol test`) wrote for
  /// [buildMode] (lowercase, e.g. `debug`) and [flavor], or returns `null`.
  static AndroidApks? locateBuilt(
    Directory rootDirectory, {
    required String buildMode,
    String? flavor,
  }) {
    final apkDir = rootDirectory
        .childDirectory('build')
        .childDirectory('app')
        .childDirectory('outputs')
        .childDirectory('apk');
    if (!apkDir.existsSync()) {
      return null;
    }

    File? app;
    File? test;
    for (final entity in apkDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.apk')) {
        continue;
      }
      final segments = p.split(p.relative(entity.path, from: apkDir.path));
      if (!segments.contains(buildMode)) {
        continue;
      }
      // A flavor's (case-sensitive) directory is in both APK paths. Without a
      // flavor, APKs of flavored builds sit one level deeper.
      if (flavor != null && !segments.contains(flavor)) {
        continue;
      }
      final inAndroidTestDir = segments.contains('androidTest');
      if (flavor == null && segments.length != (inAndroidTestDir ? 3 : 2)) {
        continue;
      }
      if (entity.path.endsWith('-androidTest.apk')) {
        test ??= entity;
      } else if (!inAndroidTestDir) {
        app ??= entity;
      }
    }
    if (app == null || test == null) {
      return null;
    }
    return AndroidApks(app: app, test: test);
  }

  /// Finds exactly one app APK and one `*-androidTest.apk` in [dir], as
  /// written by `patrol build android` and `patrol build android --develop`.
  // ignore: prefer_constructors_over_static_methods
  static AndroidApks fromDirectory(Directory dir) {
    if (!dir.existsSync()) {
      throwToolExit('Directory with prebuilt APKs does not exist: ${dir.path}');
    }
    final appApks = <File>[];
    final testApks = <File>[];
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.apk')) {
        continue;
      }
      if (entity.path.endsWith('-androidTest.apk')) {
        testApks.add(entity);
      } else {
        appApks.add(entity);
      }
    }
    if (appApks.length != 1 || testApks.length != 1) {
      final found = [...appApks, ...testApks].map((f) => f.path).join(', ');
      throwToolExit(
        'Expected exactly one app APK and one *-androidTest.apk in '
        '${dir.path} (found: ${found.isEmpty ? 'none' : found}).',
      );
    }
    return AndroidApks(app: appApks.single, test: testApks.single);
  }
}

/// Puts a freshly compiled `kernel_blob.bin` into an existing debug APK,
/// so the tests run without Gradle.
///
/// The androidTest APK holds no Dart code, so it is only signed again: an
/// instrumentation must be signed with the same key as the app it tests.
/// Both are signed with the Android debug key.
class AndroidKernelSwapper {
  AndroidKernelSwapper({
    required this._processManager,
    required this._platform,
    required this._rootDirectory,
    required this._logger,
  });

  static const kernelEntry = 'assets/flutter_assets/kernel_blob.bin';

  final ProcessManager _processManager;
  final NativePlatform _platform;
  final Directory _rootDirectory;
  final Logger _logger;

  /// Writes the patched APKs into [outputDir] and returns them.
  ///
  /// [javaHome] is asked for only when `JAVA_HOME` isn't set, as `apksigner`
  /// needs Java.
  Future<AndroidApks> swap({
    required AndroidApks base,
    required File kernel,
    required Directory outputDir,
    required Future<String?> Function() javaHome,
  }) async {
    if (_platform.isWindows) {
      throwToolExit('--reuse-build is not supported on Windows hosts yet.');
    }
    final buildTools = _buildToolsDirectory();
    final keystore = _debugKeystore();
    final environment = <String, String>{
      if (_platform.environment['JAVA_HOME'] == null)
        'JAVA_HOME': ?await javaHome(),
    };

    final task = _logger.task('Putting the compiled Dart code into the APK');
    if (outputDir.existsSync()) {
      outputDir.deleteSync(recursive: true);
    }
    final staging = outputDir.childDirectory('staging');
    final stagedKernel = staging.fileSystem.file(
      p.join(staging.path, kernelEntry),
    )..parent.createSync(recursive: true);
    kernel.copySync(stagedKernel.path);

    final unaligned = base.app.copySync(
      outputDir.childFile('app-unaligned.apk').path,
    );
    final aligned = outputDir.childFile('app-aligned.apk');
    final app = outputDir.childFile(p.basename(base.app.path));
    final test = outputDir.childFile(p.basename(base.test.path));

    try {
      // `zip` replaces the entry in place and copies the others as they are.
      await _run([
        'zip',
        '-q',
        unaligned.path,
        kernelEntry,
      ], workingDirectory: staging.path);
      await _run([
        p.join(buildTools.path, 'zipalign'),
        ...['-f', '-p', '4'],
        unaligned.path,
        aligned.path,
      ]);
      for (final (input, output) in [(aligned, app), (base.test, test)]) {
        await _run([
          p.join(buildTools.path, 'apksigner'),
          'sign',
          ...['--ks', keystore.path],
          ...['--ks-pass', 'pass:android'],
          ...['--key-pass', 'pass:android'],
          ...['--ks-key-alias', 'androiddebugkey'],
          ...['--out', output.path],
          input.path,
        ], environment: environment);
      }
    } catch (_) {
      task.fail('Failed to put the compiled Dart code into the APK');
      rethrow;
    } finally {
      staging.deleteSync(recursive: true);
      for (final file in [unaligned, aligned]) {
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    }
    task.complete('Put the compiled Dart code into the APK');
    return AndroidApks(app: app, test: test);
  }

  Future<void> _run(
    List<String> command, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    final result = await _processManager.run(
      command,
      workingDirectory: workingDirectory,
      environment: environment,
    );
    if (result.exitCode != 0) {
      throwToolExit(
        '`${p.basename(command.first)}` exited with code ${result.exitCode}:\n'
        '${result.stdOut}${result.stdErr}',
      );
    }
  }

  /// The newest `build-tools` of the Android SDK `flutter` resolved, which
  /// hold `zipalign` and `apksigner`.
  Directory _buildToolsDirectory() {
    final sdk = _androidSdkPath();
    if (sdk == null) {
      throwToolExit(
        "Couldn't locate the Android SDK. Set the ANDROID_HOME environment "
        'variable or run `patrol doctor`.',
      );
    }
    final dir = _rootDirectory.fileSystem
        .directory(sdk)
        .childDirectory('build-tools');
    final versions = dir.existsSync()
        ? dir.listSync().whereType<Directory>().where(
            (d) => d.childFile('apksigner').existsSync(),
          )
        : const <Directory>[];
    Version? parse(Directory d) {
      try {
        return Version.parse(p.basename(d.path));
      } on FormatException {
        return null;
      }
    }

    final sorted = versions.where((d) => parse(d) != null).toList()
      ..sort((a, b) => parse(b)!.compareTo(parse(a)));
    if (sorted.isEmpty) {
      throwToolExit(
        'No Android build-tools with apksigner found in ${dir.path}. Install '
        'them with the Android SDK Manager.',
      );
    }
    return sorted.first;
  }

  String? _androidSdkPath() {
    final localProperties = _rootDirectory
        .childDirectory('android')
        .childFile('local.properties');
    if (localProperties.existsSync()) {
      for (final line in localProperties.readAsLinesSync()) {
        final trimmed = line.trim();
        if (trimmed.startsWith('sdk.dir=')) {
          final value = trimmed.substring('sdk.dir='.length).trim();
          if (value.isNotEmpty) {
            return value.replaceAll(r'\:', ':').replaceAll(r'\\', r'\');
          }
        }
      }
    }
    final env = _platform.environment;
    return env['ANDROID_HOME'] ?? env['ANDROID_SDK_ROOT'];
  }

  /// The key Gradle signs debug builds with, unless the app sets its own.
  File _debugKeystore() {
    final env = _platform.environment;
    final userHome =
        env['ANDROID_USER_HOME'] ?? p.join(env['HOME']!, '.android');
    final keystore = _rootDirectory.fileSystem
        .directory(userHome)
        .childFile('debug.keystore');
    if (!keystore.existsSync()) {
      throwToolExit(
        'The Android debug keystore does not exist at ${keystore.path}. Run a '
        'full build without --reuse-build once to create it.',
      );
    }
    return keystore;
  }
}
