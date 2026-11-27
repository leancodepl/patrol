import 'package:file/file.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/xcode_test_codegen.dart';

const _generatedIncName = 'PatrolGeneratedTests.inc';

const _discoveryDocsUrl =
    'https://patrol.leancode.co/documentation/ci/build-time-test-discovery';

const _generatedIncInclude =
    '#if __has_include("$_generatedIncName")\n'
    '#include "$_generatedIncName"\n'
    '#endif';

const _buildTimeMode = 'build-time';
const _runtimeMode = 'runtime';

const _runtimeDiscoveryInc =
    '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
    '// Built with runtime test discovery: no generated tests.\n';

/// The build-time discovery side of an Xcode `RunnerUITests` target, shared by
/// iOS and macOS: checks that `RunnerUITests.m` includes the generated tests
/// (Patrol never edits it), writes `PatrolGeneratedTests.inc`, records the
/// discovery mode with the build and maps `--only` to `-only-testing`.
class XcodeRunnerSetup {
  XcodeRunnerSetup._({
    required this._fs,
    required this._rootDirectory,
    required this._logger,
    required this.platform,
    required this.runnerMacro,
    required this.targetPlatform,
  });

  /// The iOS runner of a project rooted at [rootDirectory].
  XcodeRunnerSetup.ios({
    required FileSystem fs,
    required Directory rootDirectory,
    required Logger logger,
  }) : this._(
         fs: fs,
         rootDirectory: rootDirectory,
         logger: logger,
         platform: 'ios',
         runnerMacro: 'PATROL_INTEGRATION_TEST_IOS_RUNNER',
         targetPlatform: TargetPlatform.iOS,
       );

  /// The macOS runner of a project rooted at [rootDirectory].
  XcodeRunnerSetup.macos({
    required FileSystem fs,
    required Directory rootDirectory,
    required Logger logger,
  }) : this._(
         fs: fs,
         rootDirectory: rootDirectory,
         logger: logger,
         platform: 'macos',
         runnerMacro: 'PATROL_INTEGRATION_TEST_MACOS_RUNNER',
         targetPlatform: TargetPlatform.macOS,
       );

  final FileSystem _fs;
  final Directory _rootDirectory;
  final Logger _logger;

  /// The Flutter platform directory holding the Xcode project, which is also
  /// the `patrol build` subcommand that builds it: `ios` or `macos`.
  final String platform;

  /// The runner macro in `RunnerUITests.m`, e.g.
  /// `PATROL_INTEGRATION_TEST_IOS_RUNNER`.
  final String runnerMacro;

  /// The platform whose build-time manifest this runner reads.
  final TargetPlatform targetPlatform;

  Directory get _runnerDirectory =>
      _rootDirectory.childDirectory(platform).childDirectory('RunnerUITests');

  File get _runnerFile => _runnerDirectory.childFile('RunnerUITests.m');

  /// The generated static-XCTest include file, `#include`d by RunnerUITests.m.
  File get generatedIncFile => _runnerDirectory.childFile(_generatedIncName);

  /// The discovery mode of the last build, stored with its artifacts, so a run
  /// on another machine that only gets `build/` still knows it.
  File get _discoveryModeFile => _rootDirectory
      .childDirectory('build')
      .childDirectory('${platform}_integ')
      .childFile('patrol_test_discovery_mode');

  /// Why this project can't use build-time discovery, or null when it can:
  /// `RunnerUITests.m` has to `#include` the generated tests. Patrol never
  /// edits the file; the caller warns or fails with the lines to add.
  String? discoverySetupProblem() {
    final runner = _runnerFile;
    // A missing target is reported by xcodebuild.
    if (!runner.existsSync() ||
        includesGeneratedTests(runner.readAsStringSync())) {
      return null;
    }
    return "${runner.path} doesn't include the generated tests. Add these lines "
        'right after $runnerMacro(RunnerUITests):\n'
        '\n'
        '${_indented(_generatedIncInclude)}\n'
        '\n'
        'See $_discoveryDocsUrl';
  }

  /// Prepares the target for a new build: resets the generated tests, drops
  /// the mode of the previous build, and stops a build that would fail to
  /// compile or silently skip the generated tests.
  void prepareBuild({required bool emitTestManifest}) {
    _resetGeneratedInc();
    if (_discoveryModeFile.existsSync()) {
      _discoveryModeFile.deleteSync();
    }

    final runner = _runnerFile;
    if (!runner.existsSync()) {
      return;
    }

    final contents = runner.readAsStringSync();
    if (_removedStaticBaseMacro.hasMatch(contents)) {
      throwToolExit(
        '${runner.path} uses ${runnerMacro}_STATIC_BASE, which was removed in '
        'Patrol 5.0. Rename it to $runnerMacro, which runs build-time '
        'discovered tests too.\n'
        '\n'
        'See $_discoveryDocsUrl',
      );
    }

    if (_removedStaticMacro.hasMatch(contents)) {
      throwToolExit(
        '${runner.path} uses the ${runnerMacro}_STATIC_BEGIN and _END macros, '
        'which were removed in Patrol 5.0. Replace them with:\n'
        '\n'
        '${_indented('$runnerMacro(RunnerUITests)\n$_generatedIncInclude')}\n'
        '\n'
        'See $_discoveryDocsUrl',
      );
    }

    if (emitTestManifest) {
      final problem = discoverySetupProblem();
      if (problem != null) {
        throwToolExit(
          'Build-time test discovery is on, but $problem\n'
          'Or pass --no-emit-test-manifest to use runtime discovery.',
        );
      }
    }
  }

  /// Stores the discovery mode of a build that just succeeded.
  void recordBuild({required bool emitTestManifest}) {
    _discoveryModeFile
      ..createSync(recursive: true)
      ..writeAsStringSync(emitTestManifest ? _buildTimeMode : _runtimeMode);
  }

  RegExp get _removedStaticBaseMacro =>
      RegExp('\\b${runnerMacro}_STATIC_BASE\\(');

  RegExp get _removedStaticMacro =>
      RegExp('^[ \\t]*${runnerMacro}_STATIC_BEGIN\\b', multiLine: true);

  static String _indented(String lines) =>
      lines.split('\n').map((l) => '  $l').join('\n');

  /// Whether [runnerSource] pulls in `PatrolGeneratedTests.inc`.
  static bool includesGeneratedTests(String runnerSource) => RegExp(
    '^[ \\t]*#[ \\t]*(?:include|import)[ \\t]*[<"]$_generatedIncName[>"]',
    multiLine: true,
  ).hasMatch(runnerSource);

  /// Whether the last build generated test classes, i.e. ran with build-time
  /// discovery.
  bool get hasGeneratedTests {
    final mode = _discoveryModeFile;
    if (mode.existsSync()) {
      return mode.readAsStringSync().trim() == _buildTimeMode;
    }
    // Built by a patrol_cli that didn't record the mode.
    final inc = generatedIncFile;
    return inc.existsSync() && inc.readAsStringSync().contains('@interface ');
  }

  /// Leaves a `PatrolGeneratedTests.inc` that declares no tests when the runner
  /// includes it (an unguarded `#include` needs the file to compile), and no
  /// file otherwise.
  void _resetGeneratedInc() {
    final inc = generatedIncFile;
    final runner = _runnerFile;
    if (!runner.existsSync() ||
        !includesGeneratedTests(runner.readAsStringSync())) {
      if (inc.existsSync()) {
        inc.deleteSync();
      }
      return;
    }
    // An unchanged file keeps its mtime, so Xcode doesn't rebuild the target.
    if (inc.existsSync() && inc.readAsStringSync() == _runtimeDiscoveryInc) {
      return;
    }
    inc
      ..createSync(recursive: true)
      ..writeAsStringSync(_runtimeDiscoveryInc);
  }

  /// Generates one XCTestCase subclass per Dart test file from the manifest at
  /// [manifestPath] into [generatedIncFile].
  void generateTests(String manifestPath) {
    final output = generatedIncFile;
    final count = XcodeTestCodegen(_fs).generate(
      manifestPath: manifestPath,
      outputPath: output.path,
      buildCommand: 'patrol build $platform',
    );
    _logger.info('Generated $count static XCTest method(s) → ${output.path}');
  }

  /// The `-only-testing` selectors (below the target) for [onlyTests]: a Dart
  /// test name becomes `<class>/<method>`, a test file path the bare `<class>`.
  /// With nothing requested, every generated class, so a run restricted to
  /// Patrol's tests stays restricted; empty with runtime discovery, where the
  /// whole target runs. Throws when [onlyTests] can't be resolved.
  List<String> onlyTestingFor(List<String> onlyTests) => onlyTests.isNotEmpty
      ? _resolveOnlyTesting(onlyTests)
      : _generatedClassSelectors();

  List<String> _resolveOnlyTesting(List<String> onlyTests) {
    final manifest = hasGeneratedTests
        ? TestManifest.loadFromBuild(_rootDirectory, platform: targetPlatform)
        : null;
    if (manifest == null) {
      throwToolExit(
        'The app was built with runtime test discovery, so --only has no '
        'generated tests to select. Run `patrol build $platform` without '
        '--no-emit-test-manifest before `patrol test-without-building`.',
      );
    }
    final tests = manifest.tests;
    final selection = resolveOnlySelection(tests, onlyTests);
    if (selection.isEmpty) {
      throwToolExit(
        'None of the requested --only test(s) were found in the manifest.\n'
        'Pass an exact Dart test name or a test file path.\n'
        'Available tests:\n${tests.map((t) => '  ${t.dartName}').join('\n')}',
      );
    }
    if (selection.unmatched.isNotEmpty) {
      _logger.warn(
        'Ignoring --only ${selection.unmatched.join(', ')}: no such Dart test '
        'or test file in the manifest.',
      );
    }
    return [
      ...selection.classNames,
      ...selection.tests.map((name) => name.selector),
    ];
  }

  List<String> _generatedClassSelectors() {
    if (!hasGeneratedTests) {
      return const [];
    }
    final manifest = TestManifest.loadFromBuild(
      _rootDirectory,
      platform: targetPlatform,
    );
    if (manifest == null) {
      return const [];
    }
    return generatePerFileTestNames(
      manifest.tests,
    ).map((name) => name.className).toSet().toList();
  }
}
