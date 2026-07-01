// Illustrative usage. Copy this pattern into your app's patrol_test/ folder.
//
// dev_dependencies:
//   patrol_axe:
//     path: ../patrol_axe
//
// import 'package:patrol/patrol.dart';
// import 'package:patrol_axe/patrol_axe.dart';
//
// void main() {
//   patrolTest('home screen is accessible', ($) async {
//     await $.pumpWidgetAndSettle(const MyApp());
//
//     await $.axe.initSession(
//       dequeApiKey: const String.fromEnvironment('DEQUE_API_KEY'),
//       dequeProjectId: const String.fromEnvironment('DEQUE_PROJECT_ID'),
//     );
//     await $.axe.scan(scanName: 'home', tags: {'smoke'});
//   });
// }

void main() {}
