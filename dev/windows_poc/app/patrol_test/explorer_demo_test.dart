import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:windows_poc/main.dart';

/// Opens File Explorer to a temp folder via [WindowsAutomator.launchApp],
/// activates the window, and taps a known file with UI Automation.
void main() {
  patrolTest('launchApp opens Explorer and taps a file', ($) async {
    await $.pumpWidgetAndSettle(const WindowsPocApp());

    final folder = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}PatrolExplorerDemo',
    );
    if (folder.existsSync()) {
      folder.deleteSync(recursive: true);
    }
    folder.createSync();
    addTearDown(() {
      if (folder.existsSync()) {
        folder.deleteSync(recursive: true);
      }
    });

    const fileName = 'patrol_explorer_target.txt';
    final file = File(
      '${folder.path}${Platform.pathSeparator}$fileName',
    );
    file.writeAsStringSync('hello from patrol windows explorer demo');

    // launchApp: start Explorer at our folder (no fixture EXE needed).
    await $.platform.windows.launchApp(
      appPath: 'explorer.exe',
      arguments: '"${folder.path}"',
      activate: false,
    );

    // Explorer reuses the shell — activate by window title (folder name).
    await $.platform.windows.activateApp(windowName: 'PatrolExplorerDemo');

    await $.platform.windows.waitUntilVisible(name: fileName);
    expect(
      await $.platform.windows.isElementVisible(name: fileName),
      isTrue,
    );

    final item = await $.platform.windows.findElement(name: fileName);
    expect(item, isNotNull);
    expect(item!.name, fileName);

    // Select the file in Explorer (outside Flutter).
    await $.platform.windows.tap(name: fileName);
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Bring Explorer forward again to prove activateApp after interaction.
    await $.platform.windows.activateApp(windowName: 'PatrolExplorerDemo');
    expect(
      await $.platform.windows.isElementVisible(name: fileName),
      isTrue,
    );
  });
}
