# Patrol MCP Server

An MCP server that wraps `patrol develop` to manage end-to-end Flutter tests from Cursor with blocking behavior and activity-based timeouts.

## Features

- Pre-flight analysis check (runs `flutter analyze` before starting tests to catch errors early)
- Run Patrol tests and wait for completion (blocking)
- Smart session handling (auto-restart if session exists)
- Graceful quit via patrol's built-in command

### Requirements

- A Flutter project with Patrol configured
- `patrol` CLI on your PATH
- `fvm` optional (the run script uses it if available)

## Setup

### Project Structure

Your project should be organized as follows (final structure after setup):

```
your_mobile_project/
├── .cursor/
│   └── run-patrol           # Patrol run script
├── app/                     # Flutter app code
└── packages/
    └── patrol_mcp/          # Copy patrol_mcp here
```

### Installation Steps

1. **Option A (Recommended): Git dependency**

  TODO

2. Create the run script:

   - In your project mobile project root, create `.cursor/run-patrol` file with the following content:

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

   - Make it executable:

   ```bash
   # From your project mobile project root
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
           "PATROL_TEST_PORT": "8081",
           "SHOW_TERMINAL": "false"
         }
       }
     }
   }
   ```

   **Configuration options:**

   - `PROJECT_ROOT`: Path to the Flutter project folder containing `pubspec.yaml` (default: current directory)
   - `PATROL_FLAGS`: Additional flags for the `patrol develop` command. Multiple flags can be space-separated (e.g., `"--dart-define-from-file=.defines/dev.env --flavor dev"`)
   - `PATROL_TEST_PORT`: Port for patrol's test server (default: `8081`). Used by both `patrol develop` and native tree fetching
   - `SHOW_TERMINAL`: Set to `"true"` to open a Terminal window with live log streaming (macOS only). Logs are always written to `patrol.log` in the project root regardless of this setting

4. Ensure the MCP server is enabled in Cursor Settings → MCP.

## Troubleshooting

- Make sure you have IDE opened in the project mobile project root
- Ensure the dev dependency is installed: `dart pub get`
- Ensure `.cursor/run-patrol` is executable: `chmod +x .cursor/run-patrol`
- Verify the `patrol` CLI is available: `which patrol` should print a path
- Check MCP server status in Cursor Settings → MCP

## Usage (from Cursor)

- `patrol-run` - Run patrol tests and wait for completion (blocks Cursor)

  - Input: `{ "testFile": "integration_test/your_test.dart", "timeoutMinutes": 5 }`
  - Logs are written to `patrol.log` in the project root
  - If no session running: starts new session with specified test file
  - If session already running: automatically restarts current tests
  - Default timeout: 5 minutes (activity-based)

- `patrol-quit` - Quit the patrol session gracefully

  - Input: `{}`
  - Sends "Q" command to patrol process for clean shutdown
  - Returns immediately

- `patrol-status` - Get current status and recent output

  - Input: `{}`
  - Returns: `isDevelopRunning`, `testState`, `lastOutput`

- `patrol-screenshot` - Capture a screenshot of the current device/simulator screen

  - Input: `{ "platform": "android" }` or `{ "platform": "ios" }`
  - Captures screenshot using platform-specific commands:
    - Android: `adb exec-out screencap -p`
    - iOS: `xcrun simctl io booted screenshot --type=png /dev/stdout`
  - Returns image as base64-encoded PNG that Cursor can display directly
  - Requires active device/simulator connection

- `patrol-native-tree` - Fetch the native UI tree from the device

  - Input: `{}`
  - Requires an active patrol develop session
  - Returns native UI tree
  - Useful for writing system native interactions and interactions with apps other than the app under test.
