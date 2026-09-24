class FlutterCommand {
  const FlutterCommand(this.executable, [this.arguments = const []]);

  factory FlutterCommand.parse(String command) {
    final parts = command.split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return FlutterCommand(command);
    }
    return FlutterCommand(parts[0], parts.skip(1).toList());
  }

  final String executable;
  final List<String> arguments;

  /// The `dart` command from the same SDK as this `flutter` command.
  ///
  /// Handles the shapes seen in practice: a bare `flutter`, a path to the
  /// binary, and a wrapper such as `fvm flutter`, where `flutter` is an argument
  /// rather than the executable.
  FlutterCommand toDartCommand() {
    const flutterNames = {'flutter', 'flutter.bat', 'flutter.exe'};

    String toDartName(String flutterName) => switch (flutterName) {
      'flutter.bat' => 'dart.bat',
      'flutter.exe' => 'dart.exe',
      _ => 'dart',
    };

    // `fvm flutter`, `mise exec -- flutter`, ...: swap the last `flutter` arg.
    final lastFlutterArg = arguments.lastIndexWhere(flutterNames.contains);
    if (lastFlutterArg != -1) {
      final newArguments = [...arguments];
      newArguments[lastFlutterArg] = toDartName(arguments[lastFlutterArg]);
      return FlutterCommand(executable, newArguments);
    }

    // A path (or bare name) ending in `flutter`: swap the last segment.
    final separator = executable.contains(r'\') ? r'\' : '/';
    final segments = executable.split(separator);
    final name = segments.last;
    if (flutterNames.contains(name)) {
      segments[segments.length - 1] = toDartName(name);
      return FlutterCommand(segments.join(separator), arguments);
    }

    // Unrecognizable -- fall back to whatever `dart` is on PATH.
    return const FlutterCommand('dart');
  }

  @override
  String toString() => '$executable ${arguments.join(" ")}';
}
