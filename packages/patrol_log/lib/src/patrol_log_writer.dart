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
    try {
      // Validate entry before adding to stream
      // ignore: unnecessary_null_comparison
      if (entry == null) {
        print('Error: Null entry cannot be logged');
        return;
      }

      // Convert to JSON safely
      Map<String, dynamic> jsonEntry;
      try {
        jsonEntry = entry.toJson();
      } catch (e) {
        print('Error converting entry to JSON: $e');
        return;
      }

      // Add to stream with null check on controller
      // ignore: unnecessary_null_comparison
      if (_controller != null && !_controller.isClosed && jsonEntry != null) {
        _controller.add(Entry.fromJson(jsonEntry));
      } else {
        print('Error: Stream controller is unavailable');
      }
    } catch (e) {
      print('Unexpected error in log method: $e');
    }
  }

  /// Writes the entries to the console.
  void write() {
    _streamSubscription = _controller.stream.listen(
      (entry) {
        // Print to standard output, so it can be read by the CLI.
        // ignore: avoid_print
        try {
          final jsonEntry = entry.toJson();
          final encodedEntry = jsonEncode(jsonEntry);

          print('PATROL_LOG $encodedEntry');
        } on FormatException catch (e) {
          
        } catch (e) {
          
        }
      },
      onError: (onError) {
        print('Stream Error: $onError');
      },
      cancelOnError: false,
    );
  }

  void close() {
    _streamSubscription.cancel();
    _controller.close();
  }
}
