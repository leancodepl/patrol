class VMConnectionDetails {
  const VMConnectionDetails({
    required this.port,
    required this.auth,
  });

  final String port;
  final String auth;

  Uri get uri => Uri.parse('http://127.0.0.1:$port/$auth');
  Uri get webSocketUri {
    final pathSegments = uri.pathSegments.where((c) => c.isNotEmpty).toList()
      ..add('ws');
    return uri.replace(scheme: 'ws', pathSegments: pathSegments);
  }

  static VMConnectionDetails? tryExtractFromLogs(String logsLine) {
    final vmLink = RegExp('listening on (http.+)').firstMatch(logsLine)?.group(1);

    if (vmLink == null) {
      return null;
    }

    final port = RegExp(':([0-9]+)/').firstMatch(vmLink)?.group(1);
    final auth = RegExp(':$port/(.+)').firstMatch(vmLink)?.group(1);

    if (port == null || auth == null) {
      throw Exception('Failed to extract VM connection details');
    }

    return VMConnectionDetails(port: port, auth: auth);
  }
}
