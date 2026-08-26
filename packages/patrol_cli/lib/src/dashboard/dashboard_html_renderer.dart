import 'dart:convert';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:path/path.dart' as path;
import 'package:patrol_cli/src/dashboard/dashboard_assets.dart';
import 'package:patrol_cli/src/dashboard/dashboard_report.dart';

/// Renders a [DashboardRun] as a single self-contained HTML page.
///
/// Everything the page needs is inlined, so the file can be opened straight
/// from disk or uploaded as a CI artifact. Videos are the one exception: they
/// are linked relatively, because inlining megabytes of MP4 would make the
/// report unusable.
class DashboardHtmlRenderer {
  /// Creates a renderer.
  const DashboardHtmlRenderer();

  /// Renders [run] into HTML.
  ///
  /// [reportPath] is where the file will be written; video links are made
  /// relative to its directory so moving the report together with the video
  /// directory keeps them working.
  String render(DashboardRun run, {required String reportPath}) {
    final reportDirectory = path.dirname(path.absolute(reportPath));
    final buffer = StringBuffer();

    final title =
        'Patrol report · ${run.appDescription ?? run.platform} '
        '· ${run.passedCount}/${run.totalCount} passed';

    buffer
      ..writeln('<!DOCTYPE html>')
      ..writeln('<html lang="en" data-theme="dark">')
      ..writeln('<head>')
      ..writeln('<meta charset="utf-8">')
      ..writeln(
        '<meta name="viewport" content="width=device-width, initial-scale=1">',
      )
      ..writeln('<title>${_escape(title)}</title>')
      ..writeln('<link rel="icon" href="$dashboardFavicon">')
      ..writeln('<style>$dashboardCss</style>')
      ..writeln('</head>')
      ..writeln('<body>');

    _writeTopbar(buffer);
    buffer.writeln('<div class="wrap">');
    _writeHero(buffer, run);
    _writeStats(buffer, run);
    _writeNotices(buffer, run);
    _writeToolbar(buffer, run);
    _writeTests(buffer, run, reportDirectory: reportDirectory);
    _writeFooter(buffer, run);
    buffer
      ..writeln('</div>')
      ..writeln('<script>$dashboardJs</script>')
      ..writeln('</body>')
      ..writeln('</html>');

    return buffer.toString();
  }

  void _writeTopbar(StringBuffer buffer) {
    buffer
      ..writeln('<header class="topbar">')
      ..writeln('<div class="brand">')
      ..writeln(patrolLogoSvg)
      ..writeln('<span class="brand-name">patrol</span>')
      ..writeln('</div>')
      ..writeln('<div class="brand-sep"></div>')
      ..writeln('<span class="brand-tag">Test report</span>')
      ..writeln('<div class="topbar-spacer"></div>')
      ..writeln(
        '<button class="icon-button" id="theme-toggle" type="button" '
        'title="Toggle light / dark theme">$iconContrast'
        '<span>Theme</span></button>',
      )
      ..writeln('</header>');
  }

  void _writeHero(StringBuffer buffer, DashboardRun run) {
    final verdict = run.isSuccessful
        ? '<span class="verdict-pass">All tests passed</span>'
        : '<span class="verdict-fail">'
              '${run.failedCount + run.incompleteCount} of ${run.totalCount} '
              'test${run.totalCount == 1 ? '' : 's'} failed</span>';

    buffer
      ..writeln('<section class="hero">')
      ..writeln('<h1 class="hero-title">$verdict</h1>')
      ..writeln('<div class="hero-meta">');

    _writePill(buffer, iconDevice, run.platform, run.deviceName);
    if (run.appDescription case final app?) {
      _writePill(buffer, iconApp, 'App', app);
    }
    _writePill(buffer, iconBuild, 'Build', run.buildMode);
    if (run.flavor case final flavor?) {
      _writePill(buffer, iconFlavor, 'Flavor', flavor);
    }
    _writePill(buffer, iconClock, 'Started', _formatDateTime(run.startedAt));

    buffer
      ..writeln('</div>')
      ..writeln('</section>');
  }

  void _writePill(
    StringBuffer buffer,
    String icon,
    String label,
    String value,
  ) {
    buffer.writeln(
      '<span class="pill">$icon${_escape(label)} '
      '<b>${_escape(value)}</b></span>',
    );
  }

  void _writeStats(StringBuffer buffer, DashboardRun run) {
    final tiles = <({String label, String value, String? status, bool accent})>[
      (
        label: 'Pass rate',
        value: '${(run.passRate * 100).round()}%',
        status: null,
        accent: true,
      ),
      (label: 'Total', value: '${run.totalCount}', status: null, accent: false),
      (
        label: 'Passed',
        value: '${run.passedCount}',
        status: 'passed',
        accent: false,
      ),
      (
        label: 'Failed',
        // An unfinished test is a failure as far as the reader is concerned.
        value: '${run.failedCount + run.incompleteCount}',
        status: 'failed',
        accent: false,
      ),
      (
        label: 'Skipped',
        value: '${run.skippedCount}',
        status: 'skipped',
        accent: false,
      ),
      (
        label: 'Duration',
        value: formatDuration(run.duration),
        status: null,
        accent: false,
      ),
    ];

    buffer.writeln('<section class="stats">');
    for (final tile in tiles) {
      final status = tile.status;
      buffer.writeln(
        '<div class="stat${tile.accent ? ' accent' : ''}'
        '${status == null ? '' : ' stat-$status'}">'
        '<div class="stat-label">'
        '${status == null ? '' : '<span class="dot dot-$status"></span>'}'
        '${_escape(tile.label)}</div>'
        '<div class="stat-value">${_escape(tile.value)}</div>'
        '</div>',
      );
    }
    buffer.writeln('</section>');

    _writeProgressBar(buffer, run);
  }

  void _writeProgressBar(StringBuffer buffer, DashboardRun run) {
    if (run.totalCount == 0) {
      return;
    }

    String segment(String name, int count) {
      if (count == 0) {
        return '';
      }
      final percent = count / run.totalCount * 100;
      return '<span class="seg-$name" style="width: '
          '${percent.toStringAsFixed(2)}%" title="$count $name"></span>';
    }

    buffer
      ..write('<div class="bar" role="img" aria-label="Test results">')
      ..write(segment('passed', run.passedCount))
      ..write(segment('failed', run.failedCount))
      ..write(segment('incomplete', run.incompleteCount))
      ..write(segment('skipped', run.skippedCount))
      ..writeln('</div>');
  }

  void _writeNotices(StringBuffer buffer, DashboardRun run) {
    if (run.errors.isEmpty && run.warnings.isEmpty) {
      return;
    }

    buffer.writeln('<section class="notices">');
    // Patrol logs a multi-line message one entry per line, so the lines are
    // joined back into a single block instead of a tile each.
    if (run.errors.isNotEmpty) {
      buffer.writeln(
        '<div class="notice notice-error"><pre>'
        '${_escape(_stripAnsi(run.errors.join('\n')).trim())}</pre></div>',
      );
    }
    for (final warning in run.warnings) {
      buffer.writeln(
        '<div class="notice notice-warning">'
        '${_escape(_stripAnsi(warning))}</div>',
      );
    }
    buffer.writeln('</section>');
  }

  void _writeToolbar(StringBuffer buffer, DashboardRun run) {
    final failedCount = run.failedCount + run.incompleteCount;

    String chip(String filter, String label, int count, {bool active = false}) {
      return '<button class="chip" type="button" data-filter="$filter" '
          'aria-pressed="$active">${_escape(label)} '
          '<span class="count">$count</span></button>';
    }

    buffer
      ..writeln('<div class="toolbar">')
      ..writeln(
        '<input class="search" id="search" type="search" '
        'placeholder="Filter tests, files, steps…" '
        'aria-label="Filter tests">',
      )
      ..writeln('<div class="chips">')
      ..writeln(chip('all', 'All', run.totalCount, active: true))
      ..writeln(chip('failed', 'Failed', failedCount))
      ..writeln(chip('passed', 'Passed', run.passedCount))
      ..writeln(chip('skipped', 'Skipped', run.skippedCount))
      ..writeln('</div>')
      ..writeln(
        '<button class="icon-button" id="toggle-all" type="button">'
        '$iconExpand<span class="label">Expand all</span></button>',
      )
      ..writeln('</div>');
  }

  void _writeTests(
    StringBuffer buffer,
    DashboardRun run, {
    required String reportDirectory,
  }) {
    buffer.writeln('<div class="tests">');
    for (var i = 0; i < run.tests.length; i++) {
      _writeTest(
        buffer,
        run.tests[i],
        index: i,
        reportDirectory: reportDirectory,
      );
    }
    buffer
      ..writeln('</div>')
      ..writeln(
        '<div class="empty" id="empty" hidden>No test matches the current '
        'filter.</div>',
      );

    if (run.tests.isEmpty) {
      buffer.writeln(
        '<div class="empty">This run reported no tests. Check the console '
        'output for build or device errors.</div>',
      );
    }
  }

  void _writeTest(
    StringBuffer buffer,
    DashboardTest test, {
    required int index,
    required String reportDirectory,
  }) {
    // Failed tests are what the report is opened for, so they start expanded.
    final startsOpen =
        test.hasDetails &&
        (test.status == DashboardTestStatus.failed ||
            test.status == DashboardTestStatus.incomplete);

    buffer.writeln(
      '<article class="test status-${test.status.name}'
      '${startsOpen ? ' is-open' : ''}" '
      'data-status="${test.status.name}" '
      'data-details="${test.hasDetails}" '
      'data-search="${_escape(_searchIndex(test))}">',
    );
    _writeTestHead(buffer, test, index: index, expanded: startsOpen);
    if (test.hasDetails) {
      _writeTestBody(
        buffer,
        test,
        index: index,
        reportDirectory: reportDirectory,
      );
    }
    buffer.writeln('</article>');
  }

  void _writeTestHead(
    StringBuffer buffer,
    DashboardTest test, {
    required int index,
    required bool expanded,
  }) {
    buffer
      ..writeln(
        '<button class="test-head" type="button" '
        'aria-expanded="$expanded" aria-controls="test-body-$index">',
      )
      ..writeln(
        '<span class="chevron">${test.hasDetails ? iconChevron : ''}</span>',
      )
      ..writeln('<span class="test-title">')
      ..writeln(
        '<span class="test-name">'
        '<span class="status-dot dot-${test.status.name}"></span>'
        '${_escape(test.name)}</span>',
      );

    if (test.filePath case final filePath?) {
      buffer.writeln('<span class="test-file">${_escape(filePath)}</span>');
    }

    buffer
      ..writeln('</span>')
      ..writeln('<span class="test-facts">');

    if (test.steps.isNotEmpty) {
      buffer.writeln(
        '<span class="with-icon" title="Patrol steps">$iconSteps'
        '${test.steps.length}</span>',
      );
    }
    if (test.videoPath != null) {
      buffer.writeln(
        '<span class="with-icon" title="Video recording">$iconVideo</span>',
      );
    }
    if (test.duration case final duration?) {
      buffer.writeln(
        '<span class="duration">${formatDuration(duration)}</span>',
      );
    }

    buffer
      ..writeln('</span>')
      ..writeln(
        '<span class="badge badge-${test.status.name}">'
        '${_escape(test.status.label)}</span>',
      )
      ..writeln('</button>');
  }

  void _writeTestBody(
    StringBuffer buffer,
    DashboardTest test, {
    required int index,
    required String reportDirectory,
  }) {
    final videoSrc = _videoSrc(test.videoPath, reportDirectory);
    buffer
      ..writeln(
        '<div class="test-body${videoSrc != null ? ' with-video' : ''}" '
        'id="test-body-$index">',
      )
      ..writeln('<div class="test-main">');

    // The exception belongs to the step that broke, so it is folded into that
    // step's row. Without a failing step it goes above the list, still folded.
    final exception = test.error == null
        ? null
        : _exceptionHtml(test.error!, id: 'exception-$index');
    final failingStep = test.steps.lastIndexWhere(
      (step) => step.status == DashboardStepStatus.failed,
    );

    if (exception != null && failingStep == -1) {
      buffer.writeln(exception);
    }
    _writeLogs(buffer, test.logs, prelude: true);
    _writeSteps(
      buffer,
      test,
      exception: failingStep == -1 ? null : exception,
      exceptionStepIndex: failingStep,
    );
    buffer.writeln('</div>');

    if (videoSrc != null) {
      _writeVideo(buffer, videoSrc, test.videoPath!);
    }

    buffer.writeln('</div>');
  }

  /// Builds the collapsed exception panel.
  ///
  /// Stack traces run to dozens of lines, so only a one-line summary is shown
  /// until the row is clicked. The message and the stack frames are kept as two
  /// blocks rather than a box per line.
  String _exceptionHtml(String error, {required String id}) {
    final (message, frames) = _splitException(_stripAnsi(error));
    final summary = message.isEmpty
        ? 'Exception'
        : message
              .split('\n')
              .firstWhere(
                (line) => line.trim().isNotEmpty,
                orElse: () => 'Exception',
              );

    final buffer = StringBuffer()
      ..write('<div class="exception">')
      ..write(
        '<button class="exception-head" type="button" aria-expanded="false" '
        'aria-controls="$id">'
        '<span class="chevron">$iconChevron</span>'
        '<span class="exception-tag">${iconAlert}Exception</span>'
        '<span class="exception-summary">'
        '${_escape(summary.trim())}</span>'
        '</button>',
      )
      ..write('<div class="exception-body" id="$id">');

    if (message.isNotEmpty) {
      buffer.write('<pre class="exception-message">${_escape(message)}</pre>');
    }
    if (frames.isNotEmpty) {
      final count = frames.where(_framePattern.hasMatch).length;
      buffer.write(
        '<div class="exception-frames-label">'
        'Stack trace · $count frame${count == 1 ? '' : 's'}</div>'
        '<pre class="exception-frames">'
        '${_escape(frames.join('\n'))}</pre>',
      );
    }

    return (buffer..write('</div></div>')).toString();
  }

  /// Splits a failure message into its human-readable part and its stack
  /// frames, so the frames can be rendered dimmer and tighter.
  ///
  /// Everything from the first `#0`-style frame onwards is a frame, including
  /// the `<asynchronous suspension>` markers between them.
  static (String, List<String>) _splitException(String error) {
    final lines = error.trimRight().split('\n');
    final firstFrame = lines.indexWhere(_framePattern.hasMatch);
    if (firstFrame == -1) {
      return (lines.join('\n').trim(), const []);
    }

    final message = lines.sublist(0, firstFrame);
    // The frames carry their own label, so Flutter's lead-in is just noise.
    while (message.isNotEmpty &&
        (message.last.trim().isEmpty ||
            message.last.trim() ==
                'When the exception was thrown, this was the stack:')) {
      message.removeLast();
    }

    return (message.join('\n').trim(), lines.sublist(firstFrame));
  }

  static final _framePattern = RegExp(r'^\s*#\d+\s');

  void _writeSteps(
    StringBuffer buffer,
    DashboardTest test, {
    String? exception,
    int exceptionStepIndex = -1,
  }) {
    if (test.steps.isEmpty) {
      return;
    }

    final longest = test.longestStepDuration.inMicroseconds;
    buffer
      ..writeln(
        '<div class="section-label">$iconSteps'
        'Steps <span>(${test.steps.length})</span></div>',
      )
      ..writeln('<ol class="steps">');

    for (var i = 0; i < test.steps.length; i++) {
      final step = test.steps[i];
      final statusName = step.status.name;
      final width = longest == 0 || step.duration == null
          ? 0.0
          : step.duration!.inMicroseconds / longest * 100;

      buffer
        ..writeln('<li class="step step-$statusName">')
        ..writeln('<div class="step-row">')
        ..writeln('<span class="step-index">${i + 1}</span>')
        ..writeln('<span class="step-icon">${_stepIcon(step.status)}</span>')
        ..writeln('<span class="step-action">${_escape(step.action)}</span>')
        ..writeln(
          '<span class="step-track"><span style="width: '
          '${width.toStringAsFixed(1)}%"></span></span>',
        )
        ..writeln(
          '<span class="step-duration">'
          '${step.duration == null ? '—' : formatDuration(step.duration!)}'
          '</span>',
        )
        ..writeln('</div>');

      _writeLogs(buffer, step.logs);
      if (exception != null && i == exceptionStepIndex) {
        buffer.writeln(exception);
      }
      buffer.writeln('</li>');
    }

    buffer.writeln('</ol>');
  }

  void _writeLogs(
    StringBuffer buffer,
    List<String> logs, {
    bool prelude = false,
  }) {
    if (logs.isEmpty) {
      return;
    }

    buffer.writeln('<ul class="logs${prelude ? ' prelude' : ''}">');
    for (final log in logs) {
      buffer.writeln('<li class="log">${_escape(_stripAnsi(log))}</li>');
    }
    buffer.writeln('</ul>');
  }

  void _writeVideo(StringBuffer buffer, String src, String absolutePath) {
    buffer
      ..writeln('<aside class="video-panel">')
      ..writeln('<div class="section-label">${iconVideo}Recording</div>')
      ..writeln(
        '<video controls preload="metadata" playsinline src="$src"></video>',
      )
      ..writeln(
        '<div class="video-path"><a href="$src" target="_blank" '
        'rel="noreferrer">${_escape(path.basename(absolutePath))}</a></div>',
      )
      ..writeln('</aside>');
  }

  void _writeFooter(StringBuffer buffer, DashboardRun run) {
    buffer
      ..writeln('<footer>')
      ..writeln(
        '<span>Generated by patrol_cli ${_escape(run.cliVersion)} · '
        '${_escape(_formatDateTime(DateTime.now()))}</span>',
      )
      ..writeln('<span>Device ${_escape(run.deviceId)}</span>');

    if (run.nativeReportPath case final nativeReport?) {
      buffer.writeln(
        '<span>Platform report: <a href="${_href(nativeReport)}">'
        '${_escape(path.basename(nativeReport))}</a></span>',
      );
    }

    buffer
      ..writeln(
        '<span><a href="https://patrol.leancode.co" target="_blank" '
        'rel="noreferrer">patrol.leancode.co</a></span>',
      )
      ..writeln('</footer>');
  }

  /// Lowercased haystack the client-side search filters on.
  String _searchIndex(DashboardTest test) {
    final buffer = StringBuffer()
      ..write(test.name)
      ..write(' ')
      ..write(test.filePath ?? '')
      ..write(' ')
      ..write(test.status.name)
      ..write(' ')
      ..write(test.error ?? '');
    for (final step in test.steps) {
      buffer
        ..write(' ')
        ..write(step.action);
    }
    return _stripAnsi(buffer.toString()).toLowerCase();
  }

  /// Path of the video relative to the report, as a URL.
  String? _videoSrc(String? videoPath, String reportDirectory) {
    if (videoPath == null) {
      return null;
    }

    // A relative link keeps working when the report and the video directory
    // are archived or moved together, e.g. as a CI artifact.
    try {
      final relative = path.relative(
        path.absolute(videoPath),
        from: reportDirectory,
      );
      return path.split(relative).map(Uri.encodeComponent).join('/');
    } on Exception {
      // No relative path exists, e.g. on a different Windows drive.
      return Uri.file(path.absolute(videoPath)).toString();
    }
  }

  String _href(String filePath) {
    if (filePath.startsWith('file://') ||
        filePath.startsWith('http://') ||
        filePath.startsWith('https://')) {
      return _escape(filePath);
    }
    return _escape(Uri.file(filePath).toString());
  }

  String _stepIcon(DashboardStepStatus status) => switch (status) {
    DashboardStepStatus.passed => iconCheck,
    DashboardStepStatus.failed => iconCross,
    DashboardStepStatus.running => iconClock,
  };

  static String _formatDateTime(DateTime dateTime) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${dateTime.year}-${two(dateTime.month)}-${two(dateTime.day)} '
        '${two(dateTime.hour)}:${two(dateTime.minute)}:${two(dateTime.second)}';
  }

  /// Formats [duration] the way the report shows it: `840ms`, `4.2s`, `2m 07s`.
  static String formatDuration(Duration duration) {
    final microseconds = duration.inMicroseconds;
    if (microseconds < 0) {
      return '0ms';
    }
    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    }
    if (duration.inSeconds < 60) {
      final seconds = microseconds / Duration.microsecondsPerSecond;
      return '${seconds.toStringAsFixed(seconds < 10 ? 2 : 1)}s';
    }
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds - minutes * 60;
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  /// Log lines and failure messages can carry terminal colors, which would
  /// show up as `[32m` garbage in HTML. Most lines have none, so the scan for
  /// an escape byte is worth it before handing the string to a regex.
  static String _stripAnsi(String value) =>
      value.contains('\x1B') ? AnsiStyles.strip(value) : value;

  /// Escapes `& < > " '` in a single pass. The values land in attributes as
  /// well as in text, so both quote styles have to go.
  static const _htmlEscape = HtmlEscape(
    HtmlEscapeMode(escapeLtGt: true, escapeQuot: true, escapeApos: true),
  );

  static String _escape(String value) => _htmlEscape.convert(value);
}
