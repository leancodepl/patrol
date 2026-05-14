import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol/patrol.dart';

import 'remote_app.dart';
import 'remote_app_tester.dart';
import 'remote_apps_lookup.dart';

/// Patrol test variant for driving a cross-origin Flutter Web app from a
/// controller window.
///
/// Opens [origin] in a new tab via `window.open`, awaits the remote app's
/// `patrol_ready` broadcast, then runs [callback] with a [RemoteAppTester]
/// as `$`. The `$` here is **not** the regular `PatrolIntegrationTester` —
/// it produces [RemotePatrolFinder]s whose actions execute remotely.
///
/// [startsIn] is the name of a remote app declared in `patrol.remote.apps`
/// in the controller's pubspec.yaml. The orchestrator wires that name to a
/// concrete origin URL via `--dart-define=PATROL_REMOTE_APPS=<json>`.
///
/// Example:
///
/// ```dart
/// patrolRemoteTest(
///   'panel_auth_canvas_roundtrip',
///   startsIn: 'panel',
///   callback: ($) async {
///     await $(#go_login).tap();
///     await $.waitForApp('auth');
///     await $(#email).enterText('foo@bar.com');
///     await $(#sign_in).tap();
///     await $.waitForApp('panel');
///     expect(await $('Welcome').count, 1);
///   },
/// );
/// ```
@isTest
void patrolRemoteTest(
  String description, {
  required String startsIn,
  required Future<void> Function(RemoteAppTester $) callback,
  bool? skip,
  Timeout? timeout,
  dynamic tags,
}) {
  patrolTest(
    description,
    ($) async {
      final app = await RemoteApp.open(RemoteApps.origin(startsIn));
      final tester = RemoteAppTester(app);
      try {
        await callback(tester);
      } finally {
        app.close();
      }
    },
    skip: skip,
    timeout: timeout,
    tags: tags,
  );
}
