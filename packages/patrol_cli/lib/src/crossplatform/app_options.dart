import 'dart:convert' show base64Encode, utf8;

import 'package:meta/meta.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';

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

  /// Translates these options into a host `flutter test` invocation that runs
  /// the bundle in build-time discovery mode and writes the test manifest to
  /// [manifestOutputPath].
  ///
  /// The same `--dart-define`s as the real build are forwarded on purpose: a
  /// test description can be built from a dart-define (e.g. a target env), so
  /// discovery must see the exact same config or the manifest names would
  /// diverge from what the on-device run registers.
  @nonVirtual
  List<String> toFlutterTestDiscoveryInvocation({
    required String manifestOutputPath,
  }) {
    return [
      ...[command.executable, ...command.arguments],
      'test',
      target,
      '--suppress-analytics',
      ...['--dart-define', 'PATROL_TEST_DISCOVERY=true'],
      ...['--dart-define', 'PATROL_MANIFEST_OUTPUT=$manifestOutputPath'],
      for (final dartDefine in dartDefines.entries) ...[
        '--dart-define',
        '${dartDefine.key}=${dartDefine.value}',
      ],
      for (final dartDefineFromFilePath in dartDefineFromFilePaths) ...[
        '--dart-define-from-file',
        dartDefineFromFilePath,
      ],
    ];
  }
}

class AndroidAppOptions {
  const AndroidAppOptions({
    required this.flutter,
    this.packageName,
    required this.appServerPort,
    required this.testServerPort,
    required this.uninstall,
    this.emitTestManifest = false,
  });

  final FlutterAppOptions flutter;
  final String? packageName;
  final int appServerPort;
  final int testServerPort;
  final bool uninstall;

  /// Whether to discover Dart tests at build time (host `flutter test`) and
  /// generate static JUnit test methods, so each Dart test becomes a real,
  /// individually-selectable native test. Experimental, opt-in.
  final bool emitTestManifest;

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

  List<String> toGradleConnectedTestInvocation({
    required bool isWindows,
    String? onlyTestClass,
  }) {
    // for example: connectedDevDebugAndroidTest, connectedReleaseAndroidTest
    return _toGradleInvocation(
      isWindows: isWindows,
      task: 'connected$_effectiveFlavor${_buildMode}AndroidTest',
      noUninstallAfterTests: !uninstall,
      // Restrict the run to the generated static class (the Android analog of
      // iOS `-only-testing`). This also stops the parameterized host class from
      // performing its runtime discovery launch.
      onlyTestClass: onlyTestClass,
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
    String? onlyTestClass,
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

    // Run only the generated static test class, if requested.
    if (onlyTestClass != null) {
      cmd.add(
        '-Pandroid.testInstrumentationRunnerArguments.class=$onlyTestClass',
      );
    }

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
    this.emitTestManifest = false,
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

  /// Whether to discover Dart tests at build time (host `flutter test`) and
  /// embed a manifest into the test bundle, so the native runner can skip the
  /// runtime discovery launch. Experimental, opt-in.
  final bool emitTestManifest;

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
      ...['-workspace', 'Runner.xcworkspace'],
      ...['-scheme', scheme],
      ...['-configuration', configuration],
      ...['-sdk', if (simulator) 'iphonesimulator' else 'iphoneos'],
      ...[
        '-destination',
        'generic/platform=${simulator ? 'iOS Simulator' : 'iOS'}',
      ],
      '-quiet',
      ...['-derivedDataPath', '../build/ios_integ'],
      r'OTHER_SWIFT_FLAGS=$(inherited) -D PATROL_ENABLED',
      r'OTHER_LDFLAGS=$(inherited) -weak_framework XCTest -F$(PLATFORM_DIR)/Developer/Library/Frameworks -L$(PLATFORM_DIR)/Developer/usr/lib',
      'OTHER_CFLAGS=\$(inherited) -D FULL_ISOLATION=${fullIsolation ? 1 : 0} -D CLEAR_PERMISSIONS=${clearIOSPermissions ? 1 : 0}',
    ];

    return cmd;
  }

  /// Translates these options into a proper `xcodebuild test-without-building`
  /// invocation.
  ///
  /// When [onlyTesting] is non-empty, one `-only-testing` selector is emitted per
  /// entry (`RunnerUITests/RunnerUITests/<selector>`), restricting the run to
  /// those specific generated tests; otherwise the whole `RunnerUITests` class
  /// runs. Per-test selectors require the static codegen (build-time discovery).
  List<String> testWithoutBuildingInvocation(
    Device device, {
    required String xcTestRunPath,
    required String resultBundlePath,
    List<String> onlyTesting = const [],
  }) {
    final destination = device.real
        ? 'platform=iOS,id=${device.id}'
        : 'platform=iOS Simulator,id=${device.id},OS=$osVersion';

    final cmd = [
      ...['xcodebuild', 'test-without-building'],
      ...['-xctestrun', xcTestRunPath],
      if (onlyTesting.isEmpty)
        ...['-only-testing', 'RunnerUITests/RunnerUITests']
      else
        for (final selector in onlyTesting)
          ...['-only-testing', 'RunnerUITests/RunnerUITests/$selector'],
      ...['-destination', destination],
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
      r'OTHER_LDFLAGS=$(inherited) -weak_framework XCTest -F$(PLATFORM_DIR)/Developer/Library/Frameworks -L$(PLATFORM_DIR)/Developer/usr/lib',
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
    this.channel,
    this.executablePath,
    this.slowMo,
    this.chromiumSandbox,
    this.downloadsPath,
    this.ignoreDefaultArgs,
    this.proxy,
    this.browserTimeout,
    this.tracesDir,
    this.bypassCsp,
    this.ignoreHttpsErrors,
    this.offline,
    this.httpCredentials,
    this.extraHttpHeaders,
    this.screenshot,
    this.trace,
    this.storageState,
    this.acceptDownloads,
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
  final bool? headless;
  final int? webPort;
  final String? browserArgs;
  final String? channel;
  final String? executablePath;
  final int? slowMo;
  final bool? chromiumSandbox;
  final String? downloadsPath;
  final String? ignoreDefaultArgs;
  final String? proxy;
  final int? browserTimeout;
  final String? tracesDir;
  final bool? bypassCsp;
  final bool? ignoreHttpsErrors;
  final bool? offline;
  final String? httpCredentials;
  final String? extraHttpHeaders;
  final String? screenshot;
  final String? trace;
  final String? storageState;
  final bool? acceptDownloads;

  /// Timeout in seconds for the web server to start.
  /// Defaults to 120 seconds (2 minutes) if not specified.
  final int? serverTimeout;

  /// Translates these options into environment variables consumed by the
  /// Playwright web runner. Unset options are omitted.
  Map<String, String> toEnvironmentVariables() {
    final values = <String, Object?>{
      'PATROL_WEB_RETRIES': retries,
      'PATROL_WEB_VIDEO': video,
      'PATROL_WEB_TIMEOUT': timeout,
      'PATROL_WEB_WORKERS': workers,
      'PATROL_WEB_REPORTER': reporter,
      'PATROL_WEB_LOCALE': locale,
      'PATROL_WEB_TIMEZONE': timezone,
      'PATROL_WEB_COLOR_SCHEME': colorScheme,
      'PATROL_WEB_GEOLOCATION': geolocation,
      'PATROL_WEB_PERMISSIONS': permissions,
      'PATROL_WEB_USER_AGENT': userAgent,
      'PATROL_WEB_VIEWPORT': viewport,
      'PATROL_WEB_GLOBAL_TIMEOUT': globalTimeout,
      'PATROL_WEB_SHARD': shard,
      'PATROL_WEB_HEADLESS': headless,
      'PATROL_WEB_BROWSER_ARGS': browserArgs,
      'PATROL_WEB_CHANNEL': channel,
      'PATROL_WEB_EXECUTABLE_PATH': executablePath,
      'PATROL_WEB_SLOW_MO': slowMo,
      'PATROL_WEB_CHROMIUM_SANDBOX': chromiumSandbox,
      'PATROL_WEB_DOWNLOADS_PATH': downloadsPath,
      'PATROL_WEB_IGNORE_DEFAULT_ARGS': ignoreDefaultArgs,
      'PATROL_WEB_PROXY': proxy,
      'PATROL_WEB_BROWSER_TIMEOUT': browserTimeout,
      'PATROL_WEB_TRACES_DIR': tracesDir,
      'PATROL_WEB_BYPASS_CSP': bypassCsp,
      'PATROL_WEB_IGNORE_HTTPS_ERRORS': ignoreHttpsErrors,
      'PATROL_WEB_OFFLINE': offline,
      'PATROL_WEB_HTTP_CREDENTIALS': httpCredentials,
      'PATROL_WEB_EXTRA_HTTP_HEADERS': extraHttpHeaders,
      'PATROL_WEB_SCREENSHOT': screenshot,
      'PATROL_WEB_TRACE': trace,
      'PATROL_WEB_STORAGE_STATE': storageState,
      'PATROL_WEB_ACCEPT_DOWNLOADS': acceptDownloads,
    };

    return {
      for (final entry in values.entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };
  }

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
