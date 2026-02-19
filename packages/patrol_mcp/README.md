# Patrol MCP Server

An MCP server to manage Patrol tests with AI agents.

## Features

- Run Patrol tests in develop mode and wait for completion (blocking)
- Smart session handling (auto-restart if session exists)
- Graceful quit
- Screenshot capture with auto-detected platform
- Native UI tree inspection

### Requirements

- A Flutter project with Patrol configured
- `fvm` optional (the run script uses it if available)

## Setup

### Project Structure

Your project should be organized as follows (final structure after setup):

```
your_mobile_project/
├── .cursor/
│   ├── mcp.json               # MCP server configuration
│   └── run-patrol              # Patrol run script
└── app/                        # Flutter app code
```

### Installation Steps

1. Add `patrol_mcp` as a dev dependency in your Flutter project's `pubspec.yaml`:

   ```yaml
   dev_dependencies:
     patrol_mcp:
       git:
         url: https://github.com/leancodepl/patrol.git
         path: packages/patrol_mcp
   ```

2. Create the run script:

   In your project mobile project root, create `.cursor/run-patrol` file with the following content:

   ```bash
   #!/usr/bin/env sh

   cd "${PROJECT_ROOT:-.}"
   export PROJECT_ROOT=$PWD

   if [ -d ".fvm/flutter_sdk" ]; then
     .fvm/flutter_sdk/bin/dart run patrol_mcp
   elif which fvm >/dev/null 2>&1; then
     fvm dart run patrol_mcp
   else
     dart run patrol_mcp
   fi
   ```

   Make it executable:

   ```bash
   chmod +x .cursor/run-patrol
   ```

3. Configure Cursor MCP in `.cursor/mcp.json`:

   From your project mobile project root, create/edit `.cursor/mcp.json`:

   ```json
   {
     "mcpServers": {
       "patrol": {
         "command": "./.cursor/run-patrol",
         "env": {
           "PROJECT_ROOT": "./app",
           "PATROL_FLAGS": "",
           "SHOW_TERMINAL": "false"
         }
       }
     }
   }
   ```

   **Configuration options:**

   - `PROJECT_ROOT`: Path to the Flutter project folder containing `pubspec.yaml` (default: current directory)
   - `PATROL_FLAGS`: Additional flags passed to the develop session. Multiple flags can be space-separated (e.g., `"--dart-define-from-file=.defines/dev.env --flavor dev"`). Supports the same flags as `patrol develop`.
   - `PATROL_TEST_PORT`: Port for patrol's test server (default: `8081`)
   - `PATROL_APP_SERVER_PORT`: Port for the app server (default: `8082`)
   - `PATROL_FLUTTER_COMMAND`: Custom flutter command (e.g., `fvm flutter`)
   - `SHOW_TERMINAL`: Set to `"true"` to open a Terminal window with live log streaming (macOS only). Logs are always written to `patrol.log` in the project root regardless of this setting

4. Ensure the MCP server is enabled in Cursor Settings → MCP.

## Troubleshooting

- Make sure you have IDE opened in the project mobile project root
- Ensure the dev dependency is installed: `dart pub get`
- Ensure `.cursor/run-patrol` is executable: `chmod +x .cursor/run-patrol`
- Check MCP server status in Cursor Settings → MCP

## Usage (from Cursor)

- `run` - Run patrol tests and wait for completion

  - Input: `{ "testFile": "integration_test/your_test.dart", "timeoutMinutes": 5 }`
  - Logs are written to `patrol.log` in the project root
  - If no session running: starts new session with specified test file
  - If session already running: automatically restarts current tests
  - Default timeout: 5 minutes

- `quit` - Quit the patrol session gracefully

  - Input: `{}`
  - Stops the develop session and cleans up resources
  - Returns immediately

- `status` - Get current status and recent output

  - Input: `{}`
  - Returns: `isDevelopRunning`, `testState`, `output`, device info

- `screenshot` - Capture a screenshot of the current device/simulator screen

  - No input required — platform is auto-detected from the active session
  - Captures screenshot using platform-specific commands (adb for Android, xcrun for iOS)
  - Returns image as base64-encoded PNG that Cursor can display directly
  - Requires an active patrol session (run a test first)

- `native-tree` - Fetch the native UI tree from the device

  - Input: `{}`
  - Requires an active patrol develop session
  - Returns native UI tree
  - Useful for writing system native interactions and interactions with apps other than the app under test
