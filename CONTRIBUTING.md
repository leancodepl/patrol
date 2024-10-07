# Contributing

If you're thinking about contributing to Patrol, thank you! We appreciate your help.
Changes to Patrol CLI can be debugged using the following instructions:

### Visual Studio Code

Use our launch.json configuration changing the `cwd` value to the absolute path of the project you
want to test and relative paths to the target tests in `args`.

```json
{
  "version": "0.1.0",
  "configurations": [
    {
      "name": "Patrol CLI",
      "request": "launch",
      "type": "dart",
      "program": "patrol/packages/patrol_cli/bin/main.dart",
      "cwd": "absolute_path_to_my_project",
      "args": [
        "test",
        "-t",
        "integration_test/example_test.dart"
      ]
    }
  ]
}
```

### Android Studio

1. Click on `Edit Configurations` and add a `Dart Command Line App` configuration.
2. Set the `Dart file` to the absolute path of your `patrol_cli/bin/main.dart`.
3. Set the `Program arguments` to `test -t integration_test/example_test.dart` changing the
   relative paths to your target tests.
4. Set the `Working directory` to the absolute path of the project you want to test.

