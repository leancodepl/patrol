import 'package:flutter/material.dart';

/// Makes it possible to retrieve a name that this [Symbol] was created with.
extension SymbolName on Symbol {
  /// Returns the name that this [Symbol] was created with.
  ///
  /// It's kinda hacky, but works well. Might require adjustements to work on
  /// the web though.
  String get name {
    final symbol = toString();
    return symbol.substring(8, symbol.length - 2);
  }
}

/// List of all [Alignment] values.
const alignments = [
  Alignment.center,
  Alignment.bottomCenter,
  Alignment.bottomLeft,
  Alignment.bottomRight,
  Alignment.centerLeft,
  Alignment.centerRight,
  Alignment.topCenter,
  Alignment.topLeft,
  Alignment.topRight,
];
