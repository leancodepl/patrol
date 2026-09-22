import 'dart:async';

import 'package:file/file.dart';
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/dart_define_utils.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';
import 'package:patrol_cli/src/web/web_artifact.dart';
import 'package:patrol_cli/src/web/web_test_backend.dart';

const _defaultOutputDir = 'build/patrol-web';

/// Compiles a web test app into a directory that `patrol test-without-building`
/// can run on a machine with neither Flutter nor a resolved pub cache.
class BuildWebCommand extends PatrolCommand {
  BuildWebCommand({
    required TestFinderFactory testFinderFactory,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required WebTestBackend webTestBackend,
    required CompatibilityChecker compatibilityChecker,
    required Directory projectRoot,
    required FileSystem fs,
    required Analytics analytics,
    required Logger logger,
  }) : _testFinderFactory = testFinderFactory,
       _testBundler = testBundler,
       _dartDefinesReader = dartDefinesReader,
       _pubspecReader = pubspecReader,
       _webTestBackend = webTestBackend,
       _compatibilityChecker = compatibilityChecker,
       _projectRoot = projectRoot,
       _fs = fs,
       _analytics = analytics,
       _logger = logger {
    usesTargetOption();
    usesBuildModeOption();
    usesDartDefineOption();
    usesDartDefineFromFileOption();
    usesLabelOption();
    usesTagsOption();
    usesExcludeTagsOption();
    usesCheckCompatibilityOption();
    usesAppNameOption();

    argParser
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Directory to put the artifact in.',
        valueHelp: _defaultOutputDir,
        defaultsTo: _defaultOutputDir,
      )
      ..addFlag(
        'force',
        help:
            'Build in profile or release mode anyway. Patrol drives the app '
            'through the Flutter semantics tree, which those modes strip, so '
            'the tests stop interacting with the app and pass without doing '
            'anything.',
        negatable: false,
      );
  }

  final TestFinderFactory _testFinderFactory;
  final TestBundler _testBundler;
  final DartDefinesReader _dartDefinesReader;
  final PubspecReader _pubspecReader;
  final WebTestBackend _webTestBackend;
  final CompatibilityChecker _compatibilityChecker;
  final Directory _projectRoot;
  final FileSystem _fs;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'web';

  @override
  String? get docsName => 'build';

  @override
  String get description => 'Build app for integration testing on web.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(
        FlutterVersion.fromCLI(flutterCommand),
        'build_web',
      ),
    );

    if (buildMode != BuildMode.debug && !boolArg('force')) {
      _logger.err(
        'Patrol web tests only work in debug mode: profile and release builds '
        'drop the semantics tree the tests type and tap through, so they run '
        'green without touching the app. Drop --${buildMode.name}, or pass '
        '--force if you know what you are doing.',
      );
      return 1;
    }

    // `patrol test` gets by on `flutter run -d web-server`, which doesn't need
    // this, so a project that tests on web today may well not have it yet.
    if (!_projectRoot.childFile('web/index.html').existsSync()) {
      _logger.err(
        'This project is not configured for the web, which `flutter build web` '
        'requires. Run `flutter create . --platforms web` in '
        '${_projectRoot.path} and build again.',
      );
      return 1;
    }

    final config = _pubspecReader.read();
    final testDirectory = config.testDirectory;

    if (boolArg('check-compatibility')) {
      await _compatibilityChecker.checkVersionsCompatibilityForBuild(
        patrolVersion: _pubspecReader.getPatrolVersion(),
      );
    }

    final testFinder = _testFinderFactory.create(testDirectory);
    final excludes = stringsArg('exclude').toSet();
    final target = stringsArg('target');
    final targets = target.isNotEmpty
        ? testFinder.findTests(target, config.testFileSuffix, excludes)
        : testFinder.findAllTests(
            excludes: excludes,
            testFileSuffix: config.testFileSuffix,
          );

    _logger.detail('Received ${targets.length} test target(s)');
    for (final t in targets) {
      _logger.detail('Received test target: $t');
    }

    final tags = stringArg('tags');
    final excludeTags = stringArg('exclude-tags');
    if (tags != null) {
      _logger.detail('Received tag(s): $tags');
    }
    if (excludeTags != null) {
      _logger.detail('Received exclude tag(s): $excludeTags');
    }

    if (boolArg('generate-bundle')) {
      _testBundler.createTestBundle(
        testDirectory,
        targets,
        tags,
        excludeTags,
        web: true,
      );
    }
    final entrypoint = _testBundler.getBundledTestFile(
      testDirectory,
      web: true,
    );

    final appName = stringArg('app-name');
    final displayLabel = boolArg('label');

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    // Kept identical to `patrol test` on web, so the artifact runs the same way.
    final internalDartDefines = {
      'PATROL_APP_PACKAGE_NAME': config.android.packageName,
      'PATROL_APP_BUNDLE_ID': config.ios.bundleId,
      'PATROL_MACOS_APP_BUNDLE_ID': config.macos.bundleId,
      'PATROL_ANDROID_APP_NAME': appName ?? config.android.appName,
      'PATROL_IOS_APP_NAME': appName ?? config.ios.appName,
      'PATROL_MACOS_APP_NAME': appName ?? config.macos.appName,
      'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE': 'false',
      'PATROL_TEST_LABEL_ENABLED': displayLabel.toString(),
      'PATROL_TEST_DIRECTORY': testDirectory,
      'PATROL_SCREENSHOT_ON_FAILURE': config.screenshotOnFailure.toString(),
      'COVERAGE_ENABLED': 'false',
    }.withNullsRemoved();

    final dartDefines = {...customDartDefines, ...internalDartDefines};
    _logger.detail(
      'Received ${dartDefines.length} --dart-define(s) '
      '(${customDartDefines.length} custom, ${internalDartDefines.length} internal)',
    );
    for (final dartDefine in customDartDefines.entries) {
      _logger.detail('Received custom --dart-define: ${dartDefine.key}');
    }
    for (final dartDefine in internalDartDefines.entries) {
      _logger.detail(
        'Received internal --dart-define: ${dartDefine.key}=${dartDefine.value}',
      );
    }

    final dartDefineFromFilePaths = stringsArg('dart-define-from-file');

    final webOpts = WebAppOptions(
      flutter: FlutterAppOptions(
        command: flutterCommand,
        target: entrypoint.path,
        flavor: null,
        buildMode: buildMode,
        dartDefines: mergeDartDefines(
          dartDefineFromFilePaths,
          dartDefines,
          _dartDefinesReader,
        ),
        dartDefineFromFilePaths: dartDefineFromFilePaths,
        buildName: null,
        buildNumber: null,
      ),
    );

    final artifact = WebArtifact.at(stringArg('output')!, fs: _fs);
    if (artifact.holdsForeignEntries) {
      _logger.err(
        '${artifact.root.path} holds files that are not part of a Patrol web '
        'artifact. Pass --output pointing at a new or previously built '
        'directory.',
      );
      return 1;
    }

    try {
      await _webTestBackend.build(
        webOpts,
        output: artifact.appDir.absolute.path,
      );

      artifact.copyRunnerFrom(
        _fs.directory(await _webTestBackend.resolveWebRunnerPath()),
      );
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      return 1;
    }

    _logger
      ..info('${artifact.appDir.path} (web app under test)')
      ..info('${artifact.runnerDir.path} (Playwright runner)')
      ..info(
        'Run it with: patrol test-without-building '
        '--input ${artifact.root.path}',
      );

    return 0;
  }
}
