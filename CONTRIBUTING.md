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
      "args": [
        "test",
        "-t",
        "integration_test/example_test.dart",
      ]
    },
  ],
}

```

### Android Studio

Use our `.run/patrol_cli.run.xml` configuration changing the `working directory` value to the path of the
project you want to test and updating paths to the target tests in `arguments`.

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

## Implementing native interactions

Native methods API is generated from a schema. If you wish to modify any of these methods, follow steps from below:

1. Go to `schema.dart` in the root directory of the repository.
2. Find a method or a request/response class that you wish to modify, apply your changes.
3. Run `./gen_from_schema` script to regenerate the contracts.

## Working with patrol_devtools_extension 

If you plan to use the local version of Patrol to test/modify the Patrol DevTools extension, you need to deploy it first. To do this, navigate to the `patrol_devtools_extension` folder and run the `./publish_to_patrol_extension` script.
