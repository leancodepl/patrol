class FlutterCommand {
  const FlutterCommand(this.executable, [this.arguments = const []]);

  factory FlutterCommand.parse(String command) {
    final parts = command.split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return FlutterCommand(command);
    }
    return FlutterCommand(parts[0], parts.skip(1).toList());
  }

  factory FlutterCommand.fromJson(Map<String, dynamic> json) {
    return FlutterCommand(
      json['executable'] as String,
      (json['arguments'] as List<dynamic>?)?.cast<String>() ?? <String>[],
    );
  }

  final String executable;
  final List<String> arguments;

  Map<String, dynamic> toJson() {
    return {
      'executable': executable,
      'arguments': arguments,
    };
  }

  @override
  String toString() => '$executable ${arguments.join(" ")}';
}
