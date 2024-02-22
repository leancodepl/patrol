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

  @override
  String toString() => '$executable ${arguments.join(" ")}';
}
