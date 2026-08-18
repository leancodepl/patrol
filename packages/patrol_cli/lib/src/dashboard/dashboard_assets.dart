/// Static assets inlined into the generated dashboard, so the report is a
/// single self-contained file that opens from disk without a web server.
library;

/// The Patrol logo mark, with the brand yellow kept in both themes.
const patrolLogoSvg = '''
<svg class="logo-mark" viewBox="0 0 36.23 40" role="img" aria-label="Patrol" xmlns="http://www.w3.org/2000/svg">
<path d="M33.2794 33.2344H2.95024C2.24217 33.2344 1.65211 32.6409 1.77012 31.9288L5.90055 4.27301C6.25459 1.78042 8.37883 0 10.8571 0H25.2546C27.7328 0 29.8571 1.78042 30.2111 4.27301L34.3416 31.9288C34.5776 32.6409 33.9875 33.2344 33.2794 33.2344Z" fill="#F0FF00"/>
<path d="M11.5651 13.7689H13.5713C13.9254 13.7689 14.2794 14.125 14.2794 14.4811V16.4989C14.2794 16.8549 13.9254 17.211 13.5713 17.211H11.5651C11.2111 17.211 10.8571 16.8549 10.8571 16.4989V14.4811C10.8571 14.0063 11.2111 13.7689 11.5651 13.7689Z" fill="#1D1D1B"/>
<path d="M7.78877 17.9236H9.79498C10.149 17.9236 10.5031 18.2797 10.5031 18.6358V20.6535C10.5031 21.0096 10.149 21.3657 9.79498 21.3657H7.78877C7.43473 21.3657 7.08069 21.0096 7.08069 20.6535V18.6358C7.19872 18.2797 7.43473 17.9236 7.78877 17.9236Z" fill="#1D1D1B"/>
<path d="M11.5651 22.0773H13.5713C13.9254 22.0773 14.2794 22.4334 14.2794 22.7894V24.8072C14.2794 25.1633 13.9254 25.5194 13.5713 25.5194H11.5651C11.2111 25.5194 10.8571 25.1633 10.8571 24.8072V22.7894C10.8571 22.3147 11.2111 22.0773 11.5651 22.0773Z" fill="#1D1D1B"/>
<path d="M24.6645 3.79846H22.6583C22.3042 3.79846 21.9502 4.15455 21.9502 4.51064V6.52845C21.9502 6.88453 22.3042 7.24062 22.6583 7.24062H24.6645C25.0185 7.24062 25.3726 6.88453 25.3726 6.52845V4.39194C25.3726 4.03585 25.0185 3.79846 24.6645 3.79846Z" fill="#1D1D1B"/>
<path d="M28.4409 7.95312H26.4346C26.0806 7.95312 25.7266 8.30921 25.7266 8.66529V10.6831C25.7266 11.0391 26.0806 11.3952 26.4346 11.3952H28.4409C28.7949 11.3952 29.1489 11.0391 29.1489 10.6831V8.66529C29.0309 8.30921 28.7949 7.95312 28.4409 7.95312Z" fill="#1D1D1B"/>
<path d="M24.6645 12.1069H22.6583C22.3042 12.1069 21.9502 12.463 21.9502 12.8191V14.8369C21.9502 15.193 22.3042 15.5491 22.6583 15.5491H24.6645C25.0185 15.5491 25.3726 15.193 25.3726 14.8369V12.8191C25.3726 12.3443 25.0185 12.1069 24.6645 12.1069Z" fill="#1D1D1B"/>
<path d="M17.1116 4.39221H19.1179C19.4719 4.39221 19.8259 4.7483 19.8259 5.10438V28.8433C19.8259 29.1994 19.4719 29.5555 19.1179 29.5555H17.1116C16.7576 29.5555 16.4036 29.1994 16.4036 28.8433V5.10438C16.5216 4.6296 16.7576 4.39221 17.1116 4.39221Z" fill="#1D1D1B"/>
<path d="M35.0497 39.9996H1.18012C0.47205 39.9996 0 39.5249 0 38.8127V37.3884C0 36.6762 0.47205 36.2014 1.18012 36.2014H35.0497C35.7578 36.2014 36.2298 36.6762 36.2298 37.3884V38.8127C36.2298 39.4062 35.7578 39.9996 35.0497 39.9996Z" fill="#F0FF00"/>
</svg>''';

/// Favicon of the report, so a browser tab full of reports stays recognizable.
const dashboardFavicon =
    'data:image/svg+xml,'
    '%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 36 40%22%3E'
    '%3Crect width=%2236%22 height=%2240%22 rx=%228%22 fill=%22%231D1D1B%22/%3E'
    '%3Crect x=%228%22 y=%228%22 width=%224%22 height=%2224%22 fill=%22%23F0FF00%22/%3E'
    '%3Crect x=%2216%22 y=%2214%22 width=%224%22 height=%2218%22 fill=%22%23F0FF00%22/%3E'
    '%3Crect x=%2224%22 y=%2220%22 width=%224%22 height=%2212%22 fill=%22%23F0FF00%22/%3E'
    '%3C/svg%3E';

/// Stylesheet of the dashboard.
const dashboardCss = '''
*, *::before, *::after { box-sizing: border-box; }

:root {
  color-scheme: dark;
  --yellow: #f0ff00;
  --yellow-soft: rgba(240, 255, 0, 0.14);
  --bg: #101110;
  --bg-glow: radial-gradient(1200px 520px at 12% -20%, rgba(240, 255, 0, 0.10), transparent 70%);
  --surface: #191b19;
  --surface-2: #1f221f;
  --surface-3: #262a26;
  --border: #2c302c;
  --border-strong: #3b403b;
  --text: #f3f5f0;
  --text-dim: #9ba299;
  --text-faint: #6e756c;
  --pass: #55d98a;
  --fail: #ff5f56;
  --skip: #8b918a;
  --warn: #ffc53d;
  --shadow: 0 18px 40px -24px rgba(0, 0, 0, 0.9);
  --radius: 14px;
  --mono: ui-monospace, "SF Mono", SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace;
}

html[data-theme="light"] {
  color-scheme: light;
  --yellow: #d8e600;
  --yellow-soft: rgba(216, 230, 0, 0.18);
  --bg: #f4f5f1;
  --bg-glow: radial-gradient(1200px 520px at 12% -20%, rgba(240, 255, 0, 0.35), transparent 70%);
  --surface: #ffffff;
  --surface-2: #f7f8f4;
  --surface-3: #eef0e9;
  --border: #e0e2da;
  --border-strong: #cbcec3;
  --text: #1f1f1f;
  --text-dim: #5d635b;
  --text-faint: #8b918a;
  --pass: #1a9d55;
  --fail: #d92c22;
  --skip: #757b74;
  --warn: #a86c00;
  --shadow: 0 18px 40px -30px rgba(0, 0, 0, 0.35);
}

html { scroll-behavior: smooth; }

body {
  margin: 0;
  min-height: 100vh;
  background-color: var(--bg);
  background-image: var(--bg-glow);
  background-repeat: no-repeat;
  color: var(--text);
  font-family: Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  font-size: 15px;
  line-height: 1.5;
  -webkit-font-smoothing: antialiased;
}

.wrap { max-width: 1140px; margin: 0 auto; padding: 0 24px 72px; }

/* Inline icons never stretch to their container. */
.ico { width: 14px; height: 14px; flex: none; display: block; }

/* ---------- header ---------- */

.topbar {
  position: sticky;
  top: 0;
  z-index: 20;
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px 24px;
  border-bottom: 1px solid var(--border);
  background: var(--bg);
  background: color-mix(in srgb, var(--bg) 82%, transparent);
  backdrop-filter: blur(14px) saturate(140%);
}

.brand { display: flex; align-items: center; gap: 10px; text-decoration: none; color: inherit; }
.logo-mark { width: 22px; height: 24px; display: block; }
.brand-name { font-size: 17px; font-weight: 700; letter-spacing: -0.02em; }
.brand-sep { width: 1px; height: 20px; background: var(--border-strong); }
.brand-tag { font-size: 13px; color: var(--text-dim); letter-spacing: 0.04em; text-transform: uppercase; }
.topbar-spacer { flex: 1; }

.icon-button {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  height: 32px;
  padding: 0 12px;
  border: 1px solid var(--border);
  border-radius: 999px;
  background: var(--surface);
  color: var(--text-dim);
  font: inherit;
  font-size: 13px;
  white-space: nowrap;
  cursor: pointer;
  transition: color 0.15s, border-color 0.15s, background 0.15s;
}
.icon-button:hover { color: var(--text); border-color: var(--border-strong); }

/* ---------- hero ---------- */

.hero { padding: 36px 0 8px; }

.hero-title {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 12px;
  margin: 0;
  font-size: clamp(26px, 4vw, 38px);
  font-weight: 800;
  letter-spacing: -0.03em;
}
.hero-title .verdict-pass { color: var(--pass); }
.hero-title .verdict-fail { color: var(--fail); }

.hero-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 16px;
}
.pill {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  padding: 5px 11px;
  border: 1px solid var(--border);
  border-radius: 999px;
  background: var(--surface);
  color: var(--text-dim);
  font-size: 12.5px;
  white-space: nowrap;
}
.pill b { color: var(--text); font-weight: 600; }
.pill svg { width: 13px; height: 13px; opacity: 0.75; }

/* ---------- stats ---------- */

.stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 12px;
  margin-top: 26px;
}
.stat {
  padding: 16px 18px;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  background: var(--surface);
  box-shadow: var(--shadow);
}
.stat-label {
  display: flex;
  align-items: center;
  gap: 7px;
  font-size: 12px;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--text-faint);
}
.stat-value { margin-top: 8px; font-size: 30px; font-weight: 750; letter-spacing: -0.03em; }
.stat-value.small { font-size: 24px; }
.stat.accent { border-color: color-mix(in srgb, var(--yellow) 45%, var(--border)); background: linear-gradient(180deg, var(--yellow-soft), transparent 70%), var(--surface); }
.stat .dot { width: 8px; height: 8px; border-radius: 50%; }
.dot-passed { background: var(--pass); }
.dot-failed { background: var(--fail); }
.dot-skipped { background: var(--skip); }
.dot-incomplete { background: var(--warn); }
.stat-passed .stat-value { color: var(--pass); }
.stat-failed .stat-value { color: var(--fail); }
.stat-skipped .stat-value { color: var(--skip); }

.bar {
  display: flex;
  height: 8px;
  margin-top: 20px;
  border-radius: 999px;
  overflow: hidden;
  background: var(--surface-3);
}
.bar span { height: 100%; transition: width 0.4s ease; }
.bar .seg-passed { background: var(--pass); }
.bar .seg-failed { background: var(--fail); }
.bar .seg-incomplete { background: var(--warn); }
.bar .seg-skipped { background: var(--skip); }

/* ---------- run-level notices ---------- */

.notices { margin-top: 22px; display: grid; gap: 10px; }
.notice {
  padding: 12px 14px;
  border: 1px solid var(--border);
  border-left-width: 3px;
  border-radius: 10px;
  background: var(--surface);
  font-family: var(--mono);
  font-size: 12.5px;
  white-space: pre-wrap;
  word-break: break-word;
}
.notice pre { margin: 0; font: inherit; white-space: pre-wrap; }
.notice-error { border-left-color: var(--fail); }
.notice-warning { border-left-color: var(--warn); }

/* ---------- toolbar ---------- */

.toolbar {
  position: sticky;
  top: 61px;
  z-index: 10;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 10px;
  margin: 34px 0 14px;
  padding: 12px 0;
  background: var(--bg);
  background: color-mix(in srgb, var(--bg) 88%, transparent);
  backdrop-filter: blur(10px);
}

.search {
  flex: 1 1 220px;
  min-width: 180px;
  height: 36px;
  padding: 0 14px;
  border: 1px solid var(--border);
  border-radius: 999px;
  background: var(--surface);
  color: var(--text);
  font: inherit;
  font-size: 14px;
}
.search::placeholder { color: var(--text-faint); }
.search:focus { outline: none; border-color: var(--yellow); box-shadow: 0 0 0 3px var(--yellow-soft); }

.chips { display: flex; flex-wrap: wrap; gap: 6px; }
.chip {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  height: 32px;
  padding: 0 13px;
  border: 1px solid var(--border);
  border-radius: 999px;
  background: var(--surface);
  color: var(--text-dim);
  font: inherit;
  font-size: 13px;
  cursor: pointer;
  transition: color 0.15s, border-color 0.15s, background 0.15s;
}
.chip:hover { color: var(--text); }
.chip[aria-pressed="true"] {
  color: #1f1f1f;
  background: var(--yellow);
  border-color: var(--yellow);
  font-weight: 600;
}
.chip .count { opacity: 0.65; font-variant-numeric: tabular-nums; }

/* ---------- test list ---------- */

.tests { display: grid; gap: 8px; }

.test {
  border: 1px solid var(--border);
  border-radius: var(--radius);
  background: var(--surface);
  overflow: hidden;
  transition: border-color 0.15s;
}
.test:hover { border-color: var(--border-strong); }
.test.is-open { border-color: var(--border-strong); }
.test.status-failed { border-left: 3px solid var(--fail); }
.test.status-passed { border-left: 3px solid var(--pass); }
.test.status-skipped { border-left: 3px solid var(--skip); }
.test.status-incomplete { border-left: 3px solid var(--warn); }
.test[hidden] { display: none; }

.test-head {
  display: grid;
  grid-template-columns: 18px 1fr auto auto;
  align-items: center;
  gap: 12px;
  width: 100%;
  padding: 14px 16px;
  border: 0;
  background: none;
  color: inherit;
  font: inherit;
  text-align: left;
  cursor: pointer;
}
.test-head:hover { background: var(--surface-2); }
.test-head:focus-visible { outline: 2px solid var(--yellow); outline-offset: -2px; }

.chevron { color: var(--text-faint); transition: transform 0.2s ease; }
.chevron svg { width: 14px; height: 14px; display: block; }
.test.is-open .chevron { transform: rotate(90deg); color: var(--text-dim); }

.test-title { min-width: 0; }
.test-name {
  display: flex;
  align-items: center;
  gap: 9px;
  font-weight: 600;
  letter-spacing: -0.01em;
}
.test-name .status-dot { flex: none; width: 9px; height: 9px; border-radius: 50%; }
.test-file {
  margin-top: 3px;
  font-family: var(--mono);
  font-size: 12px;
  color: var(--text-faint);
  overflow-wrap: anywhere;
}

.test-facts { display: flex; align-items: center; gap: 14px; color: var(--text-dim); font-size: 12.5px; }
.test-facts .with-icon { display: inline-flex; align-items: center; gap: 5px; }
.test-facts svg { width: 13px; height: 13px; opacity: 0.7; }
.duration { font-variant-numeric: tabular-nums; }

.badge {
  padding: 3px 10px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}
.badge-passed { color: var(--pass); background: color-mix(in srgb, var(--pass) 16%, transparent); }
.badge-failed { color: var(--fail); background: color-mix(in srgb, var(--fail) 18%, transparent); }
.badge-skipped { color: var(--skip); background: color-mix(in srgb, var(--skip) 18%, transparent); }
.badge-incomplete { color: var(--warn); background: color-mix(in srgb, var(--warn) 18%, transparent); }

.test-body { display: none; border-top: 1px solid var(--border); padding: 18px 16px 20px; }
.test.is-open .test-body { display: grid; gap: 20px; }
.test-body.with-video { grid-template-columns: minmax(0, 1fr) 288px; }
@media (max-width: 860px) { .test-body.with-video { grid-template-columns: minmax(0, 1fr); } }

.section-label {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0 0 10px;
  font-size: 11.5px;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--text-faint);
}

/* ---------- exception ---------- */

/* Folded by default: a stack trace is dozens of lines and would otherwise
   push the steps off the screen. */
.exception {
  margin: 2px 0 8px 54px;
  border: 1px solid color-mix(in srgb, var(--fail) 30%, var(--border));
  border-radius: 10px;
  background: color-mix(in srgb, var(--fail) 7%, var(--surface));
  overflow: hidden;
}
.test-main > .exception { margin: 0 0 16px; }
@media (max-width: 640px) { .exception { margin-left: 0; } }

.exception-head {
  display: flex;
  align-items: center;
  gap: 9px;
  width: 100%;
  padding: 8px 11px;
  border: 0;
  background: none;
  color: inherit;
  font: inherit;
  text-align: left;
  cursor: pointer;
}
.exception-head:hover { background: color-mix(in srgb, var(--fail) 8%, transparent); }
.exception-head:focus-visible { outline: 2px solid var(--fail); outline-offset: -2px; }
.exception .chevron { color: var(--fail); display: flex; }
.exception.is-open .chevron { transform: rotate(90deg); }

.exception-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  flex: none;
  color: var(--fail);
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}
.exception-summary {
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-family: var(--mono);
  font-size: 12px;
  color: var(--text-dim);
}
/* The summary repeats the message's first line, so drop it once open. */
.exception.is-open .exception-summary { display: none; }

.exception-body { display: none; padding: 2px 12px 12px; }
.exception.is-open .exception-body { display: block; }
.exception-message {
  margin: 0;
  font-family: var(--mono);
  font-size: 12.5px;
  line-height: 1.55;
  white-space: pre-wrap;
  word-break: break-word;
  color: var(--text);
}
.exception-frames-label {
  margin: 12px 0 4px;
  font-size: 10.5px;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--text-faint);
}
/* Frames are reference material: dimmer, tighter, and scrollable past ~20. */
.exception-frames {
  margin: 0;
  max-height: 320px;
  overflow: auto;
  font-family: var(--mono);
  font-size: 11.5px;
  line-height: 1.4;
  white-space: pre-wrap;
  word-break: break-word;
  color: var(--text-faint);
}

/* ---------- steps ---------- */

.steps { list-style: none; margin: 0; padding: 0; display: grid; gap: 2px; }
.step { border-radius: 8px; }
.step-row {
  display: grid;
  grid-template-columns: 30px 14px minmax(0, 1fr) 72px 62px;
  align-items: center;
  gap: 10px;
  padding: 7px 8px;
  border-radius: 8px;
}
.step:hover > .step-row { background: var(--surface-2); }
.step-index { font-family: var(--mono); font-size: 11.5px; color: var(--text-faint); text-align: right; font-variant-numeric: tabular-nums; }
.step-icon { width: 14px; height: 14px; }
.step-icon svg { width: 14px; height: 14px; display: block; }
.step-passed .step-icon { color: var(--pass); }
.step-failed .step-icon { color: var(--fail); }
.step-running .step-icon { color: var(--warn); }
.step-action { font-size: 13.5px; overflow-wrap: anywhere; }
.step-failed .step-action { color: var(--fail); font-weight: 600; }
.step-running .step-action { color: var(--warn); }
.step-track { height: 4px; border-radius: 999px; background: var(--surface-3); overflow: hidden; }
.step-track span { display: block; height: 100%; border-radius: 999px; background: color-mix(in srgb, var(--yellow) 70%, var(--border-strong)); }
.step-failed .step-track span { background: var(--fail); }
.step-duration { font-family: var(--mono); font-size: 11.5px; color: var(--text-dim); text-align: right; font-variant-numeric: tabular-nums; }

@media (max-width: 640px) {
  .step-row { grid-template-columns: 24px 14px minmax(0, 1fr) 56px; }
  .step-track { display: none; }
}

.logs { list-style: none; margin: 2px 0 8px; padding: 0 0 0 54px; display: grid; gap: 3px; }
.log {
  display: flex;
  gap: 8px;
  font-family: var(--mono);
  font-size: 12px;
  color: var(--text-dim);
  white-space: pre-wrap;
  word-break: break-word;
}
.log::before { content: "›"; color: var(--text-faint); }
.logs.prelude { padding-left: 8px; margin-bottom: 14px; }

/* ---------- video ---------- */

.video-panel { align-self: start; }
.video-panel video {
  width: 100%;
  /* Phone recordings are portrait, so cap the height instead of letting one
     video stretch the whole row. */
  max-height: 520px;
  object-fit: contain;
  border: 1px solid var(--border);
  border-radius: 12px;
  background: #000;
  display: block;
}
.video-panel .video-path {
  margin-top: 8px;
  font-family: var(--mono);
  font-size: 11px;
  color: var(--text-faint);
  overflow-wrap: anywhere;
}
.video-panel a { color: var(--text-dim); }

.empty {
  padding: 42px 20px;
  border: 1px dashed var(--border-strong);
  border-radius: var(--radius);
  text-align: center;
  color: var(--text-dim);
}

footer {
  margin-top: 42px;
  padding-top: 20px;
  border-top: 1px solid var(--border);
  color: var(--text-faint);
  font-size: 12.5px;
  display: flex;
  flex-wrap: wrap;
  gap: 8px 18px;
}
footer a { color: var(--text-dim); }
''';

/// Behavior of the dashboard: filtering, search and expanding tests.
const dashboardJs = '''
(function () {
  var root = document.documentElement;
  var stored = null;
  try { stored = localStorage.getItem('patrol-report-theme'); } catch (e) {}
  if (stored) { root.dataset.theme = stored; }

  var themeButton = document.getElementById('theme-toggle');
  if (themeButton) {
    themeButton.addEventListener('click', function () {
      var next = root.dataset.theme === 'light' ? 'dark' : 'light';
      root.dataset.theme = next;
      try { localStorage.setItem('patrol-report-theme', next); } catch (e) {}
    });
  }

  var tests = Array.prototype.slice.call(document.querySelectorAll('.test'));
  var chips = Array.prototype.slice.call(document.querySelectorAll('.chip'));
  var search = document.getElementById('search');
  var empty = document.getElementById('empty');
  var filter = 'all';

  function apply() {
    var needle = (search && search.value || '').trim().toLowerCase();
    var visible = 0;
    tests.forEach(function (test) {
      var matchesFilter = filter === 'all' || test.dataset.status === filter;
      var haystack = test.dataset.search || '';
      var matchesNeedle = !needle || haystack.indexOf(needle) !== -1;
      var show = matchesFilter && matchesNeedle;
      test.hidden = !show;
      if (show) { visible++; }
    });
    if (empty) { empty.hidden = visible !== 0; }
  }

  chips.forEach(function (chip) {
    chip.addEventListener('click', function () {
      filter = chip.dataset.filter;
      chips.forEach(function (other) {
        other.setAttribute('aria-pressed', String(other === chip));
      });
      apply();
    });
  });

  if (search) {
    search.addEventListener('input', apply);
    search.addEventListener('keydown', function (event) {
      if (event.key === 'Escape') { search.value = ''; apply(); }
    });
  }

  function setOpen(test, open) {
    test.classList.toggle('is-open', open);
    var head = test.querySelector('.test-head');
    if (head) { head.setAttribute('aria-expanded', String(open)); }
  }

  tests.forEach(function (test) {
    var head = test.querySelector('.test-head');
    if (!head || test.dataset.details !== 'true') { return; }
    head.addEventListener('click', function () {
      setOpen(test, !test.classList.contains('is-open'));
    });
  });

  // The exception under a failing step folds on its own, so a long stack
  // trace does not bury the steps.
  Array.prototype.slice.call(document.querySelectorAll('.exception')).forEach(
    function (exception) {
      var head = exception.querySelector('.exception-head');
      if (!head) { return; }
      head.addEventListener('click', function (event) {
        event.stopPropagation();
        var open = !exception.classList.contains('is-open');
        exception.classList.toggle('is-open', open);
        head.setAttribute('aria-expanded', String(open));
      });
    }
  );

  var toggleAll = document.getElementById('toggle-all');
  if (toggleAll) {
    toggleAll.addEventListener('click', function () {
      var expandable = tests.filter(function (test) {
        return test.dataset.details === 'true' && !test.hidden;
      });
      var shouldOpen = expandable.some(function (test) {
        return !test.classList.contains('is-open');
      });
      expandable.forEach(function (test) { setOpen(test, shouldOpen); });
      toggleAll.querySelector('.label').textContent = shouldOpen ? 'Collapse all' : 'Expand all';
    });
  }

  apply();
})();
''';
