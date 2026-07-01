class AxeInitSessionRequest {
  late String dequeApiKey;
  late String dequeProjectId;
}

class AxeScanRequest {
  late bool uploadToDashboard;
  late Set<String> tags;
  String? scanName;
}

abstract class AxeAutomator<IOSServer, AndroidServer, DartClient> {
  void axeInitSession(AxeInitSessionRequest request);
  void axeScan(AxeScanRequest request);
}
