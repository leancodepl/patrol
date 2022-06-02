import 'dart:io';

extension ProcessResultX on ProcessResult {
  String get stdErr => stderr as String;
}
