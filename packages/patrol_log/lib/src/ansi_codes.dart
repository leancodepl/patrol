class AnsiCodes {
  /// This is the Unicode escape sequence for the ASCII escape character (ESC).
  static const String escape = '\u001b';

  /// `[0m` - Reset all styles.
  static const String reset = '$escape[0m';

  /// `[1m` - Set text to bold.
  static const String bold = '$escape[1m';

  static String color(String color) => '$escape[${color}m';

  static String gray = color('30');
  static String get red => color('31');
  static String get green => color('32');
  static String get yellow => color('33');
  static String get blue => color('34');
  static String get lightBlue => color('38;5;87');
  static String get magenta => color('35');
  static String get cyan => color('36');
  static String get orange => color('38;5;208');
}
