import 'dart:async';

import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/patrol_log_reader.dart';

/// Backstop for when no replacement run ever announces itself.
const kRestartTeardownBackstop = Duration(seconds: 3);

/// Whether `flutter run` output still belongs to the run a hot restart is
/// replacing: open from the restart request until the replacement run's
/// [isReplacementRunMarker], read from that same stream.
class RestartTeardownWindow {
  bool _open = false;
  Timer? _backstop;

  /// Whether output still belongs to the run a restart is replacing.
  bool get isOpen => _open;

  /// A hot restart was sent to `flutter run`.
  void restartRequested() {
    _backstop?.cancel();
    _backstop = null;
    _open = true;
  }

  /// `flutter run` reported the restart done; it never reopens the window.
  void restartCompleted() {
    if (!_open) {
      return;
    }
    _backstop?.cancel();
    _backstop = Timer(kRestartTeardownBackstop, close);
  }

  /// The replacement run announced itself, or the restart never happened.
  void close() {
    _backstop?.cancel();
    _backstop = null;
    _open = false;
  }

  /// Whether [line] is the config entry every `patrolTest` prints while it is
  /// declared, which only a starting run does, before any `setUpAll`.
  static bool isReplacementRunMarker(String line) {
    final match = RegExp('PATROL_LOG (.*)').firstMatch(line);
    final json = match?.group(1);
    if (json == null) {
      return false;
    }
    try {
      final entry = PatrolLogReader.parseEntry(json.replaceAll(r'\134', r'\'));
      return entry is ConfigEntry && entry.config.containsKey('printLogs');
    } on Object {
      return false;
    }
  }
}
