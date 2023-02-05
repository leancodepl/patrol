const exitCodeInterrupted = 130;

/// Throw a specialized exception for expected situations where the tool should
/// exit with a clear message to the user and no stack trace unless the
/// --verbose option is specified. For example: network errors.
Never throwToolExit(String message, {int? exitCode}) {
  throw ToolExit(message, exitCode: exitCode);
}

/// Throw a specialized exception for when the tool is interrupted by the user.
///
/// Details should document what exactly was interrupted. They shouldn't be
/// shown unless --verbose is specified.
Never throwToolInterrupted(String details) {
  throw ToolInterrupted(details);
}

/// Specialized exception for expected situations where the tool should exit
/// with a clear message to the user and no stack trace unless the --verbose
/// option is specified. For example: network errors.
class ToolExit implements Exception {
  const ToolExit(this.message, {int? exitCode}) : exitCode = exitCode ?? 1;

  final String message;
  final int exitCode;

  @override
  String toString() => 'Error: $message';
}

/// Sspecialized exception for when the tool is interrupted by the user.
///
/// Details should document what exactly was interrupted. They shouldn't be
/// shown unless --verbose is specified.
class ToolInterrupted implements Exception {
  const ToolInterrupted(this.details);

  final String message = 'Interrupted';
  final String details;
  final exitCode = exitCodeInterrupted;

  @override
  String toString() => '$message: $details';
}
