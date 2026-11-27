import 'dart:convert';

import 'package:file/file.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/reuse_build/native_fingerprint.dart';
import 'package:process/process.dart';

/// Compiles the Dart side of a debug build (`kernel_blob.bin`) without
/// building the native app, using `flutter build bundle`.
///
/// A debug build is a native shell plus all the Dart code in this one file,
/// and the file holds every compile-time constant: the test bundle, patrol's
/// internal dart-defines, the user's dart-defines and the flavor.
class KernelCompiler {
  KernelCompiler({
    required this._processManager,
    required this._rootDirectory,
    required this._logger,
  });

  final ProcessManager _processManager;
  final Directory _rootDirectory;
  final Logger _logger;

  /// Where [compile] writes its output for [platform].
  Directory outputDirectory(ReusePlatform platform) => _rootDirectory
      .childDirectory('build')
      .childDirectory('patrol_kernel')
      .childDirectory(platform.id);

  /// Returns the compiled `kernel_blob.bin`.
  Future<File> compile(
    FlutterAppOptions options, {
    required ReusePlatform platform,
  }) async {
    final outDir = outputDirectory(platform);
    final assetDir = outDir.childDirectory('flutter_assets');
    if (assetDir.existsSync()) {
      assetDir.deleteSync(recursive: true);
    }
    outDir.createSync(recursive: true);

    final task = _logger.task('Compiling Dart code (no native build)');
    final process = await _processManager.start(
      bundleInvocation(
        options,
        platform: platform,
        assetDir: assetDir.path,
        depfile: outDir.childFile('kernel_blob.bin.d').path,
      ),
      runInShell: true,
      workingDirectory: _rootDirectory.path,
    );
    final stdout = process.listenStdOut((l) => _logger.detail('\t: $l'));
    final stderr = process.listenStdErr((l) => _logger.err('\t$l'));
    final exitCode = await process.exitCode;
    await stdout.cancel();
    await stderr.cancel();

    final kernel = assetDir.childFile('kernel_blob.bin');
    if (exitCode != 0 || !kernel.existsSync()) {
      task.fail('Failed to compile Dart code');
      throwToolExit('`flutter build bundle` exited with code $exitCode');
    }
    task.complete('Compiled Dart code');
    return kernel;
  }

  /// Compiles the Dart code of a release build for physical iOS devices into
  /// an `App.framework` (machine code plus assets) with `flutter assemble`,
  /// the way Xcode's Flutter build phase does. Returns the framework.
  Future<Directory> compileIOSAppFramework(
    FlutterAppOptions options, {
    required String configuration,
  }) async {
    final outDir = outputDirectory(ReusePlatform.iosDevice);
    if (outDir.existsSync()) {
      outDir.deleteSync(recursive: true);
    }
    outDir.createSync(recursive: true);

    final sdk = await _processManager.run([
      'xcrun',
      ...['--sdk', 'iphoneos'],
      '--show-sdk-path',
    ]);
    if (sdk.exitCode != 0) {
      throwToolExit('Failed to find the iOS SDK: ${sdk.stdErr}');
    }

    final task = _logger.task('Compiling Dart code (no native build)');
    final process = await _processManager.start(
      assembleIOSInvocation(
        options,
        configuration: configuration,
        sdkRoot: sdk.stdOut.trim(),
        outputDir: outDir.path,
        sourceRoot: _rootDirectory.childDirectory('ios').path,
      ),
      runInShell: true,
      workingDirectory: _rootDirectory.path,
    );
    final stdout = process.listenStdOut((l) => _logger.detail('\t: $l'));
    final stderr = process.listenStdErr((l) => _logger.err('\t$l'));
    final exitCode = await process.exitCode;
    await stdout.cancel();
    await stderr.cancel();

    final framework = outDir.childDirectory('App.framework');
    if (exitCode != 0 || !framework.existsSync()) {
      task.fail('Failed to compile Dart code');
      throwToolExit('`flutter assemble` exited with code $exitCode');
    }
    task.complete('Compiled Dart code');
    return framework;
  }

  /// The `flutter assemble` invocation that builds a release `App.framework`
  /// for iOS devices, mirroring Flutter's `xcode_backend.dart`.
  static List<String> assembleIOSInvocation(
    FlutterAppOptions options, {
    required String configuration,
    required String sdkRoot,
    required String outputDir,
    required String sourceRoot,
  }) {
    final dartDefines = options.dartDefines.entries
        .map((e) => base64Encode(utf8.encode('${e.key}=${e.value}')))
        .join(',');
    return [
      options.command.executable,
      ...options.command.arguments,
      'assemble',
      '--no-version-check',
      '--suppress-analytics',
      '--output=$outputDir/',
      '-dTargetPlatform=ios',
      '-dTargetFile=${options.target}',
      '-dBuildMode=release',
      if (options.flavor case final flavor?) '-dFlavor=$flavor',
      '-dConfiguration=$configuration',
      '-dIosArchs=arm64',
      '-dSdkRoot=$sdkRoot',
      '-dTreeShakeIcons=${!options.noTreeShakeIcons}',
      '-dTrackWidgetCreation=false',
      '-dDartObfuscation=false',
      '-dAction=build',
      '--DartDefines=$dartDefines',
      '-dSrcRoot=$sourceRoot',
      'release_ios_bundle_flutter_assets',
    ];
  }

  /// The `flutter build bundle` invocation for [options].
  ///
  /// `build bundle` has no `--flavor`, so the flavor goes in as the
  /// `FLUTTER_APP_FLAVOR` define, which is what a flavored build sets.
  /// [FlutterAppOptions.dartDefines] already holds the contents of the
  /// `--dart-define-from-file` files, so the files themselves aren't passed.
  static List<String> bundleInvocation(
    FlutterAppOptions options, {
    required ReusePlatform platform,
    required String assetDir,
    required String depfile,
  }) {
    final dartDefines = {
      ...options.dartDefines,
      'FLUTTER_APP_FLAVOR': ?options.flavor,
    };
    return [
      options.command.executable,
      ...options.command.arguments,
      ...['build', 'bundle'],
      '--no-version-check',
      '--suppress-analytics',
      '--debug',
      ...['--target-platform', platform.bundleTargetPlatform],
      ...['--target', options.target],
      ...['--asset-dir', assetDir],
      ...['--depfile', depfile],
      for (final entry in dartDefines.entries) ...[
        '--dart-define',
        '${entry.key}=${entry.value}',
      ],
    ];
  }
}
