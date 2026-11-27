import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:process/process.dart';

/// Puts newly compiled Dart code into a copy of an existing iOS build (the
/// `Build/Products` directory with the `.xctestrun`), so the tests run
/// without `xcodebuild build-for-testing`.
///
/// The Dart code lives in `App.framework`, in both `Runner.app` and the UI
/// test runner. Every bundle around a changed file is signed again, inner
/// bundles first.
class IOSBuildPatcher {
  IOSBuildPatcher({required this._processManager, required this._logger});

  final ProcessManager _processManager;
  final Logger _logger;

  static const _bundleExtensions = {'.app', '.framework', '.xctest'};

  /// Simulator debug builds: replaces every `kernel_blob.bin` with [kernel]
  /// and signs ad hoc, like Xcode does for the simulator.
  Future<Directory> swapKernel({
    required Directory products,
    required String configuration,
    required File kernel,
    required Directory outputDir,
  }) async {
    final task = _logger.task('Putting the compiled Dart code into the app');
    try {
      final configDir = await _copyProducts(
        products,
        '$configuration-iphonesimulator',
        outputDir,
      );
      final kernels = configDir
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((f) => p.basename(f.path) == 'kernel_blob.bin')
          .toList();
      if (kernels.isEmpty) {
        throwToolExit(
          'No kernel_blob.bin found in the simulator build. --reuse-build '
          'needs a debug build on simulators.',
        );
      }
      for (final file in kernels) {
        kernel.copySync(file.path);
      }
      await _signAround(
        kernels.map((f) => f.parent.path),
        within: outputDir.path,
        identity: '-',
        fatal: false,
      );
    } catch (_) {
      task.fail('Failed to put the compiled Dart code into the app');
      rethrow;
    }
    task.complete('Put the compiled Dart code into the app');
    return outputDir;
  }

  /// Physical device release builds: replaces every `App.framework` with
  /// [appFramework] (Dart compiled to machine code, plus assets) and signs
  /// with the identity the base build's `Runner.app` was signed with. Its
  /// provisioning profile and entitlements stay as they are.
  Future<Directory> swapAppFramework({
    required Directory products,
    required String configuration,
    required Directory appFramework,
    required Directory outputDir,
  }) async {
    final task = _logger.task('Putting the compiled Dart code into the app');
    try {
      final configDir = await _copyProducts(
        products,
        '$configuration-iphoneos',
        outputDir,
      );
      final runnerApp = configDir.childDirectory('Runner.app');
      if (!runnerApp.existsSync()) {
        throwToolExit('No Runner.app found in ${configDir.path}.');
      }
      final identity = await signingIdentity(runnerApp);

      final frameworks = configDir
          .listSync(recursive: true, followLinks: false)
          .whereType<Directory>()
          .where((d) => p.basename(d.path) == 'App.framework')
          .toList();
      if (frameworks.isEmpty) {
        throwToolExit('No App.framework found in ${configDir.path}.');
      }
      for (final framework in frameworks) {
        framework.deleteSync(recursive: true);
        await _copyTree(appFramework, framework);
      }
      await _signAround(
        frameworks.map((d) => d.path),
        within: outputDir.path,
        identity: identity,
        fatal: true,
      );
    } catch (_) {
      task.fail('Failed to put the compiled Dart code into the app');
      rethrow;
    }
    task.complete('Put the compiled Dart code into the app');
    return outputDir;
  }

  /// The SHA-1 of the certificate [bundle] is signed with, which `codesign
  /// --sign` accepts as the identity.
  Future<String> signingIdentity(Directory bundle) async {
    final tmp = bundle.fileSystem.systemTempDirectory.createTempSync(
      'patrol_cert',
    );
    try {
      final prefix = p.join(tmp.path, 'cert');
      final result = await _processManager.run([
        'codesign',
        '-d',
        '--extract-certificates=$prefix',
        bundle.path,
      ]);
      final leaf = bundle.fileSystem.file('${prefix}0');
      if (result.exitCode != 0 || !leaf.existsSync()) {
        throwToolExit(
          '${bundle.path} is not signed with a certificate (codesign exited '
          'with code ${result.exitCode}): ${result.stdErr}',
        );
      }
      return sha1.convert(leaf.readAsBytesSync()).toString().toUpperCase();
    } finally {
      tmp.deleteSync(recursive: true);
    }
  }

  /// Copies the `.xctestrun` files and [configDirName] from [products] into
  /// a clean [outputDir], and returns the copied [configDirName].
  Future<Directory> _copyProducts(
    Directory products,
    String configDirName,
    Directory outputDir,
  ) async {
    final configDir = products.childDirectory(configDirName);
    if (!configDir.existsSync()) {
      throwToolExit('No build found at ${configDir.path}.');
    }
    if (outputDir.existsSync()) {
      outputDir.deleteSync(recursive: true);
    }
    outputDir.createSync(recursive: true);
    for (final entity in products.listSync()) {
      if (entity is File && entity.path.endsWith('.xctestrun')) {
        entity.copySync(outputDir.childFile(p.basename(entity.path)).path);
      }
    }
    final copy = outputDir.childDirectory(configDirName);
    await _copyTree(configDir, copy);
    return copy;
  }

  /// Signs every bundle that is or contains one of [paths], up to [within],
  /// inner bundles first: an outer signature seals the inner ones.
  Future<void> _signAround(
    Iterable<String> paths, {
    required String within,
    required String identity,
    required bool fatal,
  }) async {
    final bundles = <String>{};
    for (final path in paths) {
      var dir = path;
      while (p.isWithin(within, dir)) {
        if (_bundleExtensions.contains(p.extension(dir))) {
          bundles.add(dir);
        }
        dir = p.dirname(dir);
      }
    }
    final ordered = bundles.toList()
      ..sort((a, b) => p.split(b).length.compareTo(p.split(a).length));
    for (final bundle in ordered) {
      final result = await _processManager.run([
        'codesign',
        '--force',
        ...['--sign', identity],
        '--preserve-metadata=identifier,entitlements,flags',
        '--timestamp=none',
        bundle,
      ]);
      if (result.exitCode == 0) {
        continue;
      }
      final message =
          'Failed to sign $bundle again (codesign exited with code '
          '${result.exitCode}): ${result.stdErr}';
      if (fatal) {
        throwToolExit(message);
      }
      // The simulator runs apps with a broken signature too, so go on.
      _logger.warn(message);
    }
  }

  /// Copies with APFS clones where possible, which costs no disk space.
  Future<void> _copyTree(Directory from, Directory to) async {
    var result = await _processManager.run(['cp', '-Rc', from.path, to.path]);
    if (result.exitCode != 0) {
      if (to.existsSync()) {
        to.deleteSync(recursive: true);
      }
      result = await _processManager.run(['cp', '-R', from.path, to.path]);
    }
    if (result.exitCode != 0) {
      throwToolExit('Failed to copy ${from.path}:\n${result.stdErr}');
    }
  }
}
