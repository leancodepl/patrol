import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/src/custom_finders/custom_finders.dart';
import 'package:patrol_log/patrol_log.dart';

class _CapturingLogWriter extends PatrolLogWriter {
  final steps = <StepEntry>[];

  @override
  void log(Entry entry) {
    if (entry is StepEntry) {
      steps.add(entry);
    }
  }
}

void main() {
  group('action description', () {
    patrolWidgetTest(
      'wraps failure with PatrolStepException including description',
      config: const PatrolTesterConfig(
        visibleTimeout: Duration(milliseconds: 100),
      ),
      ($) async {
        await $.pumpWidget(const MaterialApp(home: SizedBox()));

        await expectLater(
          () => $(
            'Missing',
          ).tap(description: 'Clicking payment button to submit'),
          throwsA(
            isA<PatrolStepException>()
                .having(
                  (e) => e.description,
                  'description',
                  'Clicking payment button to submit',
                )
                .having(
                  (e) => e.cause,
                  'cause',
                  isA<WaitUntilVisibleTimeoutException>(),
                )
                .having(
                  (e) => e.toString(),
                  'toString',
                  contains('failed on: Clicking payment button to submit'),
                ),
          ),
        );
      },
    );

    patrolWidgetTest(
      'still throws original timeout when description is omitted',
      config: const PatrolTesterConfig(
        visibleTimeout: Duration(milliseconds: 100),
      ),
      ($) async {
        await $.pumpWidget(const MaterialApp(home: SizedBox()));

        await expectLater(
          () => $('Missing').tap(),
          throwsA(isA<WaitUntilVisibleTimeoutException>()),
        );
      },
    );

    testWidgets('overrides patrol log step text with description', (
      widgetTester,
    ) async {
      final logWriter = _CapturingLogWriter();
      final $ = PatrolTester(
        tester: widgetTester,
        config: const PatrolTesterConfig(printLogs: true),
        patrolLog: logWriter,
      );

      var count = 0;
      await $.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return GestureDetector(
                onTap: () => setState(() => count++),
                child: Text('Tap me, count: $count'),
              );
            },
          ),
        ),
      );

      await $(
        'Tap me, count: 0',
      ).tap(description: 'Clicking payment button to submit');

      expect(find.text('Tap me, count: 1'), findsOneWidget);

      expect(logWriter.steps, isNotEmpty);
      expect(
        logWriter.steps.every(
          (step) => step.action == 'Clicking payment button to submit',
        ),
        isTrue,
      );
      expect(
        logWriter.steps.any((step) => step.action.contains('widgets with')),
        isFalse,
      );
      expect(
        logWriter.steps.map((step) => step.status),
        containsAll([StepEntryStatus.start, StepEntryStatus.success]),
      );
    });

    patrolWidgetTest('works with enterText description on success', ($) async {
      await $.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              key: Key('email'),
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ),
        ),
      );

      await $(
        #email,
      ).enterText('user@example.com', description: 'Entering email address');

      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets('logs failure status with description on failed tap', (
      widgetTester,
    ) async {
      final logWriter = _CapturingLogWriter();
      final $ = PatrolTester(
        tester: widgetTester,
        config: const PatrolTesterConfig(
          printLogs: true,
          visibleTimeout: Duration(milliseconds: 100),
        ),
        patrolLog: logWriter,
      );

      await $.pumpWidget(const MaterialApp(home: SizedBox()));

      await expectLater(
        () =>
            $('Missing').tap(description: 'Clicking payment button to submit'),
        throwsA(isA<PatrolStepException>()),
      );

      expect(
        logWriter.steps.map((step) => step.action).toSet(),
        equals({'Clicking payment button to submit'}),
      );
      expect(
        logWriter.steps.map((step) => step.status),
        containsAll([StepEntryStatus.start, StepEntryStatus.failure]),
      );
    });
  });
}
