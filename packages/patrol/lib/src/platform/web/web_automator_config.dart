void _defaultPrintLogger(String message) {
  // TODO: Use a logger instead of print
  // ignore: avoid_print
  print('Patrol (native): $message');
}

/// Configuration for [WebAutomator].
class WebAutomatorConfig {
  /// Creates a new [WebAutomatorConfig].
  const WebAutomatorConfig({void Function(String)? logger})
    : logger = logger ?? _defaultPrintLogger;

  /// Called when a web action is performed.
  final void Function(String) logger;
}
