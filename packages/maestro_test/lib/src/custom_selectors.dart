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
  print('Expression parts: $parts');

  final finders = <Finder>[];
  for (final part in parts) {
    if (part.alphanumeric) {
      print('part $part is alphanumeric');
      finders.add(find.text(part));
      continue;
    }

    if (part == '>') {
      // TODO: hacky
      continue;
    }

    // If part is not alphanumeric, it should have a specifier in the front.
    final possibleSpecifierType = part.substring(0, 1);
    final possibleSpecifierValue = part.substring(1);

    // Match by Widget's class.
    if (possibleSpecifierType == '.') {
      throw UnimplementedError('Class specifier is not implemented yet');
    }

    // Match by Widget's key.
    if (possibleSpecifierType == '#') {
      finders.add(find.byKey(ValueKey(possibleSpecifierValue)));
      continue;
    }

    throw Exception('unknown specifier type: $possibleSpecifierType');
  }

  if (finders.length < 2) {
    return finders.first;
  }

  final finderResult = find.descendant(
    matching: finders.last,
    of: _findDescendant(finders, finders.length - 2),
  );

  return finderResult;
}

Finder _findDescendant(List<Finder> finders, int index) {
  final of = index == 1 ? finders.first : _findDescendant(finders, index - 1);

  return find.descendant(
    matching: finders[index],
    of: of,
  );
}

extension _StringX on String {
  bool get alphanumeric {
    for (final rune in runes) {
      final isAlphanumeric = (rune >= 48 && rune <= 57) ||
          (rune >= 65 && rune <= 90) ||
          (rune >= 97 && rune <= 122);

      if (!isAlphanumeric) {
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
