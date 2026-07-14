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

## Version Compatibility

For the version compatibility table between `patrol_mcp` and `patrol_cli`,
see the [Patrol MCP documentation][mcp_docs].

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

2. Add the config for your editor. The server is launched directly with
   `dart run patrol_mcp` — no wrapper script or `chmod` needed.

Most editors use the **same** entry — only the config file location differs. Add
this block to your editor's MCP config file:

```json
{
  "mcpServers": {
    "patrol": {
      "command": "dart",
      "args": ["run", "patrol_mcp"],
      "env": {
        "PROJECT_ROOT": ".",
        "PATROL_FLAGS": "",
        "SHOW_TERMINAL": "false"
      }
    }
  }
}
```

| Editor | Config file | Notes |
| --- | --- | --- |
| Claude Code | `.mcp.json` (project root) | Auto-discovered; you'll be prompted to approve on first use. |
| Cursor | `.cursor/mcp.json` | Enable MCP under **Settings → Features → MCP**. |
| Gemini CLI | `.gemini/settings.json` | `mcpServers` lives alongside other keys in this file. |
| Google Antigravity | Global — open via MCP store → **Manage MCP Servers → View raw config** | Per-workspace config isn't supported. |
| GitHub Copilot (CLI) | `.mcp.json` (project root), or `~/.copilot/mcp-config.json` (global) | Then run `/mcp` to confirm `patrol` is listed. |

<details>
<summary>GitHub Copilot — VS Code extension (different format)</summary>

The VS Code extension uses `.vscode/mcp.json` with a `servers` key (not
`mcpServers`) and an explicit `"type": "stdio"`:

```json
{
  "servers": {
    "patrol": {
      "type": "stdio",
      "command": "dart",
      "args": ["run", "patrol_mcp"],
      "env": {
        "PROJECT_ROOT": ".",
        "PATROL_FLAGS": "",
        "SHOW_TERMINAL": "false"
      }
    }
  }
}
```

See [VS Code's MCP docs][vscode_mcp] for starting the server.

</details>

> [!NOTE]
> **Upgrading from the `run-patrol` wrapper?** It still works — you can delete
> the script and switch to the config above.

> [!NOTE]
> **Using FVM?** If your project is FVM-pinned (`.fvmrc` or `.fvm/`), develop
> sessions use the pinned SDK automatically. To override, set
> `PATROL_FLUTTER_COMMAND` in the `env` above. If `dart run patrol_mcp` fails
> with a version-resolution error under FVM, run the server under the pinned
> SDK too: `"command": "fvm", "args": ["dart", "run", "patrol_mcp"]`.

### Environment Variables

- `PROJECT_ROOT` (recommended): Flutter project directory containing `pubspec.yaml`.
  If omitted, `patrol_mcp` uses the current working directory.
- `PATROL_FLAGS`: Extra `patrol develop` flags, for example:
  `--flavor dev --verbose`.
  Use this for ports too: `--test-server-port 8081 --app-server-port 8082`.
- `SHOW_TERMINAL`: Open macOS Terminal for live logs (`"true"` / `"false"`).

`patrol_mcp` also respects environment variables supported by `patrol_cli`
(for example: `PATROL_FLUTTER_COMMAND`, which overrides FVM auto-detection).

### Setup Best Practices

- Prefer local/project MCP config when sharing setup with a team.
- Keep MCP config in the repository so teammates share the same setup.

## Tools

- `run`: Runs a test file and waits for completion.
- `quit`: Gracefully stops the active session.
- `status`: Returns session state and recent output.
- `screenshot`: Captures screenshot from active session device.
- `native-tree`: Fetches native UI tree from active session device.

## Agent skills

Patrol also ships [agent skills][skills] that complement this MCP server — the MCP provides the tools
above, while a skill teaches the agent *how* to use them to write Patrol tests. See the catalog for
the list and install instructions.

## Troubleshooting

- Make sure your IDE is opened at the mobile project root.
- Run `dart pub get` in the Flutter project root.
- Confirm MCP server is enabled in your IDE settings.
- Wrong Flutter/SDK used? The chosen Flutter command is logged at startup to the
  server's stderr (visible in your IDE's MCP logs).

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
[mcp_docs]: https://patrol.leancode.co/documentation/other/patrol-mcp?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[vscode_mcp]: https://code.visualstudio.com/docs/copilot/chat/mcp-servers
[skills]: https://github.com/leancodepl/patrol/tree/master/skills
[docs]: https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[article_web]: https://leancode.co/blog/patrol-web-support?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[article_4x]: https://leancode.co/blog/patrol-4-0-release?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[article_vscode]: https://leancode.co/blog/patrol-vs-code-extension?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[automate_flutter_app_testing_with_patrol]: https://leancode.co/products/automated-ui-testing-in-flutter?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[patrol_setup_and_training]: https://leancode.co/products/patrol-setup-training?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme
[raw_readme]: https://raw.githubusercontent.com/leancodepl/patrol/refs/heads/master/packages/patrol_mcp/README.md
