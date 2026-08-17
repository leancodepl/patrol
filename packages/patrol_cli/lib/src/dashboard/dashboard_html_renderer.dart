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
        'title="Toggle light / dark theme">${_iconContrast()}'
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

    _writePill(buffer, _iconDevice(), run.platform, run.deviceName);
    if (run.appDescription case final app?) {
      _writePill(buffer, _iconApp(), 'App', app);
    }
    _writePill(buffer, _iconBuild(), 'Build', run.buildMode);
    if (run.flavor case final flavor?) {
      _writePill(buffer, _iconFlavor(), 'Flavor', flavor);
    }
    _writePill(buffer, _iconClock(), 'Started', _formatDateTime(run.startedAt));

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
    buffer
      ..writeln('<section class="stats">')
      ..writeln(
        _stat(
          className: 'accent',
          label: 'Pass rate',
          value: '${(run.passRate * 100).round()}%',
        ),
      )
      ..writeln(_stat(label: 'Total', value: '${run.totalCount}'))
      ..writeln(
        _stat(
          className: 'stat-passed',
          dot: 'passed',
          label: 'Passed',
          value: '${run.passedCount}',
        ),
      )
      ..writeln(
        _stat(
          className: 'stat-failed',
          dot: 'failed',
          label: 'Failed',
          value: '${run.failedCount + run.incompleteCount}',
        ),
      )
      ..writeln(
        _stat(
          className: 'stat-skipped',
          dot: 'skipped',
          label: 'Skipped',
          value: '${run.skippedCount}',
        ),
      )
      ..writeln(
        _stat(
          label: 'Duration',
          value: formatDuration(run.duration),
          small: true,
        ),
      )
      ..writeln('</section>');

    _writeProgressBar(buffer, run);
  }

  String _stat({
    required String label,
    required String value,
    String? className,
    String? dot,
    bool small = false,
  }) {
    final dotHtml = dot == null ? '' : '<span class="dot dot-$dot"></span>';
    return '<div class="stat ${className ?? ''}">'
        '<div class="stat-label">$dotHtml${_escape(label)}</div>'
        '<div class="stat-value${small ? ' small' : ''}">${_escape(value)}</div>'
        '</div>';
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
    for (final error in run.errors) {
      buffer.writeln(
        '<div class="notice notice-error">${_escape(_stripAnsi(error))}</div>',
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
        '${_iconExpand()}<span class="label">Expand all</span></button>',
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
    final status = test.status;
    // Failed tests are what the report is opened for, so they start expanded.
    final startsOpen =
        test.hasDetails &&
        (status == DashboardTestStatus.failed ||
            status == DashboardTestStatus.incomplete);
    final searchable = _searchIndex(test);

    buffer
      ..writeln(
        '<article class="test status-${status.slug}'
        '${startsOpen ? ' is-open' : ''}" '
        'data-status="${status.slug}" '
        'data-details="${test.hasDetails}" '
        'data-search="${_escape(searchable)}">',
      )
      ..writeln(
        '<button class="test-head" type="button" '
        'aria-expanded="$startsOpen" aria-controls="test-body-$index">',
      )
      ..writeln(
        '<span class="chevron">${test.hasDetails ? _iconChevron() : ''}</span>',
      )
      ..writeln('<span class="test-title">')
      ..writeln(
        '<span class="test-name">'
        '<span class="status-dot dot-${status.slug}"></span>'
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
        '<span class="with-icon" title="Patrol steps">${_iconSteps()}'
        '${test.steps.length}</span>',
      );
    }
    if (test.videoPath != null) {
      buffer.writeln(
        '<span class="with-icon" title="Video recording">'
        '${_iconVideo()}</span>',
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
        '<span class="badge badge-${status.slug}">'
        '${_escape(status.label)}</span>',
      )
      ..writeln('</button>');

    if (!test.hasDetails) {
      buffer.writeln('</article>');
      return;
    }

    final videoSrc = _videoSrc(test.videoPath, reportDirectory);
    buffer
      ..writeln(
        '<div class="test-body${videoSrc != null ? ' with-video' : ''}" '
        'id="test-body-$index">',
      )
      ..writeln('<div class="test-main">');
    _writeError(buffer, test);
    _writeLogs(buffer, test.logs, prelude: true);
    _writeSteps(buffer, test);
    buffer.writeln('</div>');

    if (videoSrc != null) {
      _writeVideo(buffer, videoSrc, test.videoPath!);
    }

    buffer
      ..writeln('</div>')
      ..writeln('</article>');
  }

  void _writeError(StringBuffer buffer, DashboardTest test) {
    if (test.error case final error?) {
      buffer
        ..writeln('<div class="error-box">')
        ..writeln('<div class="section-label">${_iconAlert()}Exception</div>')
        ..writeln('<pre>${_escape(_stripAnsi(error))}</pre>')
        ..writeln('</div>');
    }
  }

  void _writeSteps(StringBuffer buffer, DashboardTest test) {
    if (test.steps.isEmpty) {
      return;
    }

    final longest = test.longestStepDuration.inMicroseconds;
    buffer
      ..writeln(
        '<div class="section-label">${_iconSteps()}'
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
      buffer.writeln('</li>');
    }

    buffer.writeln('</ol>');
  }

  void _writeLogs(
    StringBuffer buffer,
    List<DashboardLog> logs, {
    bool prelude = false,
  }) {
    if (logs.isEmpty) {
      return;
    }

    buffer.writeln('<ul class="logs${prelude ? ' prelude' : ''}">');
    for (final log in logs) {
      buffer.writeln(
        '<li class="log">${_escape(_stripAnsi(log.message))}</li>',
      );
    }
    buffer.writeln('</ul>');
  }

  void _writeVideo(StringBuffer buffer, String src, String absolutePath) {
    buffer
      ..writeln('<aside class="video-panel">')
      ..writeln('<div class="section-label">${_iconVideo()}Recording</div>')
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
    final parts = <String>[
      test.name,
      test.filePath ?? '',
      test.status.slug,
      test.error ?? '',
      for (final step in test.steps) step.action,
    ];
    return _stripAnsi(parts.join(' ')).toLowerCase();
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
    DashboardStepStatus.passed => _iconCheck(),
    DashboardStepStatus.failed => _iconCross(),
    DashboardStepStatus.running => _iconPending(),
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

  static final _ansiPattern = RegExp(r'\x1B\[[0-9;]*[a-zA-Z]');

  /// Log lines and failure messages can carry terminal colors, which would
  /// show up as `[32m` garbage in HTML.
  static String _stripAnsi(String value) => value.replaceAll(_ansiPattern, '');

  static String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  // Inline icons, so the report needs no icon font.
  static String _svg(String body) =>
      '<svg class="ico" viewBox="0 0 16 16" fill="none" stroke="currentColor" '
      'stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" '
      'aria-hidden="true">$body</svg>';

  static String _iconCheck() => _svg('<path d="M3 8.5 6.2 11.7 13 4.9"/>');

  static String _iconCross() => _svg('<path d="M4 4l8 8M12 4l-8 8"/>');

  static String _iconPending() =>
      _svg('<circle cx="8" cy="8" r="5.3"/><path d="M8 5.4V8l1.9 1.4"/>');

  static String _iconChevron() => _svg('<path d="M6 3.5 10.5 8 6 12.5"/>');

  static String _iconSteps() =>
      _svg('<path d="M2.5 12.5h4v-3h4v-3h4"/><path d="M2.5 12.5v-2"/>');

  static String _iconVideo() => _svg(
    '<rect x="1.8" y="4" width="9" height="8" rx="1.6"/>'
    '<path d="M10.8 8.2l3.4-2.1v3.8L10.8 7.8z"/>',
  );

  static String _iconAlert() => _svg(
    '<path d="M8 2.6l5.8 10.2H2.2z"/><path d="M8 6.4v3"/>'
    '<path d="M8 11.3h.01"/>',
  );

  static String _iconClock() =>
      _svg('<circle cx="8" cy="8" r="5.6"/><path d="M8 5v3.2l2.2 1.3"/>');

  static String _iconDevice() => _svg(
    '<rect x="4.2" y="1.8" width="7.6" height="12.4" rx="1.7"/>'
    '<path d="M7 12.4h2"/>',
  );

  static String _iconApp() => _svg(
    '<rect x="2.2" y="2.2" width="5" height="5" rx="1.3"/>'
    '<rect x="8.8" y="2.2" width="5" height="5" rx="1.3"/>'
    '<rect x="2.2" y="8.8" width="5" height="5" rx="1.3"/>'
    '<rect x="8.8" y="8.8" width="5" height="5" rx="1.3"/>',
  );

  static String _iconBuild() => _svg(
    '<path d="M8 1.8l5.4 3.1v6.2L8 14.2 2.6 11.1V4.9z"/><path d="M8 8v6.2"/>'
    '<path d="M2.6 4.9L8 8l5.4-3.1"/>',
  );

  static String _iconFlavor() => _svg(
    '<path d="M2.6 6.4h10.8"/><path d="M4.6 6.4l1.5 7h3.8l1.5-7"/>'
    '<path d="M6.4 6.4V3.2h3.2v3.2"/>',
  );

  static String _iconContrast() =>
      _svg('<circle cx="8" cy="8" r="5.6"/><path d="M8 2.4v11.2"/>');

  static String _iconExpand() =>
      _svg('<path d="M5 6.2 8 9.2l3-3"/><path d="M5 10.8h6"/>');
}
