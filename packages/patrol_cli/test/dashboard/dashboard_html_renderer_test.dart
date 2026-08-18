import 'package:patrol_cli/src/dashboard/dashboard_html_renderer.dart';
import 'package:patrol_cli/src/dashboard/dashboard_report.dart';
import 'package:test/test.dart';

void main() {
  const renderer = DashboardHtmlRenderer();

  DashboardTest testCase({
    String name = 'signs in',
    String? filePath = 'integration_test/app_test.dart',
    DashboardTestStatus status = DashboardTestStatus.passed,
    Duration? duration = const Duration(seconds: 3),
    String? error,
    String? videoPath,
    List<DashboardStep> steps = const [],
  }) {
    final test =
        DashboardTest(
            name: name,
            filePath: filePath,
            startedAt: DateTime(2026, 8, 17, 12),
            status: status,
          )
          ..duration = duration
          ..error = error
          ..videoPath = videoPath;
    test.steps.addAll(steps);
    return test;
  }

  DashboardRun run(List<DashboardTest> tests) => DashboardRun(
    tests: tests,
    platform: 'iOS',
    deviceName: 'iPhone 17',
    deviceId: 'ABCD-1234',
    buildMode: 'debug',
    startedAt: DateTime(2026, 8, 17, 12),
    duration: const Duration(minutes: 1, seconds: 5),
    cliVersion: '4.7.0',
    appDescription: 'app with entrypoint test_bundle.dart',
  );

  group('DashboardHtmlRenderer', () {
    test('renders a self-contained page with inlined styles and script', () {
      final html = renderer.render(
        run([testCase()]),
        reportPath: '/project/integration_test/reports/patrol_report.html',
      );

      expect(html, startsWith('<!DOCTYPE html>'));
      expect(html, contains('<style>'));
      expect(html, contains('<script>'));
      // Nothing may be fetched from the network.
      expect(html, isNot(contains('src="http')));
      expect(html, isNot(contains('<link rel="stylesheet"')));
    });

    test('shows the verdict, the counters and the device', () {
      final html = renderer.render(
        run([
          testCase(),
          testCase(name: 'signs out', status: DashboardTestStatus.failed),
          testCase(name: 'is skipped', status: DashboardTestStatus.skipped),
        ]),
        reportPath: '/project/report.html',
      );

      expect(html, contains('1 of 3 tests failed'));
      expect(html, contains('iPhone 17'));
      expect(html, contains('data-status="failed"'));
      expect(html, contains('data-status="skipped"'));
      // One executed test out of two passed.
      expect(html, contains('50%'));
    });

    test('expands failing tests and collapses passing ones', () {
      final html = renderer.render(
        run([
          testCase(status: DashboardTestStatus.failed, error: 'boom'),
          testCase(
            name: 'passes',
            steps: [
              DashboardStep(action: 'Tap', startedAt: DateTime(2026, 8, 17))
                ..status = DashboardStepStatus.passed
                ..duration = const Duration(milliseconds: 400),
            ],
          ),
        ]),
        reportPath: '/project/report.html',
      );

      final failed = html.indexOf('data-status="failed"');
      final passed = html.indexOf('data-status="passed"');
      expect(
        html.substring(failed - 60, failed),
        contains('status-failed is-open'),
      );
      expect(html.substring(passed - 60, passed), isNot(contains('is-open')));
    });

    test('renders steps with their durations and nested logs', () {
      final step =
          DashboardStep(
              action: 'Tap on "Sign in"',
              startedAt: DateTime(2026, 8, 17),
            )
            ..status = DashboardStepStatus.passed
            ..duration = const Duration(milliseconds: 640);
      step.logs.add('waiting for the app');

      final html = renderer.render(
        run([
          testCase(steps: [step]),
        ]),
        reportPath: '/project/report.html',
      );

      expect(html, contains('Tap on &quot;Sign in&quot;'));
      expect(html, contains('640ms'));
      expect(html, contains('waiting for the app'));
    });

    test('folds the exception and nests it under the failing step', () {
      final failing =
          DashboardStep(
              action: 'Wait until "Home" is visible',
              startedAt: DateTime(2026, 8, 17),
            )
            ..status = DashboardStepStatus.failed
            ..duration = const Duration(seconds: 5);

      final html = renderer.render(
        run([
          testCase(
            status: DashboardTestStatus.failed,
            steps: [failing],
            error:
                'Expected: exactly one matching candidate\n'
                '  Actual: none\n'
                '\n'
                'When the exception was thrown, this was the stack:\n'
                '#0      fail (expect.dart:149:31)\n'
                '#1      _expect (expect.dart:144:3)',
          ),
        ]),
        reportPath: '/project/report.html',
      );

      // Folded, with only a one-line summary showing.
      expect(html, contains('aria-expanded="false"'));
      expect(
        html,
        contains(
          '<span class="exception-summary">Expected: exactly one matching '
          'candidate</span>',
        ),
      );
      // Frames are split off the message and counted.
      expect(html, contains('Stack trace · 2 frames'));
      expect(html, contains('class="exception-frames"'));
      // The panel sits inside the failing step's list item.
      final step = html.indexOf('step step-failed');
      final exception = html.indexOf('class="exception"');
      final stepEnd = html.indexOf('</li>', step);
      expect(exception, greaterThan(step));
      expect(exception, lessThan(stepEnd));
    });

    test('places the exception above the steps when no step failed', () {
      final html = renderer.render(
        run([
          testCase(
            status: DashboardTestStatus.failed,
            error: 'Expected: true',
            steps: [
              DashboardStep(action: 'Tap', startedAt: DateTime(2026, 8, 17))
                ..status = DashboardStepStatus.passed
                ..duration = const Duration(milliseconds: 100),
            ],
          ),
        ]),
        reportPath: '/project/report.html',
      );

      expect(
        html.indexOf('class="exception"'),
        lessThan(html.indexOf('<ol class="steps">')),
      );
    });

    test('joins run-level error lines into one block', () {
      final html = renderer.render(
        DashboardRun(
          tests: const [],
          platform: 'Android',
          deviceName: 'Pixel 9',
          deviceId: 'emulator-5554',
          buildMode: 'debug',
          startedAt: DateTime(2026, 8, 17),
          duration: Duration.zero,
          cliVersion: '4.7.0',
          errors: const ['first line', 'second line'],
        ),
        reportPath: '/project/report.html',
      );

      expect('class="notice notice-error"'.allMatches(html), hasLength(1));
      expect(html, contains('first line\nsecond line'));
    });

    test('escapes HTML and strips terminal colors from exceptions', () {
      final html = renderer.render(
        run([
          testCase(
            name: '<script>alert(1)</script>',
            status: DashboardTestStatus.failed,
            error: '\x1B[31mExpected: <Widget>\x1B[0m',
          ),
        ]),
        reportPath: '/project/report.html',
      );

      expect(html, isNot(contains('<script>alert(1)</script>')));
      expect(html, contains('&lt;script&gt;alert(1)&lt;/script&gt;'));
      expect(html, contains('Expected: &lt;Widget&gt;'));
      expect(html, isNot(contains('\x1B[31m')));
    });

    test('links a video relative to the report file', () {
      final html = renderer.render(
        run([
          testCase(videoPath: '/project/integration_test/videos/signs in.mp4'),
        ]),
        reportPath: '/project/integration_test/reports/patrol_report.html',
      );

      expect(html, contains('<video controls'));
      expect(html, contains('src="../videos/signs%20in.mp4"'));
    });

    test('links a video kept outside the report tree relatively too', () {
      final html = renderer.render(
        run([testCase(videoPath: '/elsewhere/videos/signs_in.mp4')]),
        reportPath: '/project/reports/patrol_report.html',
      );

      expect(html, contains('src="../../elsewhere/videos/signs_in.mp4"'));
    });

    test('renders a message when the run reported no tests', () {
      final html = renderer.render(run([]), reportPath: '/project/report.html');

      expect(html, contains('This run reported no tests'));
    });
  });

  group('DashboardHtmlRenderer.formatDuration()', () {
    test('formats sub-second, second and minute durations', () {
      expect(
        DashboardHtmlRenderer.formatDuration(const Duration(milliseconds: 640)),
        '640ms',
      );
      expect(
        DashboardHtmlRenderer.formatDuration(
          const Duration(milliseconds: 4200),
        ),
        '4.20s',
      );
      expect(
        DashboardHtmlRenderer.formatDuration(
          const Duration(seconds: 12, milliseconds: 340),
        ),
        '12.3s',
      );
      expect(
        DashboardHtmlRenderer.formatDuration(
          const Duration(minutes: 2, seconds: 7),
        ),
        '2m 07s',
      );
    });
  });
}
