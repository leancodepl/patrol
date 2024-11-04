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
  });

  final FlutterCommand command;
  final String target;
  final String? flavor;
  final BuildMode buildMode;
  final Map<String, String> dartDefines;
  final List<String> dartDefineFromFilePaths;

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

class AndroidAppOptions {
  const AndroidAppOptions({
    required this.flutter,
    this.packageName,
    required this.appServerPort,
    required this.testServerPort,
  });

  final FlutterAppOptions flutter;
  final String? packageName;
  final int appServerPort;
  final int testServerPort;

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
    );
  }

  List<String> toGradleConnectedTestInvocation({required bool isWindows}) {
    // for example: connectedDevDebugAndroidTest, connectedReleaseAndroidTest
    return _toGradleInvocation(
      isWindows: isWindows,
      task: 'connected$_effectiveFlavor${_buildMode}AndroidTest',
    );
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

    // Add Dart defines encoded in base64
    if (flutter.dartDefines.isNotEmpty) {
      final dartDefinesString = StringBuffer();
      for (var i = 0; i < flutter.dartDefines.length; i++) {
        final entry = flutter.dartDefines.entries.elementAt(i);
        final pair = utf8.encode('${entry.key}=${entry.value}');
        dartDefinesString.write(base64Encode(pair));
        if (i != flutter.dartDefines.length - 1) {
          dartDefinesString.write(',');
        }
      }

      cmd.add('-Pdart-defines=$dartDefinesString');
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
    required this.appServerPort,
    required this.testServerPort,
    this.clearPermissions = false,
  });

  final FlutterAppOptions flutter;
  final String? bundleId;
  final String scheme;
  final String configuration;
  final bool simulator;
  final int appServerPort;
  final int testServerPort;
  final bool clearPermissions;

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
      ],
      if (flutter.flavor != null) ...['--flavor', flutter.flavor!],
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
      if (clearPermissions)
        r'GCC_PREPROCESSOR_DEFINITIONS=$(inherited) CLEAR_PERMISSIONS=1',
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
      ...[
        '-destination',
        'platform=${device.real ? 'iOS' : 'iOS Simulator'},name=${device.name}',
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
      if (flutter.flavor != null) ...['--flavor', flutter.flavor!],
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
