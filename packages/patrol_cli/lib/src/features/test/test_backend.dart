import 'package:meta/meta.dart';
import 'package:patrol_cli/src/features/devices/device.dart';

abstract class AppOptions {
  const AppOptions({
    required this.target,
    required this.flavor,
    required this.dartDefines,
  });

  final String target;
  final String? flavor;
  final Map<String, String> dartDefines;

  String get description;

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

abstract class TestBackend {
  Future<void> build(covariant AppOptions options);
  Future<void> execute(covariant AppOptions options, Device device);
  Future<void> uninstall(String appId, Device device);
}
