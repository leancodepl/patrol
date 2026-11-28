import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'common.dart';

Future<File> _pidFile() async {
  final directory = await getApplicationSupportDirectory();
  return File('${directory.path}/patrol_restart_app_test.pid');
}

void main() {
  patrol(
    'restarts the app between phases',
    phases([
      PatrolPhase(($) async {
        await createApp($);
        await (await _pidFile()).writeAsString('$pid', flush: true);
      }),
      PatrolPhase(($) async {
        await createApp($);
        final file = await _pidFile();
        final previousPid = int.parse(await file.readAsString());

        expect(pid, isNot(previousPid));
        await file.delete();
      }),
      PatrolPhase(
        ($) async {
          await createApp($);
          expect($('Applink Screen'), findsOneWidget);
          expect($('Uri: patrol://check/somepath?query=10'), findsOneWidget);
        },
        launch: PatrolAppLaunch.deepLink('patrol://check/somepath?query=10'),
      ),
    ]),
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );
}
