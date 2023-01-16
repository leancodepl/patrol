import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_options.freezed.dart';

@freezed
class AppOptions with _$AppOptions {
  const factory AppOptions({
    required String target,
    required String? flavor,
    required Map<String, String> dartDefines,
  }) = _AppOptions;
}
