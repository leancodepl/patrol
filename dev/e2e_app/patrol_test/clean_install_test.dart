import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'common.dart';

Future<File> _markerFile() async {
  final directory = await getApplicationSupportDirectory();
  return File('${directory.path}/patrol_clean_install_test.marker');
}

void main() {
  patrol(
    'reinstalls the app between phases',
    phases([
      PatrolPhase(($) async {
        await createApp($);
        final file = await _markerFile();
        await file.create(recursive: true);
        await file.writeAsString('before reinstall', flush: true);
      }),
      PatrolPhase(($) async {
        await createApp($);
        expect((await _markerFile()).existsSync(), isFalse);
      }, launch: const PatrolAppLaunch.cleanInstall()),
    ]),
  );
}
