import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';

/// Waits for coverage collection on native platforms.
///
/// Posts an event with the main isolate ID, then registers a service extension
/// that external tools can call to signal that coverage has been collected.
/// Returns when that signal is received.
Future<void> waitForCoverageCollection() async {
  postEvent('waitForCoverageCollection', {
    'mainIsolateId': Service.getIsolateId(Isolate.current),
  });

  final testCompleter = Completer<void>();

  registerExtension('ext.patrol.markTestCompleted', (
    method,
    parameters,
  ) async {
    testCompleter.complete();
    return ServiceExtensionResponse.result(jsonEncode({}));
  });

  await testCompleter.future;
}
