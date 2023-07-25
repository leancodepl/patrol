# patrol example app

This application demonstrates most of Patrol's features.

## Building

Make sure to use the compatible Patrol CLI version. The easiest way is to run:

```console
$ dart pub global activate --source path packages/patrol_cli && patrol
```

from the repository root.

Once you have the right Patrol CLI version, building artifacts for testing is easy.

### Android

Run in the example app's root:

```console
$ patrol build android
```

This builds 2 APKs:
- the app under test: `<example_root>/build/app/outputs/apk/debug/app-debug.apk`
- the instrumentation app: `<example_root>/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk`

### iOS device

Run in the example app's root:

```console
$ patrol build ios --release
```

### iOS simulator

Run in the example app's root:

```
$ patrol build ios --debug --simulator
```
