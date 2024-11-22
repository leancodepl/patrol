class AnsiCodes {
  /// This is the Unicode escape sequence for the ASCII escape character (ESC).
  static const String escape = '\u001b';

  /// `[0m` - Reset all styles.
  static const String reset = '$escape[0m';

  /// `[1m` - Set text to bold.
  static const String bold = '$escape[1m';

  static String color(String color) => '$escape[${color}m';

  static String gray = color('30');
  static String red = color('31');
  static String green = color('32');
  static String yellow = color('33');
  static String blue = color('34');
  static String lightBlue = color('38;5;87');
  static String magenta = color('35');
  static String cyan = color('36');
  static String orange = color('38;5;208');
}
