import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A helper method that makes it easy to find Flutter widgets in tests. You
/// give us the String expression, and we give you the Widget you're looking
/// for.
///
/// There are 3 "type specifiers":
/// - `.` matches Widget by type.
///
///     Example:
///     ```dart
///     final textField = $('.TextField');
///     textField.enterText('user@example.com');
///     ```
///
/// - `#` matches Widget by ValueKey.
///
///     Example:
///     ```dart
///     final textField = $('#emailTextField');
///     textField.enterText('user@example.com');
///     ```
/// - raw text matches Widget by the text it contains.
///
///     Example:
///     ```dart
///     final textField = $('Enter email address');
///     textField.enterText('user@example.com');
///     ```
///
/// ### Chaining
///
/// Selectors can be chained, which allows you to write more expressive test
/// code.
///
/// Taps on a Widget of type IconButton which is the descendant of a Widget with
/// ValueKey with value
/// ```dart
///  final passwordVisibilityToggle = $('#passwordTextField > .IconButton');
///  passwordVisibilityToggle.tap();
///  ```
Finder $(String expression) {
  final parts = expression.split(' ');

  final finders = <Finder>[];
  for (final part in parts) {
    if (part.alphanumeric) {
      finders.add(find.text(part));
      continue;
    }

    // If part is not alphanumeric, it should have a specifier in the front.
    final possibleSpecifier = part.substring(0, 1);

    // Match by Widget's class.
    if (possibleSpecifier == '.') {
      throw UnimplementedError('Class specifier is not implemented yet');
    }

    // Match by Widget's key.
    if (possibleSpecifier == '#') {
      finders.add(find.byKey(ValueKey(possibleSpecifier)));
      continue;
    }

    throw Exception('unknown specifier: $possibleSpecifier');
  }

  return finders[0];
}

extension _StringX on String {
  bool get alphanumeric {
    for (final rune in runes) {
      if (rune < 48 || rune > 90) {
        return false;
      }
    }

    return true;
  }
}

/// Powerful custom selectors extending the default Flutter [Finder].
extension MaestroFinders on Finder {
  /// See [$].
  Finder? $(String expression) {
    return null;
  }
}
