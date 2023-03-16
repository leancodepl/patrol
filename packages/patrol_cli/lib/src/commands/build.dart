import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/build_android.dart';
import 'package:patrol_cli/src/commands/build_ios.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_finder.dart';

class BuildCommand extends PatrolCommand {
  BuildCommand({
    required TestFinder testFinder,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required Logger logger,
  })  : _testFinder = testFinder,
        _dartDefinesReader = dartDefinesReader,
        _pubspecReader = pubspecReader,
        _androidTestBackend = androidTestBackend,
        _logger = logger {
    addSubcommand(
      BuildAndroidCommand(
        testFinder: testFinder,
        dartDefinesReader: dartDefinesReader,
        pubspecReader: pubspecReader,
        androidTestBackend: androidTestBackend,
        logger: logger,
      ),
    );
    addSubcommand(
      BuildIOSCommand(
        testFinder: testFinder,
        dartDefinesReader: dartDefinesReader,
        pubspecReader: pubspecReader,
        iosTestBackend: iosTestBackend,
        logger: logger,
      ),
    );

    usesTargetOption();
    usesBuildModeOption();
    usesFlavorOption();
    usesDartDefineOption();
    usesLabelOption();
    usesWaitOption();

    usesAndroidOptions();
    usesIOSOptions();
  }

  final TestFinder _testFinder;
  final DartDefinesReader _dartDefinesReader;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;

  final Logger _logger;

  @override
  String get name => 'build';

  @override
  String get description => 'Build apps for integration testing.';

  @override
  Future<int> run() async {
    final targetArg = stringsArg('target');
    if (targetArg.isEmpty) {
      throwToolExit('No test target specified');
    } else if (targetArg.length > 1) {
      throwToolExit('Only one test target can be specified');
    }
    final target = _testFinder.findTest(targetArg.single);
    _logger.detail('Received test target: $target');

    final config = _pubspecReader.read();
    final androidFlavor = stringArg('flavor') ?? config.android.flavor;
    final iosFlavor = stringArg('flavor') ?? config.ios.flavor;
    if (androidFlavor != null) {
      _logger.detail('Received Android flavor: $androidFlavor');
    }
    if (iosFlavor != null) {
      _logger.detail('Received iOS flavor: $iosFlavor');
    }

    final packageName = stringArg('package-name') ?? config.android.packageName;
    final bundleId = stringArg('bundle-id') ?? config.ios.bundleId;

    final displayLabel = boolArg('label');

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_WAIT': defaultWait.toString(),
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_APP_BUNDLE_ID': bundleId,
      'PATROL_ANDROID_APP_NAME': config.android.appName,
      'PATROL_IOS_APP_NAME': config.ios.appName,
      if (displayLabel) 'PATROL_TEST_LABEL': basename(target),
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

    final flutterOpts = FlutterAppOptions(
      target: target,
      flavor: androidFlavor,
      buildMode: buildMode,
      dartDefines: dartDefines,
    );
    final androidOpts = AndroidAppOptions(
      flutter: flutterOpts,
      packageName: packageName,
    );
    Future<void> action() => _androidTestBackend.build(androidOpts);

    try {
      await action();
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      rethrow;
    }

    return 0;
  }
}
