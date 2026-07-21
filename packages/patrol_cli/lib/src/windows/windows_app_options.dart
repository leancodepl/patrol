import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart' show BuildMode;

/// Options for building and running a Flutter Windows app under Patrol.
class WindowsAppOptions {
  /// Creates [WindowsAppOptions].
  const WindowsAppOptions({
    required this.flutter,
    required this.appServerPort,
    required this.testServerPort,
  });

  /// Flutter build options.
  final FlutterAppOptions flutter;

  /// Port of PatrolAppService inside the app (8082).
  final int appServerPort;

  /// Port of the Windows automator sidecar (8081).
  final int testServerPort;

  /// Human-readable description.
  String get description =>
      'windows app with entrypoint ${basename(flutter.target)}';

  /// `flutter build windows` invocation for the Patrol test entrypoint.
  List<String> toFlutterBuildInvocation(BuildMode buildMode) {
    return [
      ...[flutter.command.executable, ...flutter.command.arguments],
      'build',
      'windows',
      '--no-version-check',
      '--suppress-analytics',
      '--${buildMode.name}',
      if (flutter.noTreeShakeIcons) '--no-tree-shake-icons',
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
  }
}
