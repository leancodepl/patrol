# Patrol MCP

[![patrol on pub.dev][patrol_badge]][patrol_link]
[![patrol_cli on pub.dev][patrol_cli_badge]][patrol_cli_link]
[![patrol_finders on pub.dev][patrol_finders_badge]][patrol_finders_link]
[![patrol_discord]][patrol_discord_link]
[![code style][leancode_lint_badge]][leancode_lint_link]
[![patrol_github_stars]][patrol_github_link]
[![patrol_x]][patrol_x_link]

MCP server for managing `patrol develop` sessions from AI agents.

## Features

- Run Patrol tests and block until completion.
- Keep and reuse a develop session for hot-restart workflows.
- Stream logs and expose session status.
- Capture screenshots with auto-detected platform.
- Read native UI tree during active sessions.

## Installation

By default, this setup assumes your Flutter project's `pubspec.yaml` is in the
repository root. If your app lives in a subdirectory, set `PROJECT_ROOT`
accordingly (for example `./app`).

1. Add `patrol_mcp` as a dev dependency in your Flutter project:

```yaml
dev_dependencies:
  patrol_mcp:
    git:
      url: https://github.com/leancodepl/patrol.git
      ref: feat/patrol-mcp
      path: packages/patrol_mcp
```

> [!IMPORTANT]
> This README focuses on project-local MCP setup.

2. Add the MCP server to your AI coding assistant configuration:

Create launcher script (`run-patrol`) in the IDE-specific location you plan to
reference from `command`.

```sh
#!/usr/bin/env sh
set -e

cd "${PROJECT_ROOT:-.}"
export PROJECT_ROOT=$PWD

if command -v fvm >/dev/null 2>&1; then
  export PATROL_FLUTTER_COMMAND="${PATROL_FLUTTER_COMMAND:-fvm flutter}"
  exec fvm dart run patrol_mcp
else
  export PATROL_FLUTTER_COMMAND="${PATROL_FLUTTER_COMMAND:-flutter}"
  exec dart run patrol_mcp
fi
```

Make it executable:

```sh
chmod +x <path-to-run-patrol>
```

Then configure your IDE MCP server:

<details>
<summary>Cursor</summary>

Add to `<workspace-root>/.cursor/mcp.json`:

Put script at: `<workspace-root>/.antigravity/run-patrol`

```json
{
  "mcpServers": {
    "patrol": {
      "command": "./.antigravity/run-patrol",
      "env": {
        "PROJECT_ROOT": ".",
        "PATROL_FLAGS": "",
        "SHOW_TERMINAL": "false"
      }
    }
  }
}
```

</details>

<details>
<summary>Google Antigravity</summary>

Put script at: `<workspace-root>/.cursor/run-patrol`

Open the MCP store, click "Manage MCP Servers", then "View raw config" and add to `mcp_config.json`:

```json
{
  "mcpServers": {
    "patrol": {
      "command": "./.cursor/run-patrol",
      "env": {
        "PROJECT_ROOT": ".",
        "PATROL_FLAGS": "",
        "SHOW_TERMINAL": "false"
      }
    }
  }
}
```

</details>

<details>
<summary>Gemini CLI</summary>

Put script at: `<workspace-root>/.gemini/run-patrol`

Add to `<workspace-root>/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "patrol": {
      "command": "./.gemini/run-patrol",
      "env": {
        "PROJECT_ROOT": ".",
        "PATROL_FLAGS": "",
        "SHOW_TERMINAL": "false"
      }
    }
  }
}
```

</details>

<details>
<summary>Claude Code</summary>

Put script at: `<workspace-root>/.claude/run-patrol`

You can run:

```bash
claude mcp add --transport stdio patrol -- ./.claude/run-patrol
```

Then make sure your Claude MCP config for `patrol` includes:

```json
{
  "mcpServers": {
    "patrol": {
      "command": "./.claude/run-patrol",
      "env": {
        "PROJECT_ROOT": ".",
        "PATROL_FLAGS": "",
        "SHOW_TERMINAL": "false"
      }
    }
  }
}
```

</details>

<details>
<summary>Copilot</summary>

Put script at: `<workspace-root>/.vscode/run-patrol`

Add to `<workspace-root>/mcp.json`:

```json
{
  "servers": {
    "patrol": {
      "command": "./.vscode/run-patrol",
      "env": {
        "PROJECT_ROOT": ".",
        "PATROL_FLAGS": "",
        "SHOW_TERMINAL": "false"
      }
    }
  }
}
```

</details>

### Environment Variables

- `PROJECT_ROOT` (recommended): Flutter project directory containing `pubspec.yaml`.
  If omitted, `patrol_mcp` uses the current working directory.
- `PATROL_FLAGS`: Extra `patrol develop` flags, for example:
  `--flavor dev --no-uninstall --open-devtools`.
  Use this for ports too: `--test-server-port 8081 --app-server-port 8082`.
- `SHOW_TERMINAL`: Open macOS Terminal for live logs (`"true"` / `"false"`).

`patrol_mcp` also respects environment variables supported by `patrol_cli`
(for example: `PATROL_FLUTTER_COMMAND`).
The provided `run-patrol` script sets `PATROL_FLUTTER_COMMAND` automatically:
`fvm flutter` when FVM is available, otherwise `flutter`.

### Setup Best Practices

- Prefer local/project MCP config when sharing setup with a team.
- Keep MCP config in the repository so teammates share the same setup.

## Tools

- `run`: Runs a test file and waits for completion.
- `quit`: Gracefully stops the active session.
- `status`: Returns session state and recent output.
- `screenshot`: Captures screenshot from active session device.
- `native-tree`: Fetches native UI tree from active session device.

## Troubleshooting

- Make sure your IDE is opened at the mobile project root.
- Run `dart pub get` in the Flutter project root.
- Verify your configured `run-patrol` path is executable.
- Confirm MCP server is enabled in your IDE settings.

## 🛠️ Maintained by LeanCode

<div align="center">
  <a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme">
    <img src="https://leancodepublic.blob.core.windows.net/public/wide.png" alt="LeanCode Logo" height="100" />
  </a>
</div>

This package is built with 💙 by **[LeanCode](https://leancode.co?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme)**.
We are **top-tier experts** focused on Flutter Enterprise solutions.

### Why LeanCode?

- **Creators of [Patrol](https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme)** - the next-gen testing framework for Flutter.
- **Production-Ready** - We use this package in apps with millions of users.
- **Full-Cycle Product Development** - We take your product from scratch to long-term maintenance.

<div align="center">
  <br />

  **Need help with your Flutter project?**

  [**👉 Hire our team**](https://leancode.co/get-estimate?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme)
  &nbsp;&nbsp;•&nbsp;&nbsp;
  [Check our other packages](https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads)

</div>

[patrol_badge]: https://img.shields.io/pub/v/patrol?label=patrol
[patrol_finders_badge]: https://img.shields.io/pub/v/patrol_finders?label=patrol_finders
[patrol_cli_badge]: https://img.shields.io/pub/v/patrol_cli?label=patrol_cli
[leancode_lint_badge]: https://img.shields.io/badge/code%20style-leancode__lint-blue
[patrol_github_stars]: https://img.shields.io/github/stars/leancodepl/patrol
[patrol_x]: https://img.shields.io/twitter/follow/patrol_leancode
[patrol_discord]: https://img.shields.io/discord/1167030497612922931?color=blue&logo=discord
[patrol_link]: https://pub.dev/packages/patrol
[patrol_finders_link]: https://pub.dev/packages/patrol_finders
[patrol_cli_link]: https://pub.dev/packages/patrol_cli
[leancode_lint_link]: https://pub.dev/packages/leancode_lint
[patrol_x_link]: https://x.com/patrol_leancode
[patrol_github_link]: https://github.com/leancodepl/patrol
[patrol_discord_link]: https://discord.gg/ukBK5t4EZg
