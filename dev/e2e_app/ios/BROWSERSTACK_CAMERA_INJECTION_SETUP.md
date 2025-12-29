# BrowserStack Camera Image Injection Setup for Patrol

This document describes how to set up BrowserStack Camera Image Injection for Patrol XCUITest integration.

## Overview

BrowserStack's Camera Image Injection feature allows you to simulate camera input during automated tests. This is useful for testing features like:
- QR code scanning
- Barcode recognition
- Check deposit (photo capture)
- Profile image capture

## Prerequisites

- BrowserStack App Automate account with Device Cloud Pro or higher plan
- Images uploaded to BrowserStack media storage

## Setup Steps

### 1. Extract the BrowserStackTestHelper Framework

The framework is included in the repository as a zip file. Extract it:

```bash
cd ios
unzip xcuitest-sample-browserstack-browserstack_test_helper/BrowserStackTestHelper.xcframework.zip -d Frameworks/
```

### 2. Link the Framework in Xcode

1. Open the project in Xcode (`Runner.xcworkspace`)

2. Select the **Runner** target

3. Go to **General** → **Frameworks, Libraries, and Embedded Content**

4. Click **+** and select **Add Other** → **Add Files...**

5. Navigate to `ios/Frameworks/BrowserStackTestHelper.xcframework` and add it

6. Set the embed option to **Embed & Sign**

### 3. Add Framework Search Path

1. Select the **Runner** target

2. Go to **Build Settings**

3. Find **Framework Search Paths**

4. Add `$(PROJECT_DIR)/Frameworks` (recursive)

### 4. Verify Setup

The following files should already be configured:

- `Runner/BrowserStackCameraInjectionPlugin.swift` - Flutter method channel handler
- `Runner/AppDelegate.swift` - Plugin registration

## Usage from Flutter/Dart

Use the `BrowserStackCameraInjection` class from your Patrol tests:

```dart
import 'browserstack_camera_injection.dart';

// Before triggering camera in your app:
final result = await BrowserStackCameraInjection.injectImage('my_qr_code.png');
if (result.success) {
  print('Image injected successfully');
  // Now trigger the camera action in your app
} else {
  print('Failed to inject image: ${result.message}');
}
```

## BrowserStack Test Execution

When running tests on BrowserStack, use these capabilities:

```bash
curl -u "YOUR_USERNAME:YOUR_ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
  -d '{
    "app": "bs://YOUR_APP_URL",
    "testSuite": "bs://YOUR_TEST_SUITE_URL",
    "devices": ["iPhone 14 Pro-16"],
    "resignApp": "true",
    "enableCameraImageInjection": "true",
    "cameraInjectionMedia": [
      "media://YOUR_MEDIA_ID"
    ]
  }' \
  -H "Content-Type: application/json"
```

### Upload Media to BrowserStack

```bash
curl -u "YOUR_USERNAME:YOUR_ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@/path/to/your/image.png" \
  -F "custom_id=MyImage"
```

## Local Development

When running locally (not on BrowserStack), the camera injection will return a failure response indicating that the feature is not available. This is expected behavior and allows you to safely include the injection calls in your tests without crashing on local devices.

## Troubleshooting

### "BrowserStackTestHelper framework not available"

This message appears when running locally. The framework only works on BrowserStack infrastructure.

### Build errors related to BrowserStackTestHelper

Ensure:
1. The framework is properly extracted to `ios/Frameworks/`
2. Framework Search Paths include `$(PROJECT_DIR)/Frameworks`
3. The framework is embedded and signed

### Camera injection not working on BrowserStack

Ensure:
1. `enableCameraImageInjection` is set to `true` in build capabilities
2. `resignApp` is set to `true`
3. Media files are uploaded and their IDs are included in `cameraInjectionMedia`
4. Images are injected **before** triggering the camera in the app

## Supported APIs

Camera image injection works with apps using these iOS Camera APIs:
- `AVCaptureDevice`
- `AVCaptureSession`
- `UIImagePickerController`

## Limitations

- Does not support video capture, only still images
- Does not work with Enterprise-signed apps (`resignApp` must be `true`)
- Maximum file size for images: 10 MB
- Supported formats: JPG, JPEG, PNG

## References

- [BrowserStack Camera Image Injection Documentation](https://www.browserstack.com/docs/app-automate/xcuitest/image-injection)
- [Patrol Documentation](https://patrol.leancode.co)

