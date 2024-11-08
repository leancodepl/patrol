class AnsiCodes {
  /// This is the Unicode escape sequence for the ASCII escape character (ESC).
  static const String escape = '\u001b';

  /// `[0m` - Reset all styles.
  static const String reset = '$escape[0m';

  /// `[1m` - Set text to bold.
  static const String bold = '$escape[1m';

  /// `[30m` - Set text color to gray.
  static const String gray = '$escape[30m';

  /// `[38;5;87m` - Set text color to light blue. Used for native actions.
  static const String lightBlue = '$escape[38;5;87m';

  static String custom(String color) => '$escape[${color}m';

  static String get green => custom('32');
  static String get yellow => custom('33');
  static String get blue => custom('34');
  static String get magenta => custom('35');
  static String get cyan => custom('36');
}
