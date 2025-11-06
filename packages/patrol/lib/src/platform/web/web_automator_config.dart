void _defaultPrintLogger(String message) {
  // TODO: Use a logger instead of print
  // ignore: avoid_print
  print('Patrol (native): $message');
}

class WebAutomatorConfig {
  const WebAutomatorConfig({void Function(String)? logger})
    : logger = logger ?? _defaultPrintLogger;

  final void Function(String) logger;
}
