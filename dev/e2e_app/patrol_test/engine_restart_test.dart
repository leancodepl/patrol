import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

import 'common.dart';

/// Differs between Flutter engines, because every engine starts a new isolate.
final _engineToken = Random().nextInt(1 << 32);

Future<File> _stateFile() async {
  final directory = await getApplicationSupportDirectory();
  return File('${directory.path}/patrol_engine_restart_test.state');
}

/// Phases that open [url] in the running app and continue after the app
/// restarts its Flutter engine.
PatrolPhaseCallback _restartPhases(String url) {
  return phases([
    PatrolPhase(($) async {
      await createApp($);
      await (await _stateFile()).writeAsString(
        '$pid $_engineToken',
        flush: true,
      );

      if (Platform.isAndroid) {
        // RecreateActivity starts MainActivity in a cleared task. The activity
        // and its engine are destroyed, so this phase ends here.
        await $.platform.mobile.openUrl(url);
      }
    }),
    PatrolPhase(($) async {
      final file = await _stateFile();
      final state = (await file.readAsString()).split(' ').map(int.parse);
      if (Platform.isAndroid && _engineToken == state.last) {
        // The restart has not happened yet, and this engine is about to be
        // destroyed. A real test would wait here for the screen that the
        // link opens.
        await Future<void>.delayed(const Duration(seconds: 30));
      }

      await createApp($);
      await file.delete();

      expect(pid, state.first, reason: 'the process must not be killed');
      expect(_engineToken, Platform.isAndroid ? isNot(state.last) : state.last);
    }, launch: const PatrolAppLaunch.attach()),
  ]);
}

void main() {
  patrol(
    'continues in the app that restarted its Flutter engine',
    _restartPhases('patrol-recreate://app'),
  );

  patrol(
    'continues in the app that restarted its Flutter engine late',
    _restartPhases('patrol-recreate://slow'),
  );
}
