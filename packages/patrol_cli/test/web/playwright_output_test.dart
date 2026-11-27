import 'package:patrol_cli/src/web/playwright_output.dart';
import 'package:test/test.dart';

void main() {
  group('PlaywrightOutput', () {
    test('keeps an error printed by global setup to stdout', () {
      const lines = [
        'Error: browserType.launch: Unsupported chromium channel "bogus"',
        '',
        '   at tests/setup.ts:8',
        '',
        '\x1B[1A\x1B[2K',
        'To open last HTML report run:',
        '',
        '  npx playwright show-report playwright-report',
      ];
      final output = PlaywrightOutput();
      lines.forEach(output.addStdout);

      expect(output.lines, [
        'Error: browserType.launch: Unsupported chromium channel "bogus"',
        '   at tests/setup.ts:8',
      ]);
    });

    test('keeps stderr lines, without ANSI codes', () {
      final output = PlaywrightOutput()
        ..addStderr(
          '\x1B[31mError: PATROL_WEB_VIEWPORT must be a valid JSON\x1B[39m',
        )
        ..addStderr('    at envJson (playwright.config.ts:137:13)');

      expect(output.lines, [
        'Error: PATROL_WEB_VIEWPORT must be a valid JSON',
        '    at envJson (playwright.config.ts:137:13)',
      ]);
    });

    test('leaves out lines that come from the app', () {
      final output = PlaywrightOutput();

      expect(
        output.addStdout('PATROL_LOG {"type":"test","status":"start"}'),
        isFalse,
      );
      expect(output.addStdout('Playwright: some console message'), isFalse);
      expect(
        output.addStdout('\x1B[2KPlaywright: after a cursor movement'),
        isFalse,
      );
      expect(output.addStdout('  1 failed'), isTrue);
      expect(output.lines, ['  1 failed']);
    });

    test('keeps only the last maxLines lines, in order', () {
      final output = PlaywrightOutput(maxLines: 3);
      for (var i = 1; i <= 5; i++) {
        output.addStderr('line $i');
      }

      expect(output.lines, ['line 3', 'line 4', 'line 5']);
    });
  });
}
