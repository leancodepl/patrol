import 'dart:async';
import 'dart:io' show Process;

import 'package:patrol_cli/src/base/logger.dart';

/// Forwards the `patrol develop` key commands from [stdin] to the
/// `flutter run` [flutterProcess] of a Linux develop session.
///
/// * `r` / `R` sends a hot restart (`R`) to [flutterProcess].
/// * `h` / `H` prints the key commands.
/// * `q` / `Q` reverts the terminal mode and calls [onQuit], which stops
///   [flutterProcess]. Later keys are ignored.
///
/// Writes to [flutterProcess] go one after another, each flushed before the
/// next starts, because an `IOSink` rejects a write while it flushes. [onQuit]
/// runs after the pending writes.
///
/// The caller cancels the returned subscription.
StreamSubscription<List<int>> forwardDevelopKeys({
  required Process flutterProcess,
  required Stream<List<int>> stdin,
  required Logger logger,
  required void Function() revertInteractiveMode,
  required Future<void> Function() onQuit,
}) {
  var pending = Future<void>.value();
  var quitting = false;

  Future<void> sendHotRestart() async {
    try {
      flutterProcess.stdin.add('R'.codeUnits);
      await flutterProcess.stdin.flush();
    } on Object catch (err) {
      logger.detail('Failed to send hot restart to Flutter: $err');
    }
  }

  return stdin.listen((event) {
    if (quitting) {
      return;
    }
    final char = String.fromCharCode(event.first);
    logger.detail('Flutter stdin: $char');

    switch (char) {
      case 'r' || 'R':
        pending = pending.then((_) => sendHotRestart());
      case 'h' || 'H':
        logger.success(
          'Patrol develop key commands:\n'
          'r Hot restart\n'
          'h Print this help message\n'
          'q Quit (terminate the process and application on the device)',
        );
      case 'q' || 'Q':
        quitting = true;
        revertInteractiveMode();
        logger.success('Quitting process...');
        pending = pending.then((_) => onQuit());
    }
  });
}
