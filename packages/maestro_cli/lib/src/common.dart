// ignore_for_file: avoid_print

import 'package:ansi_styles/ansi_styles.dart';

/// Prints message that is only visible in verbose mode.
void verbose(String text) {
  print(text);
}

/// Prints normal, informative message.
void info(String text) {
  print(text);
}

void success(String text) {
  print(AnsiStyles.green(text));
}

void error(String text) {
  print(AnsiStyles.red(text));
}
