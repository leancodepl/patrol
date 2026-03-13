# Patrol

[![patrol on pub.dev][patrol_badge]][patrol_link]
[![patrol_cli on pub.dev][patrol_cli_badge]][patrol_cli_link]
[![patrol_finders on pub.dev][patrol_finders_badge]][patrol_finders_link]
[![patrol_discord]][patrol_discord_link]
[![code style][leancode_lint_badge]][leancode_lint_link]
[![patrol_github_stars]][patrol_github_link]
[![patrol_x]][patrol_x_link]

A powerful, multiplatform E2E UI testing framework for Flutter apps that
overcomes the limitations of integration_test by handling native interactions.
Developed by [LeanCode](https://leancode.co) since 2022, battle-tested and
shaped by production-grade experience.

![Patrol promotial graphics][promo_graphics]

Learn more about Patrol:

- [Our extensive documentation][docs]
- [How Patrol 4.0 Makes Cross-Platform Flutter Testing Possible][article_4x]
- [Simplifying Flutter Web Testing: Patrol Web][article_web]
- [Patrol VS Code Extension - A Better Way to Run and Debug Flutter UI Tests][article_vscode]

## Patrol CLI

Command-line tool to run and debug tests written with [`patrol`][patrol_link] framework.

## Installation

### From pub.dev

```console
$ dart pub global activate patrol_cli
```

### From git

1. Make sure that you have Dart >= 2.18 installed.

   ```console
   $ dart --version
   ```

2. Clone the repo.
3. Go to `packages/patrol_cli`.
4. Run `dart pub global activate --source path .`

### Troubleshooting

If you can't run `patrol` from the terminal and the error is something along the
lines of "command not found", make sure that you've added appropriate
directories to PATH:

- on Unix-like systems, add `$HOME/.pub-cache/bin`
- on Windows, add `%USERPROFILE%\AppData\Local\Pub\Cache\bin`

### Disabling analytics

To disable analytics, set the `PATROL_ANALYTICS_ENABLED` environment variable to
`false`.

### Shell completion

Patrol CLI supports shell completion for bash, zsh and fish, thanks to the
[cli_completion package]. It will automatically append code necessary to make
the completion work to your shell's respective config file (e.g. `~/.zshrc`). To
disable this value, set the `PATROL_NO_COMPLETION` environment variable to any
value.

## Usage

Read the documentation:

- [setup](https://patrol.leancode.pl/getting-started)
- [test command](https://patrol.leancode.co/cli-commands/test)

## 🛠️ Maintained by LeanCode

<div align="center">
  <a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme">
    <img src="https://leancodepublic.blob.core.windows.net/public/wide.png" alt="LeanCode Logo" height="100" />
  </a>
</div>

This package is built with 💙 by **[LeanCode](https://leancode.co?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme)**.
We are **top-tier experts** focused on Flutter Enterprise solutions.

### Why LeanCode?

- **Creators of [Patrol](https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme)** – the next-gen testing framework for Flutter.

- **Production-Ready** – We use this package in apps with millions of users.
- **Full-Cycle Product Development** – We take your product from scratch to long-term maintenance.

<div align="center">
  <br />

  **Need help with your Flutter project?**

  [**👉 Hire our team**](https://leancode.co/get-estimate?utm_source=github.com&utm_medium=referral&utm_campaign=patrol-readme)
  &nbsp;&nbsp;•&nbsp;&nbsp;
  [Check our other packages](https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads)

</div>

[pub_link]: https://pub.dartlang.org/packages/patrol_cli
[pub_badge_style]: https://img.shields.io/badge/style-leancode__lint-black
[pub_badge_link]: https://pub.dartlang.org/packages/leancode_lint
[cli_completion package]: https://pub.dev/packages/cli_completion
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
[docs]: https://patrol.leancode.co
[docs_finders]: https://patrol.leancode.co/finders/overview
[promo_graphics]: ../../assets/promo_banner.png
[article_web]: https://leancode.co/blog/patrol-web-support
[article_4x]: https://leancode.co/blog/patrol-4-0-release
[article_vscode]: https://leancode.co/blog/patrol-vs-code-extension
[integration_test]: https://github.com/flutter/flutter/tree/master/packages/integration_test
