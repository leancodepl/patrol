# Contributing

If you're thinking about contributing to Patrol, thank you! We appreciate your help. Before you get started, we encourage you to read this document. It should make your contributing experience a bit better.

## Opening a PR

Before opening a PR with your changes, make sure you have updated the changelog for the package you modified.

In the PR description mention the issue that this PR resolves. If that issue doesn't exist, create one or describe in detail the changes introduced by this PR.

Use `## Unreleased` title if you're not sure what should be next version number.

Be aware that `test android emulator` and `test android emulator webview` workflows will fails due to insufficient permission of a contributor. Those will have to be re-run by someone with the write access in the repository.

## Running patrol_cli locally

If you want to work with a local version of patrol_cli, you can pick one of two approaches:

Activate patrol_cli locally by typing `dart pub global activate --source path [path to packages/patrol_cli]`. After that you can use `patrol` command exactly the same as any other pub package.

OR

Use `dart run [path to packages/patrol_cli] <command you want to test>`.

## Debugging patrol_cli

Changes to Patrol CLI can be debugged using the following configuration:

### Visual Studio Code

Use our `.vscode/launch.json` configuration changing the `cwd` value to the path of the project you
want to test and updating paths to the target tests in `args`.

```json
{
  "version": "0.1.0",
  "configurations": [
    {
      "name": "Patrol CLI",
      "request": "launch",
      "type": "dart",
      "program": "patrol/packages/patrol_cli/bin/main.dart",
      "cwd": "dev/e2e_app",
      "args": ["test", "-t", "patrol_test/example_test.dart"]
    }
  ]
}
```

### Android Studio

Use our `.run/patrol_cli.run.xml` configuration changing the `working directory` value to the path of the
project you want to test and updating paths to the target tests in `arguments`.

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="patrol_cli" type="DartCommandLineRunConfigurationType" factoryName="Dart Command Line Application">
    <option name="arguments" value="test -t patrol_test/example_test.dart" />
    <option name="filePath" value="$PROJECT_DIR$/packages/patrol_cli/bin/main.dart" />
    <option name="workingDirectory" value="$PROJECT_DIR$/dev/e2e_app" />
    <method v="2" />
  </configuration>
</component>
```

## Implementing native interactions

Native methods API is generated from a schema. If you wish to modify any of these methods, follow steps from below:

1. Go to `schema.dart` in the root directory of the repository.
2. If You want to add a new method, add it.
3. Run `./gen_from_schema` script to regenerate the contracts.
4. Implement these methods on the native side.

Note: On iOS, during development you should remove `#if PATROL_ENABLED` from `AutomatorServer.swift` and `Automator.swift` to make code completion work.

## Working with patrol_devtools_extension

If you plan to use the local version of Patrol to test/modify the Patrol DevTools extension, you need to deploy it first. To do this, navigate to the `patrol_devtools_extension` folder and run the `./publish_to_patrol_extension` script.

## Adding a new language or new strings to existing language for native OS interactions

Patrol finds some native UI elements by their label, so it ships the exact
system strings for each locale. The resources are generated from data files in
`packages/patrol/tool/native_localization/` – don't edit them by hand:

- iOS: `ios-dialog-strings.json` →
  `packages/patrol/darwin/patrol/Sources/PatrolImpl/Resources/<locale>.lproj/Localizable.strings`.
  Keys are the ones in `en.lproj`. Folder names, skipped locales, known-bad
  values and values that take precedence over the data are configured at the
  top of `generate.py`.
- Android: `android-dialog-strings.json` →
  `packages/patrol/android/src/main/res/values[-<qualifier>]/strings.xml`. To
  refresh it from AOSP (or add a locale to `QUALIFIERS`), run
  `python3 packages/patrol/tool/native_localization/fetch_android_strings.py`.
  AOSP `main` can be ahead of released Android versions; put values that a
  released version shows differently in `ANDROID_RELEASE_OVERRIDES` in
  `generate.py`. To compare with a device, pull the Settings / Photopicker APK
  (`adb shell pm path com.android.settings`) and run
  `aapt2 dump resources <apk>`.

After changing the data, regenerate the resources:

```
python3 packages/patrol/tool/native_localization/generate.py
```

No code changes are needed for a new locale: the device locale is matched
against the generated resources (region-aware, e.g. `es-MX` uses `es-419` on
iOS and `es-rUS` on Android). `packages/patrol/test/native_localization_test.dart`
checks that every locale has all keys.

If you add a new string, add its key to the data files and to `IOS_GROUPS` or
`ANDROID_KEYS` in `generate.py`, then use it in `IOSAutomator.swift` (e.g.
"labels" in `allowPermissionOnce()`) or `Automator.kt` (e.g.
`toggleAirplaneMode()`).
