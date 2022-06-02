import 'dart:io';

extension ProcessResultX on ProcessResult {
  String get stdErr => this.stderr as String;
}
