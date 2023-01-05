import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_runner.freezed.dart';

enum Platform { android, iphoneos, iphonesimulator }

@freezed
class AppOptions with _$AppOptions {
  const factory AppOptions({
    required String target,
    required String? flavor,
    required Map<String, String> dartDefines,
    required Platform platform,
  }) = _AppOptions;
}

class TestRunner {
  Future<void> run(AppOptions options) async {
    throw UnimplementedError('`run()` must be implemented');
  }
}
