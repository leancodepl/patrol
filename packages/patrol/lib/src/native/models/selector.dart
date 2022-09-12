import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patrol/src/custom_finders/custom_finders.dart';

part 'selector.freezed.dart';
part 'selector.g.dart';

/// Matches widgets on the underlying native platform.
///
/// This *does not* match Flutter widgets. If you want to use Patrol's _custom
/// selector_, see [PatrolTester] and [PatrolFinder].
@freezed
class Selector with _$Selector {
  /// Creates a new [Selector].
  const factory Selector({
    String? text,
    String? textStartsWith,
    String? textContains,
    String? className,
    String? contentDescription,
    String? contentDescriptionStartsWith,
    String? contentDescriptionContains,
    String? resourceId,
    int? instance,
    bool? enabled,
    bool? focused,
    String? packageName,
  }) = _Selector;

  /// Creates a new [Selector] from JSON.
  factory Selector.fromJson(Map<String, dynamic> json) =>
      _$SelectorFromJson(json);
}
