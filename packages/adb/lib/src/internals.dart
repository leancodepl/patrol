import 'dart:io';

import 'package:adb/src/extensions.dart';

class AdbInternals {
  const AdbInternals();

  Future<String> devices() async {
    final result = await Process.run(
      'adb',
      ['devices'],
      runInShell: true,
    );

    if (result.stdErr.isNotEmpty) {
      throw Exception(result.stdErr);
    }

    return result.stdOut;
  }
}
