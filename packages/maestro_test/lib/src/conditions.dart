import 'package:freezed_annotation/freezed_annotation.dart';

part 'conditions.freezed.dart';
part 'conditions.g.dart';

@freezed
class Conditions with _$Conditions {
  const factory Conditions({
    String? clazz,
    bool? enabled,
    bool? focused,
    String? text,
    String? textContains,
    String? contentDescription,
  }) = _Conditions;

  factory Conditions.fromJson(Map<String, dynamic> json) =>
      _$ConditionsFromJson(json);
}
