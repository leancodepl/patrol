import 'package:patrol_axe/patrol_axe.dart';

import 'common.dart';

void main() {
  patrol('patrol_axe extension smoke', ($) async {
    await createApp($);

    const apiKey = String.fromEnvironment('DEQUE_API_KEY');
    const projectId = String.fromEnvironment('DEQUE_PROJECT_ID');
    if (apiKey.isEmpty || projectId.isEmpty) {
      $.log(
        'Skipping axe integration: set DEQUE_API_KEY and DEQUE_PROJECT_ID '
        'via --dart-define to run a full scan.',
      );
      return;
    }

    await $.axe.initSession(dequeApiKey: apiKey, dequeProjectId: projectId);
    await $.axe.scan(scanName: 'patrol-axe-smoke', uploadToDashboard: false);
  });
}
