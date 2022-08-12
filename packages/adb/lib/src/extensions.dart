import 'dart:io';

/// Useful utilities for process result.
extension ProcessResultX on ProcessResult {
  /// A shortcut to avoid typing `as String` every time.
  ///
  /// If [stderr] is not a String, this will crash.
  String get stdErr => this.stderr as String;

  /// A shortcut to avoid typing `as String` every time.
  ///
  /// If [stdout] is not a String, this will crash.
  String get stdOut => this.stdout as String;
}
