// The reader prints the pretty log and the summary to the console.
// ignore_for_file: avoid_print

import 'dart:async';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/patrol_log_reader.dart';

/// Runs both sides of patrol_log in a single process.
///
/// In a real test run, `patrol` uses [PatrolLogWriter] on the device to print
/// entries as `PATROL_LOG {...}` lines, and `patrol_cli` passes the device
/// output (e.g. logcat) to [PatrolLogReader], which pretty-prints the entries
/// and builds the test summary.
Future<void> main() async {
  final scope = DisposeScope();

  // Stands in for the device output that patrol_cli listens to.
  final deviceOutput = StreamController<String>.broadcast(sync: true);

  final reader =
      PatrolLogReader(
          scope: scope,
          listenStdOut: deviceOutput.stream.listen,
          log: print,
          reportPath: 'build/reports/index.html',
          showFlutterLogs: false,
          hideTestSteps: false,
          clearTestSteps: false,
        )
        ..listen()
        ..startTimer();

  // PatrolLogWriter prints its entries, so send its prints to the device
  // output instead of the console.
  final writer =
      runZoned(
          PatrolLogWriter.new,
          zoneSpecification: ZoneSpecification(
            print: (_, _, _, line) => deviceOutput.add(line),
          ),
        )
        ..log(TestEntry(name: 'signs in', status: TestEntryStatus.start))
        ..log(
          StepEntry(action: 'enterText "Email"', status: StepEntryStatus.start),
        )
        ..log(
          StepEntry(
            action: 'enterText "Email"',
            status: StepEntryStatus.success,
          ),
        )
        ..log(LogEntry(message: 'Signing in as user@example.com'))
        ..log(TestEntry(name: 'signs in', status: TestEntryStatus.success))
        ..log(
          TestEntry(
            name: 'rejects a wrong password',
            status: TestEntryStatus.start,
          ),
        )
        ..log(StepEntry(action: 'tap "Sign in"', status: StepEntryStatus.start))
        ..log(
          StepEntry(action: 'tap "Sign in"', status: StepEntryStatus.failure),
        )
        ..log(
          TestEntry(
            name: 'rejects a wrong password',
            status: TestEntryStatus.failure,
            error: 'Expected to find "Wrong password", found 0 widgets.',
          ),
        )
        ..log(TestEntry(name: 'signs out', status: TestEntryStatus.skip));

  // Entries are delivered asynchronously, so let them reach the reader.
  await Future<void>.delayed(Duration.zero);

  reader.stopTimer();
  print(reader.summary);

  writer.close();
  reader.close();
  await deviceOutput.close();
  await scope.dispose();
}
