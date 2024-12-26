import 'dart:async';
import 'dart:convert';

import 'package:patrol_log/patrol_log.dart';

class PatrolLogWriter {
  PatrolLogWriter({Map<String, dynamic> config = const {}})
      : _controller = StreamController<Entry>.broadcast() {
    write();

    /// Pass config to the PatrolLogReader
    if (config.isNotEmpty) {
      log(ConfigEntry(config: config));
    }
  }

  final StreamController<Entry> _controller;
  late final StreamSubscription<Entry> _streamSubscription;

  /// Logs an [entry] to the stream.
  void log(Entry entry) {
    _controller.add(entry);
  }

  /// Writes the entries to the console.
  void write() {
    _streamSubscription = _controller.stream.listen((entry) {
      // Print to standard output, so it can be read by the CLI.
      // ignore: avoid_print
      print('PATROL_LOG ${jsonEncode(entry.toJson())}');
    });
  }

  void close() {
    _streamSubscription.cancel();
    _controller.close();
  }
}
