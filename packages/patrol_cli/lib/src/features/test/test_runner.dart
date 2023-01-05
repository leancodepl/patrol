import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';

part 'test_runner.freezed.dart';

@freezed
class AppOptions with _$AppOptions {
  const factory AppOptions({
    required String target,
    required String? flavor,
    required Map<String, String> dartDefines,
  }) = _AppOptions;
}

class TestRunner {
  Future<void> run(AppOptions options, Device device) async {
    throw UnimplementedError('`run()` must be implemented');
  }
}
