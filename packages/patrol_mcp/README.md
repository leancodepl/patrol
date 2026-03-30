# Patrol MCP

[![patrol on pub.dev][patrol_badge]][patrol_link]
[![patrol_cli on pub.dev][patrol_cli_badge]][patrol_cli_link]
[![patrol_finders on pub.dev][patrol_finders_badge]][patrol_finders_link]
[![patrol_discord]][patrol_discord_link]
[![code style][leancode_lint_badge]][leancode_lint_link]
[![patrol_github_stars]][patrol_github_link]
[![patrol_x]][patrol_x_link]

MCP server that lets AI agents run and manage Patrol tests in Flutter projects.

![Patrol promotional graphics][promo_graphics]

## Learn more about Patrol:

- [Our extensive documentation][docs]
- [How Patrol 4.0 Makes Cross-Platform Flutter Testing Possible][article_4x]
- [Simplifying Flutter Web Testing: Patrol Web][article_web]
- [Patrol VS Code Extension - A Better Way to Run and Debug Flutter UI Tests][article_vscode]

## How can we help you:

Patrol is an open-source framework created and maintained by LeanCode.
However, if your company wants to scale fast and accelerate Patrol's
adoption, we offer a set of value-added services on top of the core framework.

You can find out more below:

- 🚀  [Automate Flutter app testing with Patrol][automate_flutter_app_testing_with_patrol]
- 🚀  [Patrol Setup & Patrol Training][patrol_setup_and_training]

## Features

- Run Patrol tests and block until completion.
- Keep and reuse a develop session for hot-restart workflows.
- Stream logs and expose session status.
- Capture screenshots with auto-detected platform.
- Read native UI tree during active sessions.

## Installation

> [!TIP]
> **AI-assisted setup:** Ask your AI agent to install and configure Patrol MCP
> in this project. Paste the [raw README][raw_readme] into the conversation for
> full context.

> [!IMPORTANT]
> This README focuses on project-local MCP setup.

By default, this setup assumes your Flutter project's `pubspec.yaml` is in the
repository root. If your app lives in a subdirectory, set `PROJECT_ROOT`
accordingly (for example `./app`).

1. Add `patrol_mcp` as a dev dependency in your Flutter project:

   ```sh
   dart pub add --dev patrol_mcp
   ```

   Or add it manually to your `pubspec.yaml` with the
   [latest version from pub.dev](https://pub.dev/packages/patrol_mcp).

2. Create a launcher script named `run-patrol` with the contents below.
   Where to save it and how to configure MCP depends on your IDE — see step 3.

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

3. Follow the instructions for your IDE:

<details>
<summary>Claude Code (CLI & VS Code extension)</summary>

Save the script to `<workspace-root>/.claude/run-patrol` and make it executable:

```sh
chmod +x .claude/run-patrol
```

Add to `<workspace-root>/.mcp.json` (must be at project root):

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

Claude Code automatically discovers `.mcp.json` from the project root —
no additional registration step is needed. On first use, you will be
prompted to approve the project-scoped MCP server.

</details>

<details>
<summary>Cursor</summary>

Save the script to `<workspace-root>/.cursor/run-patrol` and make it executable:

```sh
chmod +x .cursor/run-patrol
```

Add to `<workspace-root>/.cursor/mcp.json`:

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

> [!NOTE]
> Make sure MCP is enabled in Cursor: **Settings → Features → MCP**.

</details>

<details>
<summary>Copilot</summary>

Save the script to `<workspace-root>/.vscode/run-patrol` and make it executable:

```sh
chmod +x .vscode/run-patrol
```

Add to `<workspace-root>/.vscode/mcp.json`:

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

Reload the IDE, then open **Settings → MCP: List Servers**. Go to
**Patrol** and make sure the server is running — start it if needed.

> [!NOTE]
> After editing `mcp.json`, you may need to restart the MCP server:
> **Settings → MCP: List Servers → Patrol → Start**.

</details>

<details>
<summary>Gemini CLI</summary>

Save the script to `<workspace-root>/.gemini/run-patrol` and make it executable:

```sh
chmod +x .gemini/run-patrol
```

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
<summary>Google Antigravity</summary>

Save the script to `<workspace-root>/.antigravity/run-patrol` and make it executable:

```sh
chmod +x .antigravity/run-patrol
```

Open the MCP store, click "Manage MCP Servers", then "View raw config" and add to `mcp_config.json`.
Per-workspace MCP config is not yet supported — the config is global
(`~/.gemini/antigravity/mcp_config.json`). The relative command path
works because Antigravity resolves it against the open workspace:

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
[promo_graphics]: ../../assets/promo_banner.png
[docs]: https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[article_web]: https://leancode.co/blog/patrol-web-support?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[article_4x]: https://leancode.co/blog/patrol-4-0-release?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[article_vscode]: https://leancode.co/blog/patrol-vs-code-extension?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[automate_flutter_app_testing_with_patrol]: https://leancode.co/products/automated-ui-testing-in-flutter?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[patrol_setup_and_training]: https://leancode.co/products/patrol-setup-training?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[raw_readme]: https://raw.githubusercontent.com/leancodepl/patrol/refs/heads/master/packages/patrol_mcp/README.md
