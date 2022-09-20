/// Throw a specialized exception for expected situations where the tool should
/// exit with a clear message to the user and no stack trace unless the
/// --verbose option is specified. For example: network errors.
Never throwToolExit(String? message, {int? exitCode}) {
  throw ToolExit(message, exitCode: exitCode);
}

/// Specialized exception for expected situations where the tool should exit
/// with a clear message to the user and no stack trace unless the --verbose
/// option is specified. For example: network errors.
class ToolExit implements Exception {
  ToolExit(this.message, {this.exitCode});

  final String? message;
  final int? exitCode;

  @override
  String toString() => 'Error: $message';
}
