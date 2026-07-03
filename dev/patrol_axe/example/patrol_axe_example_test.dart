// Example — requires DEQUE_API_KEY and DEQUE_PROJECT_ID via --dart-define.
//
//   patrol test --target patrol_test/patrol_axe_native_test.dart \
//     --dart-define=DEQUE_API_KEY=... --dart-define=DEQUE_PROJECT_ID=...

import 'package:patrol/patrol.dart';
import 'package:patrol_axe/patrol_axe.dart';

void main() {
  patrol('axe scan example', ($) async {
    await $.axe.initSession(
      dequeApiKey: const String.fromEnvironment('DEQUE_API_KEY'),
      dequeProjectId: const String.fromEnvironment('DEQUE_PROJECT_ID'),
    );
    await $.axe.scan(scanName: 'example-scan');
  });
}
