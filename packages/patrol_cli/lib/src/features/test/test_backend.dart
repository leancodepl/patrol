import 'package:meta/meta.dart';

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
