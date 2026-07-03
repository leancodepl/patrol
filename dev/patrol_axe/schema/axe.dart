class AxeInitSessionRequest {
  late String dequeApiKey;
  late String dequeProjectId;
}

class AxeScanRequest {
  late bool uploadToDashboard;
  late Set<String> tags;
  String? scanName;
}

class AxeIgnoreRulesRequest {
  late List<String> rulesToIgnore;
}

class AxeIgnoreByViewIdResourceNameRequest {
  late String viewIdResourceName;
  late List<String> ruleList;
}

abstract class AxeAutomator<IOSServer, AndroidServer, DartClient> {
  void axeInitSession(AxeInitSessionRequest request);
  void axeScan(AxeScanRequest request);
  void axeIgnoreRules(AxeIgnoreRulesRequest request);
  void axeIgnoreByViewIdResourceName(
    AxeIgnoreByViewIdResourceNameRequest request,
  );
  void axeIgnoreExperimental();
}
