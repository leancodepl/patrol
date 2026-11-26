import 'dart:collection';

/// Keeps the last lines of Playwright's own output, so Patrol can show why
/// Playwright failed when no test reported a result (e.g. an error in global
/// setup or in `playwright.config.ts`).
///
/// Lines that come from the app under test (`PATROL_LOG` entries and browser
/// console messages prefixed with `Playwright:`) are left out. The second and
/// later lines of a multi-line console message have no prefix, so they are
/// kept.
class PlaywrightOutput {
  PlaywrightOutput({this.maxLines = 30});

  final int maxLines;
  final _lines = ListQueue<String>();

  // Colors and the cursor movements of Playwright's line reporter.
  static final _ansiEscape = RegExp(r'\x1B\[[0-9;?]*[A-Za-z]');

  /// Adds a line of Playwright's stdout. Returns whether it was kept.
  bool addStdout(String line) {
    final clean = _clean(line);
    if (clean.contains('PATROL_LOG') || clean.startsWith('Playwright: ')) {
      return false;
    }
    return _add(clean);
  }

  /// Adds a line of Playwright's stderr. Returns whether it was kept.
  bool addStderr(String line) => _add(_clean(line));

  static String _clean(String line) =>
      line.replaceAll(_ansiEscape, '').trimRight();

  bool _add(String clean) {
    if (clean.trim().isEmpty ||
        clean.startsWith('To open last HTML report run:') ||
        clean.trim().startsWith('npx playwright show-report')) {
      return false;
    }
    _lines.add(clean);
    if (_lines.length > maxLines) {
      _lines.removeFirst();
    }
    return true;
  }

  /// The kept lines, oldest first.
  List<String> get lines => List.unmodifiable(_lines);
}
