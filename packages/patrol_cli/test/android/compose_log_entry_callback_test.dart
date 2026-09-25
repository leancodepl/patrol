import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/crossplatform/video_recording_manager.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:test/test.dart';

class _FakeVideoRecordingManager extends VideoRecordingManager {
  final List<String> started = <String>[];
  int stopped = 0;

  @override
  Future<void> startRecording(String testName) async => started.add(testName);

  @override
  Future<void> stopRecording() async => stopped++;
}

/// Lets the manager's internal operation chain settle.
Future<void> _pump() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  group('AndroidTestBackend.composeLogEntryCallback', () {
    test('is a passthrough when neither manager nor gate is given', () {
      void callback(Entry entry) {}
      expect(
        AndroidTestBackend.composeLogEntryCallback(onLogEntry: callback),
        same(callback),
      );
      expect(AndroidTestBackend.composeLogEntryCallback(), isNull);
    });

    test('a closed gate drops entries before they reach the manager', () async {
      final manager = _FakeVideoRecordingManager();
      final received = <Entry>[];
      final callback = AndroidTestBackend.composeLogEntryCallback(
        onLogEntry: received.add,
        videoRecordingManager: manager,
        acceptLogEntries: () => false,
      )!;

      // The placeholder test baked into prebuilt APKs emits these on app
      // launch; none of it may start a recording or reach the caller.
      callback(TestEntry(name: 'placeholder', status: TestEntryStatus.start));
      callback(
        ConfigEntry(config: const {ConfigEntry.developCompletedKey: true}),
      );
      await _pump();

      expect(manager.started, isEmpty);
      expect(manager.stopped, 0);
      expect(received, isEmpty);
    });

    test('an open gate lets the manager record and forwards entries', () async {
      final manager = _FakeVideoRecordingManager();
      final received = <Entry>[];
      var open = false;
      final callback = AndroidTestBackend.composeLogEntryCallback(
        onLogEntry: received.add,
        videoRecordingManager: manager,
        acceptLogEntries: () => open,
      )!;

      callback(TestEntry(name: 'placeholder', status: TestEntryStatus.start));
      open = true;
      callback(TestEntry(name: 'real test', status: TestEntryStatus.start));
      callback(
        ConfigEntry(config: const {ConfigEntry.developCompletedKey: true}),
      );
      await _pump();

      expect(manager.started, ['real test']);
      expect(manager.stopped, 1);
      expect(received, hasLength(2));
    });

    test('without a gate the manager wraps the callback directly', () async {
      final manager = _FakeVideoRecordingManager();
      final callback = AndroidTestBackend.composeLogEntryCallback(
        onLogEntry: (_) {},
        videoRecordingManager: manager,
      )!;

      callback(TestEntry(name: 'a test', status: TestEntryStatus.start));
      await _pump();

      expect(manager.started, ['a test']);
    });
  });
}
