import 'package:http/http.dart' as http;
import 'package:patrol/patrol.dart';

import 'contracts/axe_automator_client.dart';

class AxeAutomator {
  AxeAutomator(this._$)
    : _client = AxeAutomatorClient(http.Client(), patrolNativeServerUri);

  final PatrolIntegrationTester _$;
  final AxeAutomatorClient _client;

  /// Verifies the native extension is mounted and responding.
  Future<AxePingResult> ping() async {
    _$.log('axe: ping');
    return _client.ping();
  }

  Future<void> initSession({
    required String dequeApiKey,
    required String dequeProjectId,
  }) async {
    _$.log('axe: initSession');
    await _client.axeInitSession(
      dequeApiKey: dequeApiKey,
      dequeProjectId: dequeProjectId,
    );
  }

  /// Runs a native scan stub and returns the native proof payload.
  Future<AxePingResult> scan({
    bool uploadToDashboard = true,
    Set<String> tags = const {},
    String? scanName,
  }) async {
    _$.log('axe: scan (tags: $tags, scanName: $scanName)');
    return _client.axeScan(
      uploadToDashboard: uploadToDashboard,
      tags: tags,
      scanName: scanName,
    );
  }
}
