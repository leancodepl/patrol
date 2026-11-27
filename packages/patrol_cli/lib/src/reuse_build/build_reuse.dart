import 'dart:convert';

import 'package:file/file.dart';
import 'package:patrol_cli/src/analytics/analytics.dart' show cleanJsonResult;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/reuse_build/android_kernel_swapper.dart';
import 'package:patrol_cli/src/reuse_build/ios_build_patcher.dart';
import 'package:patrol_cli/src/reuse_build/kernel_compiler.dart';
import 'package:patrol_cli/src/reuse_build/native_fingerprint.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

/// Remembers which native build matches which native inputs, so `patrol test
/// --reuse-build` can tell whether the last build can be reused with a newly
/// compiled kernel.
///
/// The state of each cache slot lives in `build/patrol_reuse_build/<key>.json`; the
/// build itself stays where Gradle or Xcode put it. Its files are recorded
/// with their modification times, so a build that changed since (say, a
/// manual Gradle run) isn't reused.
class BuildReuseCache {
  BuildReuseCache({
    required this._rootDirectory,
    required this._processManager,
    required NativePlatform platform,
    required this._logger,
  }) : _fingerprinter = NativeFingerprinter(
         rootDirectory: _rootDirectory,
         platform: platform,
       );

  final Directory _rootDirectory;
  final ProcessManager _processManager;
  final NativeFingerprinter _fingerprinter;
  final Logger _logger;

  Directory get directory => _rootDirectory
      .childDirectory('build')
      .childDirectory('patrol_reuse_build');

  /// Where reused builds of [inputs] write their patched artifacts.
  Directory outputDirectory(NativeBuildInputs inputs) =>
      directory.childDirectory(inputs.cacheKey);

  File _stateFile(NativeBuildInputs inputs) =>
      directory.childFile('${inputs.cacheKey}.json');

  Future<NativeFingerprint> fingerprint(
    NativeBuildInputs inputs,
    FlutterCommand flutterCommand,
  ) async {
    final revision = await _flutterRevision(flutterCommand);
    return _fingerprinter.compute(inputs, flutterRevision: revision);
  }

  /// Returns why the build recorded for [inputs] can't be reused, or `null`
  /// when it can.
  String? whyNotReusable(
    NativeBuildInputs inputs, {
    required NativeFingerprint fingerprint,
    required List<FileSystemEntity> artifacts,
  }) {
    final file = _stateFile(inputs);
    if (!file.existsSync()) {
      return 'no build recorded yet';
    }
    final Map<String, dynamic> state;
    try {
      state = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } on FormatException {
      return 'the recorded build state is unreadable';
    }
    final inputsState = state['inputs'];
    if (inputsState is! Map<String, dynamic>) {
      return 'the recorded build state is unreadable';
    }
    final changed = fingerprint.differences(inputsState.cast());
    if (changed.isNotEmpty) {
      final shown = changed.take(3).join(', ');
      final more = changed.length > 3 ? ' and ${changed.length - 3} more' : '';
      return 'changed: $shown$more';
    }
    final recorded = state['artifacts'];
    if (recorded is! Map<String, dynamic>) {
      return 'the recorded build state is unreadable';
    }
    final current = _artifactStamps(artifacts);
    if (current == null) {
      return 'the last build is gone';
    }
    if (jsonEncode(current) != jsonEncode(recorded)) {
      return 'the last build changed since it was recorded';
    }
    return null;
  }

  /// Records that [artifacts] were built from inputs with [fingerprint].
  void record(
    NativeBuildInputs inputs, {
    required NativeFingerprint fingerprint,
    required List<FileSystemEntity> artifacts,
  }) {
    final stamps = _artifactStamps(artifacts);
    if (stamps == null) {
      _logger.detail(
        'Not recording the build for --reuse-build: artifacts missing',
      );
      return;
    }
    final file = _stateFile(inputs);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'fingerprint': fingerprint.hash,
        'artifacts': stamps,
        'inputs': fingerprint.entries,
      }),
    );
    _logger.detail('Recorded the build for --reuse-build in ${file.path}');
  }

  /// Forgets the build of [inputs], so the next --reuse-build run builds in full.
  void forget(NativeBuildInputs inputs) {
    final file = _stateFile(inputs);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  Map<String, int>? _artifactStamps(List<FileSystemEntity> artifacts) {
    final stamps = <String, int>{};
    for (final artifact in artifacts) {
      final stat = artifact.statSync();
      if (stat.type == FileSystemEntityType.notFound) {
        return null;
      }
      stamps[artifact.path] = stat.modified.millisecondsSinceEpoch;
    }
    return stamps;
  }

  Future<String> _flutterRevision(FlutterCommand flutterCommand) async {
    final result = await _processManager.run([
      flutterCommand.executable,
      ...flutterCommand.arguments,
      '--no-version-check',
      '--suppress-analytics',
      '--version',
      '--machine',
    ], runInShell: true);
    try {
      final json = jsonDecode(cleanJsonResult(result)) as Map<String, dynamic>;
      return [
        json['frameworkRevision'],
        json['engineRevision'],
        json['dartSdkVersion'],
      ].join('/');
    } on Object {
      // Unknown means every run differs, so nothing is ever reused wrongly.
      return 'unknown-${DateTime.now().microsecondsSinceEpoch}';
    }
  }
}

/// What `patrol test --reuse-build` needs, in one place.
class BuildReuseTools {
  const BuildReuseTools({
    required this.cache,
    required this.kernelCompiler,
    required this.androidSwapper,
    required this.iosPatcher,
  });

  final BuildReuseCache cache;
  final KernelCompiler kernelCompiler;
  final AndroidKernelSwapper androidSwapper;
  final IOSBuildPatcher iosPatcher;
}
