import 'package:args/command_runner.dart';

extension CommandRunnerX on CommandRunner<void> {
  /// Workaround for https://github.com/dart-lang/args/issues/221.
  String get usageWithoutDescription {
    final crop = description.length + 2;
    return usage.substring(crop);
  }
}
