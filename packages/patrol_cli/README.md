# patrol_cli

[![patrol_cli on pub.dev][pub_badge]][pub_link]
[![codestyle][pub_badge_style]][pub_badge_link]

Command-line tool to make working with [patrol][pub_link_test] easier.

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

### Skipping the build step

If you want to separate the build and test steps (e.g. to build once and run
tests multiple times), you can use `patrol build` to pre-build and then
`patrol test --no-build` to run with the existing binaries:

```console
$ patrol build android
$ patrol test --no-build
```

The `--no-build` flag tells `patrol test` to skip the build step entirely and
use the binaries previously produced by `patrol build android` (or
`patrol build ios`). The binaries are expected at their default output paths.

[pub_badge]: https://img.shields.io/pub/v/patrol_cli.svg
[pub_link]: https://pub.dartlang.org/packages/patrol_cli
[pub_link_test]: https://pub.dartlang.org/packages/patrol
[pub_badge]: https://img.shields.io/pub/v/patrol_cli.svg
[pub_link]: https://pub.dartlang.org/packages/patrol_cli
[pub_badge_style]: https://img.shields.io/badge/style-leancode__lint-black
[pub_badge_link]: https://pub.dartlang.org/packages/leancode_lint
[cli_completion package]: https://pub.dev/packages/cli_completion
