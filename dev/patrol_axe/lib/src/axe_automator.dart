import 'package:http/http.dart' as http;
import 'package:patrol/patrol.dart';

import 'contracts/axe_automator_client.dart';

class AxeAutomator {
  AxeAutomator(this._$)
    : _client = AxeAutomatorClient(http.Client(), patrolNativeServerUri);

  final PatrolIntegrationTester _$;
  final AxeAutomatorClient _client;

  /// Initializes an axe DevTools accessibility testing session.
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

  /// Runs an axe DevTools accessibility scan of the currently visible UI.
  Future<void> scan({
    bool uploadToDashboard = true,
    Set<String> tags = const {},
    String? scanName,
  }) async {
    _$.log('axe: scan (tags: $tags, scanName: $scanName)');
    await _client.axeScan(
      uploadToDashboard: uploadToDashboard,
      tags: tags,
      scanName: scanName,
    );
  }

  /// Configures the scanner to ignore the given accessibility rules.
  Future<void> ignoreRules(List<String> rulesToIgnore) async {
    _$.log('axe: ignoreRules ($rulesToIgnore)');
    await _client.axeIgnoreRules(rulesToIgnore: rulesToIgnore);
  }

  /// Ignores [ruleList] for the view identified by [viewIdResourceName].
  Future<void> ignoreByViewIdResourceName(
    String viewIdResourceName,
    List<String> ruleList,
  ) async {
    _$.log('axe: ignoreByViewIdResourceName ($viewIdResourceName)');
    await _client.axeIgnoreByViewIdResourceName(
      viewIdResourceName: viewIdResourceName,
      ruleList: ruleList,
    );
  }

  /// Configures the scanner to ignore experimental accessibility rules.
  Future<void> ignoreExperimental() async {
    _$.log('axe: ignoreExperimental');
    await _client.axeIgnoreExperimental();
  }
}
