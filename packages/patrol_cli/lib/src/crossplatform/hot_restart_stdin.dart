import 'dart:async';
import 'dart:io' show Process, exit;

import 'package:patrol_cli/src/base/logger.dart';

/// Forwards the `patrol develop` key commands from [stdin] to a `flutter run`
/// [flutterProcess] that Patrol started itself (web and Linux desktop, where
/// `flutter attach` is not used).
///
/// * `r` / `R` sends a hot restart (`R`) to [flutterProcess].
/// * `h` / `H` prints the key commands.
/// * `q` / `Q` reverts the terminal mode, kills [flutterProcess] and calls
///   [onQuit] (by default, exits the CLI with code 0).
///
/// If [listenFor] is set, the returned subscription is cancelled after that
/// time. Otherwise the caller cancels it.
StreamSubscription<List<int>> forwardHotRestartKeys({
  required Process flutterProcess,
  required Stream<List<int>> stdin,
  required Logger logger,
  void Function()? revertInteractiveMode,
  void Function()? onQuit,
  Duration? listenFor,
}) {
  final streamSubscription = stdin.listen((event) {
    final char = String.fromCharCode(event.first);

    logger.detail('Flutter stdin: $char');

    if (char == 'r' || char == 'R') {
      flutterProcess.stdin.add('R'.codeUnits);
    } else if (char == 'h' || char == 'H') {
      logger.success(
        'Patrol develop key commands:\n'
        'r Hot restart\n'
        'h Print this help message\n'
        'q Quit (terminate the process and application on the device)',
      );
    } else if (char == 'q' || char == 'Q') {
      revertInteractiveMode?.call();

      logger.success('Quitting process...');
      flutterProcess.kill();

      if (onQuit != null) {
        onQuit();
      } else {
        exit(0);
      }
    }
  });

  if (listenFor != null) {
    Timer(listenFor, streamSubscription.cancel);
  }

  return streamSubscription;
}
