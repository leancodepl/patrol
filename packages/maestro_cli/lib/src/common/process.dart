import 'dart:io';

extension ProcessResultX on ProcessResult {
  /// A shortcut to avoid typing `as String` every time.
  ///
  /// If [stderr] is not a String, this will crash.
  String get stdErr => this.stderr as String;
}
