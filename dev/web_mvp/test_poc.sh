#!/bin/bash

# POC Test Script for Patrol Web Native Bridge
# This script demonstrates how to test the Dart->Playwright communication

echo "🧪 Testing Patrol Web Native Bridge POC"
echo "========================================"

# Check if we're in the right directory
if [[ ! -f "dev/web_mvp/run.js" ]]; then
    echo "❌ Please run this script from the patrol project root"
    exit 1
fi

echo "📋 Instructions:"
echo "1. In Terminal 1, run:"
echo "   flutter run -d web-server --dart-define=PATROL_APP_SERVER_PORT=8082 --target integration_test/patrol_native_poc_test.dart"
echo ""
echo "2. Wait for Flutter to print the web server URL (e.g., http://localhost:8080)"
echo ""
echo "3. In Terminal 2, run:"
echo "   node dev/web_mvp/run.js <URL_FROM_STEP_2>"
echo ""
echo "✅ Expected behavior:"
echo "   - Playwright opens Chromium"
echo "   - Test calls patrolNative('grantPermissions', {...})"
echo "   - Console shows '[patrolNative] Action: grantPermissions'"
echo "   - Test passes with OK result"
echo "   - Error case also tested and handled correctly"
echo ""
echo "🎯 This POC demonstrates bidirectional communication:"
echo "   - Playwright -> Dart (existing): test orchestration"
echo "   - Dart -> Playwright (NEW): native actions during test execution"
