import 'dart:convert' show base64Encode, utf8;

import 'package:meta/meta.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';

class FlutterAppOptions {
  const FlutterAppOptions({
    required this.target,
    required this.flavor,
    required this.buildMode,
    required this.dartDefines,
  });

  final String target;
  final String? flavor;
  final BuildMode buildMode;
  final Map<String, String> dartDefines;

  /// Translates these options into a proper `flutter attach`.
  @nonVirtual
  List<String> toFlutterAttachInvocation() {
    final cmd = [
      ...['flutter', 'attach'],
      '--no-version-check',
      '--debug',
      ...['--target', target],
      for (final dartDefine in dartDefines.entries) ...[
        '--dart-define',
        '${dartDefine.key}=${dartDefine.value}',
      ],
    ];

    return cmd;
  }
}

class AndroidAppOptions {
  const AndroidAppOptions({
    required this.flutter,
    this.packageName,
  });

  final FlutterAppOptions flutter;
  final String? packageName;

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
  });

  final FlutterAppOptions flutter;
  final String? bundleId;
  final String scheme;
  final String configuration;
  bool simulator;

  String get description {
    final platform = simulator ? 'simulator' : 'device';
    return 'app with entrypoint ${basename(flutter.target)} for iOS $platform';
  }

  /// Translates these options into a proper flutter build invocation, which
  /// runs before xcodebuild and performs configuration.
  List<String> toFlutterBuildInvocation(BuildMode buildMode) {
    final cmd = [
      ...['flutter', 'build', 'ios'],
      '--no-version-check',
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
      ...['-only-testing', 'RunnerUITests'],
      ...['-sdk', if (simulator) 'iphonesimulator' else 'iphoneos'],
      ...[
        '-destination',
        'generic/platform=${simulator ? 'iOS Simulator' : 'iOS'}',
      ],
      '-quiet',
      ...['-derivedDataPath', '../build/ios_integ'],
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
      ...['-only-testing', 'RunnerUITests'],
      ...[
        '-destination',
        'platform=${device.real ? 'iOS' : 'iOS Simulator'},name=${device.name}',
      ],
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
  });

  final FlutterAppOptions flutter;
  final String? bundleId;
  final String scheme;
  final String configuration;

  String get description {
    return 'app with entrypoint ${basename(flutter.target)} for macos';
  }

  /// Translates these options into a proper flutter build invocation, which
  /// runs before xcodebuild and performs configuration.
  List<String> toFlutterBuildInvocation(BuildMode buildMode) {
    final cmd = [
      ...['flutter', 'build', 'macos'],
      '--no-version-check',
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
      ...['-only-testing', 'RunnerUITests'],
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
  }) {
    final cmd = [
      ...['xcodebuild', 'test-without-building'],
      ...['-xctestrun', xcTestRunPath],
      ...['-only-testing', 'RunnerUITests'],
      ...[
        '-destination',
        'platform=macOS',
      ],
      '-verbose',
    ];

    return cmd;
  }
}
