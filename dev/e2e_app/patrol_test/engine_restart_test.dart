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

void main() {
  patrol(
    'continues in the app that restarted its Flutter engine',
    phases([
      PatrolPhase(($) async {
        await createApp($);
        await (await _stateFile()).writeAsString(
          '$pid $_engineToken',
          flush: true,
        );

        if (Platform.isAndroid) {
          // RecreateActivity starts MainActivity in a cleared task. The
          // activity and its engine are destroyed, so this phase ends here.
          await $.platform.mobile.openUrl('patrol-recreate://app');
        }
      }),
      PatrolPhase(($) async {
        await createApp($);
        final file = await _stateFile();
        final state = (await file.readAsString()).split(' ').map(int.parse);
        await file.delete();

        expect(pid, state.first, reason: 'the process must not be killed');
        expect(
          _engineToken,
          Platform.isAndroid ? isNot(state.last) : state.last,
        );
      }, launch: const PatrolAppLaunch.attach()),
    ]),
  );
}
