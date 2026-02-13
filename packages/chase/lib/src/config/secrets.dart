import 'dart:io';

/// Resolves secret values from environment variables or direct values.
class SecretResolver {
  const SecretResolver();

  static final _envVarPattern = RegExp(r'^\$\{(\w+)\}$');

  /// Resolves a value that may be an environment variable reference.
  ///
  /// If [value] matches `${VAR_NAME}`, returns the environment variable.
  /// Otherwise returns the value as-is.
  String resolve(String value) {
    final match = _envVarPattern.firstMatch(value);
    if (match != null) {
      final envName = match.group(1)!;
      return Platform.environment[envName] ?? '';
    }
    return value;
  }
}
