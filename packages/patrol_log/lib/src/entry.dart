abstract class Entry {
  Entry({required this.timestamp, required this.type});

  // ignore: avoid_unused_constructor_parameters
  factory Entry.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson is not implemented');
  }

  final DateTime timestamp;
  final EntryType type;

  Map<String, dynamic> toJson();

  String pretty();

  @override
  String toString() => throw UnimplementedError('toString is not implemented');
}

enum EntryType {
  step,
  test,
  log;
}

/// The number of spaces used for indentation in the pretty print.
/// Used in LogEntry and StepEntry.
const indentation = '        ';
