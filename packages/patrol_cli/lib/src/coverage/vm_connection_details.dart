class VMConnectionDetails {
  const VMConnectionDetails({
    required this.port,
    required this.auth,
  });

  final int port;
  final String auth;

  Uri get uri => Uri.parse('http://127.0.0.1:$port/$auth');
  Uri get webSocketUri {
    final pathSegments = uri.pathSegments.where((c) => c.isNotEmpty).toList()
      ..add('ws');
    return uri.replace(scheme: 'ws', pathSegments: pathSegments);
  }

  static VMConnectionDetails? tryExtractFromLogs(String logsLine) {
    final vmLink =
        RegExp('listening on (http.+)').firstMatch(logsLine)?.group(1);

    if (vmLink == null) {
      return null;
    }

    final uri = Uri.parse(vmLink);

    return VMConnectionDetails(
      port: uri.port,
      auth: uri.pathSegments.lastWhere((segment) => segment.isNotEmpty),
    );
  }
}
