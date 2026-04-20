import 'dart:convert' show base64Encode, utf8;
import 'dart:io' show Directory, FileSystemEntity;

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';

/// Resolves [IOSAppOptions] while consolidating the native-iOS-path workflow.
///
/// When a native iOS project path is provided (either via `--native-ios-path`
/// or `patrol.ios.native_project_path` in pubspec.yaml), the workspace name is
/// auto-detected and derived data is forced to an absolute path anchored at
/// the Flutter module's `build/ios_integ` directory.
IOSAppOptions resolveIOSAppOptions({
  required FlutterAppOptions flutterOpts,
  required String? bundleId,
  required String scheme,
  required String configuration,
  required bool simulator,
  required String osVersion,
  required int appServerPort,
  required int testServerPort,
  required bool fullIsolation,
  required bool clearIOSPermissions,
  required bool addToApp,
  String? nativeIosPathArg,
  String? nativeIosPathFromConfig,
  String? flutterModuleRoot,
}) {
  final rawNativePath = nativeIosPathArg ?? nativeIosPathFromConfig;
  String? resolvedNativePath;
  var workspaceName = 'Runner.xcworkspace';
  var uiTestTargetName = 'RunnerUITests';
  var derivedDataPath = '../build/ios_integ';
  var resolvedScheme = scheme;

  if (rawNativePath != null) {
    final moduleRoot = flutterModuleRoot ?? Directory.current.path;
    resolvedNativePath = p.isAbsolute(rawNativePath)
        ? rawNativePath
        : p.normalize(p.join(moduleRoot, rawNativePath));

    final dir = Directory(resolvedNativePath);
    if (!dir.existsSync()) {
      throw Exception(
        'native-ios-path does not exist: $resolvedNativePath. '
        'Check the patrol.ios.native_project_path entry in pubspec.yaml or '
        '--native-ios-path flag.',
      );
    }

    final workspaces = dir
        .listSync()
        .whereType<FileSystemEntity>()
        .where((e) => e.path.endsWith('.xcworkspace'))
        .toList();
    if (workspaces.length == 1) {
      workspaceName = p.basename(workspaces.single.path);
    } else if (workspaces.length > 1) {
      throw Exception(
        'Multiple .xcworkspace files found in $resolvedNativePath. '
        'Patrol cannot disambiguate between them.',
      );
    } else {
      throw Exception(
        'No .xcworkspace file found in $resolvedNativePath. '
        'Run `pod install` in the native iOS project first.',
      );
    }

    uiTestTargetName = 'PatrolUITests';
    resolvedScheme = 'PatrolUITests';
    derivedDataPath = p.join(moduleRoot, 'build', 'ios_integ');
  }

  return IOSAppOptions(
    flutter: flutterOpts,
    bundleId: bundleId,
    scheme: resolvedScheme,
    configuration: configuration,
    simulator: simulator,
    osVersion: osVersion,
    appServerPort: appServerPort,
    testServerPort: testServerPort,
    fullIsolation: fullIsolation,
    clearIOSPermissions: clearIOSPermissions,
    addToApp: addToApp,
    nativeIosPath: resolvedNativePath,
    workspaceName: workspaceName,
    uiTestTargetName: uiTestTargetName,
    derivedDataPath: derivedDataPath,
  );
}

class FlutterAppOptions {
  const FlutterAppOptions({
    required this.command,
    required this.target,
    required this.flavor,
    required this.buildMode,
    required this.dartDefines,
    required this.dartDefineFromFilePaths,
    required this.buildName,
    required this.buildNumber,
    this.noTreeShakeIcons = false,
  });

  final FlutterCommand command;
  final String target;
  final String? flavor;
  final BuildMode buildMode;
  final Map<String, String> dartDefines;
  final List<String> dartDefineFromFilePaths;
  final String? buildName;
  final String? buildNumber;
  final bool noTreeShakeIcons;

  /// Translates these options into a proper `flutter attach`.
  @nonVirtual
  List<String> toFlutterAttachInvocation() {
    final cmd = [
      ...[command.executable, ...command.arguments],
      'attach',
      '--no-version-check',
      '--suppress-analytics',
      '--debug',
      ...['--target', target],
      for (final dartDefine in dartDefines.entries) ...[
        '--dart-define',
        '${dartDefine.key}=${dartDefine.value}',
      ],
      for (final dartDefineFromFilePath in dartDefineFromFilePaths) ...[
        '--dart-define-from-file',
        dartDefineFromFilePath,
      ],
    ];

    return cmd;
  }
}

/// Resolves [AndroidAppOptions] while consolidating the native-android-path
/// workflow.
///
/// When a native Android project path is provided (either via
/// `--native-android-path` or `patrol.android.native_project_path` in
/// pubspec.yaml), Patrol runs Gradle inside that directory instead of the
/// Flutter module's generated `.android/` scaffold.
AndroidAppOptions resolveAndroidAppOptions({
  required FlutterAppOptions flutterOpts,
  required String? packageName,
  required int appServerPort,
  required int testServerPort,
  required bool uninstall,
  required bool addToApp,
  String? nativeAndroidPathArg,
  String? nativeAndroidPathFromConfig,
  String? flutterModuleRoot,
}) {
  final rawNativePath = nativeAndroidPathArg ?? nativeAndroidPathFromConfig;
  String? resolvedNativePath;

  if (rawNativePath != null) {
    final moduleRoot = flutterModuleRoot ?? Directory.current.path;
    resolvedNativePath = p.isAbsolute(rawNativePath)
        ? rawNativePath
        : p.normalize(p.join(moduleRoot, rawNativePath));

    final dir = Directory(resolvedNativePath);
    if (!dir.existsSync()) {
      throw Exception(
        'native-android-path does not exist: $resolvedNativePath. '
        'Check the patrol.android.native_project_path entry in pubspec.yaml '
        'or --native-android-path flag.',
      );
    }

    final gradlew = p.join(resolvedNativePath, 'gradlew');
    if (!FileSystemEntity.isFileSync(gradlew)) {
      throw Exception(
        'No gradlew script found in $resolvedNativePath. '
        'The native Android project must have a Gradle wrapper.',
      );
    }
  }

  return AndroidAppOptions(
    flutter: flutterOpts,
    packageName: packageName,
    appServerPort: appServerPort,
    testServerPort: testServerPort,
    uninstall: uninstall,
    addToApp: addToApp,
    nativeAndroidPath: resolvedNativePath,
  );
}

class AndroidAppOptions {
  const AndroidAppOptions({
    required this.flutter,
    this.packageName,
    required this.appServerPort,
    required this.testServerPort,
    required this.uninstall,
    this.addToApp = false,
    this.nativeAndroidPath,
  });

  final FlutterAppOptions flutter;
  final String? packageName;
  final int appServerPort;
  final int testServerPort;
  final bool uninstall;
  final bool addToApp;

  /// Absolute path to an external native Android project (used for add-to-app
  /// setups). When set, Patrol drives Gradle from this directory instead of
  /// the Flutter module's generated `.android/` scaffold.
  final String? nativeAndroidPath;

  String get description => 'apk with entrypoint ${basename(flutter.target)}';

  List<String> toGradleAssembleInvocation({required bool isWindows}) {
    // for example: assembleDevDebug, assembleRelease
    return _toGradleInvocation(
      isWindows: isWindows,
      task: 'assemble$_effectiveFlavor$_buildMode',
    );
  }

  List<String> toGradleAssembleTestInvocation({required bool isWindows}) {
    // for example: assembleDevDebugAndroidTest, assembleReleaseAndroidTest
    return _toGradleInvocation(
      isWindows: isWindows,
      task: 'assemble$_effectiveFlavor${_buildMode}AndroidTest',
      noUninstallAfterTests: !uninstall,
    );
  }

  List<String> toGradleConnectedTestInvocation({required bool isWindows}) {
    // for example: connectedDevDebugAndroidTest, connectedReleaseAndroidTest
    return _toGradleInvocation(
      isWindows: isWindows,
      task: 'connected$_effectiveFlavor${_buildMode}AndroidTest',
      noUninstallAfterTests: !uninstall,
    );
  }

  List<String> toGradleAppDependencies({required bool isWindows}) {
    final List<String> cmd;
    if (isWindows) {
      cmd = <String>[r'.\gradlew.bat'];
    } else {
      cmd = <String>['./gradlew'];
    }

    // Add Gradle task
    cmd.add(':app:dependencies');

    return cmd;
  }

  String get _buildMode => flutter.buildMode.androidName;

  String get _effectiveFlavor {
    var flavor = flutter.flavor ?? '';
    if (flavor.isNotEmpty) {
      flavor = flavor[0].toUpperCase() + flavor.substring(1);
    }
    return flavor;
  }

  /// Translates these options into a proper Gradle invocation.
  List<String> _toGradleInvocation({
    required bool isWindows,
    required String task,
    bool noUninstallAfterTests = false,
  }) {
    final List<String> cmd;
    if (isWindows) {
      cmd = <String>[r'.\gradlew.bat'];
    } else {
      cmd = <String>['./gradlew'];
    }

    // Add Gradle task
    cmd.add(':app:$task');

    // Add Dart test target
    final target = '-Ptarget=${flutter.target}';
    cmd.add(target);

    // Create modifiable Map
    final effectiveDartDefines = Map<String, String>.of(flutter.dartDefines);

    // Add Dart defines encoded in base64
    if (effectiveDartDefines.isNotEmpty) {
      final dartDefinesString = StringBuffer();
      for (var i = 0; i < effectiveDartDefines.length; i++) {
        final entry = effectiveDartDefines.entries.elementAt(i);
        final pair = utf8.encode('${entry.key}=${entry.value}');
        dartDefinesString.write(base64Encode(pair));
        if (i != effectiveDartDefines.length - 1) {
          dartDefinesString.write(',');
        }
      }

      cmd.add('-Pdart-defines=$dartDefinesString');
    }

    /// In Android Gradle Plugin 8.1.0 default behaviour has been changed
    /// and the application is uninstalled after integration tests.
    /// An issue has been reported:
    /// AGP 8.1.0 uninstalls app after running instrumented tests - 7.4.2 does not:
    /// https://issuetracker.google.com/issues/295039976
    /// New solution to change this behaviour has been introduced in AGP 8.2.0:
    /// https://developer.android.com/build/releases/past-releases/agp-8-2-0-release-notes
    ///
    /// To keep the app installed after the test finishes on Android
    /// with AGP 8.2 or higher, add in `gradle.properties`:
    /// ```
    /// android.injected.androidTest.leaveApksInstalledAfterRun=true
    /// ```
    if (noUninstallAfterTests) {
      cmd.add('-Pandroid.injected.androidTest.leaveApksInstalledAfterRun=true');
    }

    // Add app and test server ports
    cmd
      ..add('-Papp-server-port=$appServerPort')
      ..add('-Ptest-server-port=$testServerPort');

    return cmd;
  }
}

class IOSAppOptions {
  IOSAppOptions({
    required this.flutter,
    this.bundleId,
    required this.scheme,
    required this.configuration,
    required this.simulator,
    required this.osVersion,
    required this.appServerPort,
    required this.testServerPort,
    this.fullIsolation = false,
    this.clearIOSPermissions = false,
    this.addToApp = false,
    this.nativeIosPath,
    this.workspaceName = 'Runner.xcworkspace',
    this.uiTestTargetName = 'RunnerUITests',
    this.derivedDataPath = '../build/ios_integ',
  });

  final FlutterAppOptions flutter;
  final String? bundleId;
  final String scheme;
  final String configuration;
  final String osVersion;
  final bool simulator;
  final int appServerPort;
  final int testServerPort;
  final bool fullIsolation;
  final bool clearIOSPermissions;
  final bool addToApp;

  /// Absolute path to an external native iOS project (used for add-to-app
  /// setups). When set, Patrol drives xcodebuild against this directory instead
  /// of the Flutter module's generated `.ios/` scaffold.
  final String? nativeIosPath;

  /// Xcode workspace filename (within `.ios/` or [nativeIosPath]) that
  /// xcodebuild targets. Defaults to `Runner.xcworkspace`.
  final String workspaceName;

  /// Name of the UI Test bundle target that hosts Patrol's runner.
  /// Defaults to `RunnerUITests`.
  final String uiTestTargetName;

  /// Xcode `-derivedDataPath`. Interpreted as relative to the xcodebuild working
  /// directory unless an absolute path is provided.
  final String derivedDataPath;

  String get description {
    final platform = simulator ? 'simulator' : 'device';
    return 'app with entrypoint ${basename(flutter.target)} for iOS $platform';
  }

  /// Translates these options into a proper flutter build invocation, which
  /// runs before xcodebuild and performs configuration.
  List<String> toFlutterBuildInvocation(BuildMode buildMode) {
    final cmd = [
      ...[flutter.command.executable, ...flutter.command.arguments],
      ...['build', 'ios'],
      '--no-version-check',
      '--suppress-analytics',
      ...[
        '--config-only',
        '--no-codesign',
        '--${buildMode.name}', // for example '--debug',
        if (simulator) '--simulator',
        if (flutter.noTreeShakeIcons) '--no-tree-shake-icons',
      ],
      if (flutter.flavor case final flavor?) ...['--flavor', flavor],
      if (flutter.buildName case final buildName?) ...[
        '--build-name',
        buildName,
      ],
      if (flutter.buildNumber case final buildNumber?) ...[
        '--build-number',
        buildNumber,
      ],
      ...['--target', flutter.target],
      for (final dartDefine in flutter.dartDefines.entries) ...[
        '--dart-define',
        '${dartDefine.key}=${dartDefine.value}',
      ],
      for (final dartDefineFromFilePath in flutter.dartDefineFromFilePaths) ...[
        '--dart-define-from-file',
        dartDefineFromFilePath,
      ],
    ];

    return cmd;
  }

  /// Translates these options into a proper `xcodebuild build-for-testing`
  /// invocation.
  List<String> buildForTestingInvocation() {
    final cmd = [
      ...['xcodebuild', 'build-for-testing'],
      ...['-workspace', workspaceName],
      ...['-scheme', scheme],
      ...['-configuration', configuration],
      ...['-sdk', if (simulator) 'iphonesimulator' else 'iphoneos'],
      ...[
        '-destination',
        'generic/platform=${simulator ? 'iOS Simulator' : 'iOS'}',
      ],
      '-quiet',
      ...['-derivedDataPath', derivedDataPath],
      r'OTHER_SWIFT_FLAGS=$(inherited) -D PATROL_ENABLED',
      'OTHER_CFLAGS=\$(inherited) -D FULL_ISOLATION=${fullIsolation ? 1 : 0} -D CLEAR_PERMISSIONS=${clearIOSPermissions ? 1 : 0}',
    ];

    return cmd;
  }

  /// Translates these options into a proper `xcodebuild test-without-building`
  /// invocation.
  List<String> testWithoutBuildingInvocation(
    Device device, {
    required String xcTestRunPath,
    required String resultBundlePath,
  }) {
    final cmd = [
      ...['xcodebuild', 'test-without-building'],
      ...['-xctestrun', xcTestRunPath],
      ...['-only-testing', '$uiTestTargetName/$uiTestTargetName'],
      ...[
        '-destination',
        'platform=${device.real ? 'iOS' : 'iOS Simulator,OS=$osVersion'},name=${device.name}',
      ],
      ...['-destination-timeout', '1'],
      ...['-resultBundlePath', resultBundlePath],
    ];

    return cmd;
  }
}

class MacOSAppOptions {
  MacOSAppOptions({
    required this.flutter,
    this.bundleId,
    required this.scheme,
    required this.configuration,
    required this.appServerPort,
    required this.testServerPort,
  });

  final FlutterAppOptions flutter;
  final String? bundleId;
  final String scheme;
  final String configuration;
  final int appServerPort;
  final int testServerPort;

  String get description {
    return 'app with entrypoint ${basename(flutter.target)} for macos';
  }

  /// Translates these options into a proper flutter build invocation, which
  /// runs before xcodebuild and performs configuration.
  List<String> toFlutterBuildInvocation(BuildMode buildMode) {
    final cmd = [
      ...[flutter.command.executable, ...flutter.command.arguments],
      ...['build', 'macos'],
      '--no-version-check',
      '--suppress-analytics',
      ...[
        '--config-only',
        '--${buildMode.name}', // for example '--debug',
      ],
      if (flutter.flavor case final flavor?) ...['--flavor', flavor],
      if (flutter.buildName case final buildName?) ...[
        '--build-name',
        buildName,
      ],
      if (flutter.buildNumber case final buildNumber?) ...[
        '--build-number',
        buildNumber,
      ],
      ...['--target', flutter.target],
      for (final dartDefine in flutter.dartDefines.entries) ...[
        '--dart-define',
        '${dartDefine.key}=${dartDefine.value}',
      ],
      for (final dartDefineFromFilePath in flutter.dartDefineFromFilePaths) ...[
        '--dart-define-from-file',
        dartDefineFromFilePath,
      ],
    ];

    return cmd;
  }

  /// Translates these options into a proper `xcodebuild build-for-testing`
  /// invocation.
  List<String> buildForTestingInvocation() {
    final cmd = [
      ...['xcodebuild', 'build-for-testing'],
      ...['-workspace', 'Runner.xcworkspace'],
      ...['-scheme', scheme],
      ...['-configuration', configuration],
      '-quiet',
      ...['-derivedDataPath', '../build/macos_integ'],
      r'OTHER_SWIFT_FLAGS=$(inherited) -D PATROL_ENABLED',
    ];

    return cmd;
  }

  /// Translates these options into a proper `xcodebuild test-without-building`
  /// invocation.
  List<String> testWithoutBuildingInvocation(
    Device device, {
    required String xcTestRunPath,
    required String resultBundlePath,
  }) {
    final cmd = [
      ...['xcodebuild', 'test-without-building'],
      ...['-xctestrun', xcTestRunPath],
      ...['-only-testing', 'RunnerUITests/RunnerUITests'],
      ...['-destination', 'platform=macOS'],
      ...['-resultBundlePath', resultBundlePath],
      '-verbose',
    ];

    return cmd;
  }
}

class WebAppOptions {
  const WebAppOptions({
    required this.flutter,
    this.resultsDir,
    this.reportDir,
    this.retries,
    this.video,
    this.timeout,
    this.workers,
    this.reporter,
    this.locale,
    this.timezone,
    this.colorScheme,
    this.geolocation,
    this.permissions,
    this.userAgent,
    this.viewport,
    this.globalTimeout,
    this.shard,
    this.headless,
    this.webPort,
    this.serverTimeout,
    this.browserArgs,
  });

  final FlutterAppOptions flutter;
  final String? resultsDir;
  final String? reportDir;
  final int? retries;
  final String? video;
  final int? timeout;
  final int? workers;
  final String? reporter;
  final String? locale;
  final String? timezone;
  final String? colorScheme;
  final String? geolocation;
  final String? permissions;
  final String? userAgent;
  final String? viewport;
  final int? globalTimeout;
  final String? shard;
  final String? headless;
  final int? webPort;
  final String? browserArgs;

  /// Timeout in seconds for the web server to start.
  /// Defaults to 120 seconds (2 minutes) if not specified.
  final int? serverTimeout;

  /// Translates these options into a proper flutter build invocation.
  List<String> toFlutterBuildInvocation() {
    final cmd = [
      flutter.command.executable,
      ...flutter.command.arguments,
      'build',
      'web',
      '--target=${flutter.target}',
      '--${flutter.buildMode.name}',
      // Note: --flavor is not supported for web, so we don't include it
      ...flutter.dartDefines.entries.map(
        (e) => '--dart-define=${e.key}=${e.value}',
      ),
      ...flutter.dartDefineFromFilePaths.map(
        (e) => '--dart-define-from-file=$e',
      ),
    ];

    return cmd;
  }
}
