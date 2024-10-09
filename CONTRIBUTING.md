# Contributing

If you're thinking about contributing to Patrol, thank you! We appreciate your help.
Changes to Patrol CLI can be debugged using the following configuration:

### Visual Studio Code

Use our `.vscode/launch.json` configuration changing the `cwd` value to the path of the project you
want to test (if it's a project outside of `patrol`, use an absolute path). Update relative paths
to the target tests in `args`.

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

Use our `.run/patrol_cli.run.xml` configuration changing the `working directory` value to the path of the
project you want to test (if it's a project outside of `patrol`, use an absolute path). Update relative
paths to the target tests in `arguments`.

``` xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="patrol_cli" type="DartCommandLineRunConfigurationType" factoryName="Dart Command Line Application">
    <option name="arguments" value="test -t integration_test/example_test.dart" />
    <option name="filePath" value="$PROJECT_DIR$/packages/patrol_cli/bin/main.dart" />
    <option name="workingDirectory" value="$PROJECT_DIR$/dev/e2e_app" />
    <method v="2" />
  </configuration>
</component>
```
