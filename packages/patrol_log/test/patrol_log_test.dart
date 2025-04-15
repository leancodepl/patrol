import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_log/src/patrol_log_reader.dart';
import 'package:test/test.dart';

void main() {
  group('PatrolLogReader', () {
    test('formatDuration formats duration correctly', () {
      final reader = PatrolLogReader(
        scope: DisposeScope(),
        listenStdOut: (_, {onError, onDone, cancelOnError}) =>
            const Stream<void>.empty().listen((_) {}),
        log: (_) {},
        reportPath: '',
        showFlutterLogs: false,
        hideTestSteps: false,
        clearTestSteps: false,
      );

      expect(reader.formatDuration(const Duration(seconds: 5)), '5s');
      expect(
        reader.formatDuration(const Duration(minutes: 1, seconds: 5)),
        '1m 5s',
      );
      expect(
        reader.formatDuration(const Duration(hours: 1, minutes: 1, seconds: 5)),
        '1h 1m 5s',
      );
      expect(
        reader.formatDuration(const Duration(hours: 2)),
        '2h 0m 0s',
      );
      expect(
        reader.formatDuration(Duration.zero),
        '0s',
      );
      expect(
        reader.formatDuration(const Duration(seconds: 60)),
        '1m 0s',
      );
    });
  });
}
