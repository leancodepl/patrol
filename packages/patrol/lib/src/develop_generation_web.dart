// Identifier name is for JS interop only; its value is not significant in Dart.
// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';

// The counter lives on `window` rather than in a Dart static because DDC's hot
// restart resets statics and re-creates library objects: a static read by a
// closure from the previous generation would not observe the new value.
@JS()
external JSNumber? get __patrol__developGeneration;

@JS()
external set __patrol__developGeneration(JSNumber? value);

/// Claims a new generation, invalidating every previously claimed one.
int claimDevelopGeneration() {
  final next = (__patrol__developGeneration?.toDartInt ?? 0) + 1;
  __patrol__developGeneration = next.toJS;
  return next;
}

/// Whether [generation] is still the generation that owns the app.
bool isCurrentDevelopGeneration(int generation) =>
    (__patrol__developGeneration?.toDartInt ?? 0) == generation;
