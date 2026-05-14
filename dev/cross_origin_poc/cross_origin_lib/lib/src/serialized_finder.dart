import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';

/// Serializable representation of a Flutter widget finder.
///
/// Used to send finder specifications across the postMessage boundary between
/// the controller app and DUT apps in the cross-origin PoC.
sealed class SerializedFinder {
  const SerializedFinder();

  Map<String, Object?> toJson();

  /// Materialises this serialized finder into a real flutter_test [Finder] in
  /// the DUT isolate.
  Finder toFinder();

  static SerializedFinder fromJson(Map<String, Object?> json) {
    final kind = json['kind'] as String;
    switch (kind) {
      case 'byKey':
        return ByKeyFinder(json['value']! as String);
      case 'byText':
        return ByTextFinder(json['value']! as String);
      case 'descendant':
        return DescendantFinder(
          of: SerializedFinder.fromJson(
            (json['of']! as Map).cast<String, Object?>(),
          ),
          matching: SerializedFinder.fromJson(
            (json['matching']! as Map).cast<String, Object?>(),
          ),
        );
      default:
        throw ArgumentError('Unknown SerializedFinder kind: $kind');
    }
  }
}

class ByKeyFinder extends SerializedFinder {
  const ByKeyFinder(this.value);
  final String value;

  @override
  Map<String, Object?> toJson() => {'kind': 'byKey', 'value': value};

  @override
  Finder toFinder() => find.byKey(Key(value));
}

class ByTextFinder extends SerializedFinder {
  const ByTextFinder(this.value);
  final String value;

  @override
  Map<String, Object?> toJson() => {'kind': 'byText', 'value': value};

  @override
  Finder toFinder() => find.text(value);
}

class DescendantFinder extends SerializedFinder {
  const DescendantFinder({required this.of, required this.matching});
  final SerializedFinder of;
  final SerializedFinder matching;

  @override
  Map<String, Object?> toJson() => {
    'kind': 'descendant',
    'of': of.toJson(),
    'matching': matching.toJson(),
  };

  @override
  Finder toFinder() =>
      find.descendant(of: of.toFinder(), matching: matching.toFinder());
}

// Mirror of patrol_finders' private SymbolName extension. Inlined because
// `patrol_finders` doesn't re-export utils.dart.
String _symbolName(Symbol s) {
  final str = s.toString();
  return str.substring(8, str.length - 2); // 'Symbol("foo")' -> 'foo'
}

/// Convenience factory namespace, mirrors flutter_test's `find.*`.
abstract final class SF {
  static SerializedFinder byKey(String key) => ByKeyFinder(key);
  static SerializedFinder byText(String text) => ByTextFinder(text);
  static SerializedFinder descendant({
    required SerializedFinder of,
    required SerializedFinder matching,
  }) => DescendantFinder(of: of, matching: matching);
}

/// Serializes a [PatrolFinder] by inspecting its underlying [Finder].
///
/// Throws [UnsupportedError] if the finder shape can't be expressed as a
/// [SerializedFinder] (e.g. predicate-based finders).
extension PatrolFinderSerialization on PatrolFinder {
  SerializedFinder toSerialized() => serializeFinder(finder);
}

/// Serializes a raw flutter_test [Finder] by introspecting its private type.
///
/// flutter_test's concrete finder classes (`_KeyFinder`, `_TextFinder`,
/// `_DescendantFinder`) are private; this function identifies them by
/// `runtimeType.toString()` and reads their public fields via `dynamic`.
/// If Flutter renames those internals in a future release, this function
/// throws — by design (the user explicitly accepted "if it can't be done,
/// throw and it's fine").
SerializedFinder serializeFinder(Finder finder) {
  final typeName = finder.runtimeType.toString();
  final dynamic dyn = finder;

  switch (typeName) {
    case '_KeyFinder':
      final Object key = dyn.key as Object;
      if (key is ValueKey) {
        return ByKeyFinder(key.value.toString());
      }
      throw UnsupportedError(
        'Cannot serialize Key of type ${key.runtimeType}. '
        'Only ValueKey is supported.',
      );
    case '_TextFinder':
      return ByTextFinder(dyn.text as String);
    case '_DescendantFinder':
      return DescendantFinder(
        of: serializeFinder(dyn.ancestor as Finder),
        matching: serializeFinder(dyn.descendant as Finder),
      );
    default:
      throw UnsupportedError(
        'Cannot serialize Finder of runtime type "$typeName". '
        'Supported: _KeyFinder, _TextFinder, _DescendantFinder. '
        'For other finders, build a SerializedFinder directly via SF.*.',
      );
  }
}

/// Accepts the same matching types as `PatrolTester.call()` (the `$` operator)
/// plus our own [SerializedFinder], and returns a [SerializedFinder].
///
/// Accepted:
///   * [SerializedFinder]            — passthrough
///   * [PatrolFinder]                — via [PatrolFinderSerialization]
///   * [Finder]                      — via [serializeFinder]
///   * [ValueKey]                    — direct byKey
///   * [Symbol] (e.g. `#login`)      — byKey with the symbol name
///   * [String]                      — byText
SerializedFinder serializeMatching(Object matching) {
  if (matching is SerializedFinder) return matching;
  if (matching is PatrolFinder) return matching.toSerialized();
  if (matching is Finder) return serializeFinder(matching);
  if (matching is ValueKey) return ByKeyFinder(matching.value.toString());
  if (matching is Key) {
    throw UnsupportedError(
      'Cannot serialize Key of type ${matching.runtimeType}. '
      'Only ValueKey is supported.',
    );
  }
  if (matching is Symbol) return ByKeyFinder(_symbolName(matching));
  if (matching is String) return ByTextFinder(matching);
  throw ArgumentError(
    'Cannot serialize matching argument of type ${matching.runtimeType}. '
    'Supported: SerializedFinder, PatrolFinder, Finder, ValueKey, Symbol, String.',
  );
}
