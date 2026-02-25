# Feed BrowserStack-Injected Image to Camera Viewfinder

## Context

BrowserStack Camera Image Injection only intercepts specific iOS capture APIs (AVCapturePhoto, UIImagePickerController, AVCaptureStillImageOutput). QR scanner packages like `mobile_scanner` use `AVCaptureVideoDataOutput` for continuous frame scanning — an API BrowserStack does **not** inject into. So the injected image is never visible in the viewfinder and QR codes are never detected.

**Goal:** Add a new Patrol command that programmatically captures the BrowserStack-injected image using a supported API, converts it to a `CMSampleBuffer`, and feeds it directly to the video data output delegate — making QR scanners detect the injected QR code.

## Architecture

This command runs in the **app process** (where AVCaptureSession lives), not the test runner. It uses a Flutter method channel on `SwiftPatrolPlugin`, bypassing the generated schema/HTTP pipeline entirely.

```
Dart test → MethodChannel("pl.leancode.patrol/main") → SwiftPatrolPlugin → CameraViewfinderInjector
```

The existing `injectCameraPhoto` (test runner → BrowserStack staging) remains unchanged.

## Implementation

### 1. New Swift file: `CameraViewfinderInjector.swift`
**Path:** `darwin/Classes/CameraViewfinderInjector.swift`

A singleton class that:

**a) Swizzles `AVCaptureSession.startRunning()`** on first use to track active sessions via weak references. This lets us find the camera session created by any QR scanner package.

```swift
// In patrol_startRunning (swizzled):
CameraViewfinderInjector.shared.trackSession(self)
self.patrol_startRunning() // calls original
```

**b) `feedInjectedImageToViewfinder()` method** — the core logic:

1. **Find the active AVCaptureSession** from tracked sessions
2. **Find the `AVCaptureVideoDataOutput`** from `session.outputs`
3. **Get its `sampleBufferDelegate`** and `sampleBufferCallbackQueue`
4. **Add a temporary `AVCapturePhotoOutput`** to the session (requires `beginConfiguration()`/`commitConfiguration()`)
5. **Trigger `capturePhoto(with:delegate:)`** — BrowserStack intercepts this and returns the staged injected image
6. **In the `AVCapturePhotoCaptureDelegate` callback:**
   - Get the image from `AVCapturePhoto` (via `cgImageRepresentation()` or `pixelBuffer`)
   - Convert to a `CVPixelBuffer` in BGRA format (matching what mobile_scanner expects)
   - Create a `CMSampleBuffer` from the pixel buffer using `CMSampleBufferCreateForImageBuffer`
   - Call `delegate.captureOutput(videoDataOutput, didOutput: sampleBuffer, from: connection)` on the tracked delegate's queue
7. **Clean up:** remove the temporary `AVCapturePhotoOutput` from the session

Key helper: `createPixelBuffer(from cgImage: CGImage) -> CVPixelBuffer?` — creates a BGRA pixel buffer by drawing the CGImage into a `CGContext` backed by a `CVPixelBuffer`.

### 2. Modify `SwiftPatrolPlugin.swift`
**Path:** `darwin/Classes/SwiftPatrolPlugin.swift`

- In `register(with:)`: call `CameraViewfinderInjector.shared.installSwizzles()` to set up session tracking
- In `handle(_:result:)`: handle `"feedInjectedImageToViewfinder"` method call → delegate to `CameraViewfinderInjector.shared.feedInjectedImageToViewfinder(completion:)` → return result via `FlutterResult`

### 3. Add Dart method on `IOSAutomator`
**Path:** `lib/src/platform/ios/ios_automator.dart`

```dart
Future<void> feedInjectedImageToViewfinder();
```

### 4. Implement in `IOSAutomatorNative`
**Path:** `lib/src/platform/ios/ios_automator_native.dart`

Add a `MethodChannel` instance and call `'feedInjectedImageToViewfinder'` through it:

```dart
static const _channel = MethodChannel('pl.leancode.patrol/main');

@override
Future<void> feedInjectedImageToViewfinder() async {
  await _channel.invokeMethod('feedInjectedImageToViewfinder');
}
```

### 5. Expose on `PlatformAutomator`
**Path:** `lib/src/platform/platform_automator.dart`

```dart
Future<void> feedInjectedImageToViewfinder() {
  return ios.feedInjectedImageToViewfinder();
}
```

### 6. Update the example test
**Path:** `example/patrol_test/qr_scanner_test.dart`

```dart
await $.platform.ios.injectCameraPhoto(imageName: 'hello_patrol_qr.png');
await $('Scan QR code').tap();
// grant permissions...
await $.pump(const Duration(seconds: 2)); // wait for camera to initialize
await $.platform.ios.feedInjectedImageToViewfinder();
await $.pump(const Duration(seconds: 1));
expect($('Hello Patrol!'), findsOneWidget);
```

## Files to modify/create

| File | Action |
|------|--------|
| `darwin/Classes/CameraViewfinderInjector.swift` | **Create** — swizzling + capture + feed logic |
| `darwin/Classes/SwiftPatrolPlugin.swift` | **Modify** — register swizzle, handle method call |
| `lib/src/platform/ios/ios_automator.dart` | **Modify** — add abstract method |
| `lib/src/platform/ios/ios_automator_native.dart` | **Modify** — implement via MethodChannel |
| `lib/src/platform/platform_automator.dart` | **Modify** — expose method |
| `example/patrol_test/qr_scanner_test.dart` | **Modify** — use new method |

## Verification

1. Build the example app for iOS (`cd example && flutter build ios`)
2. Run the QR scanner test on BrowserStack with camera injection enabled
3. Confirm: the injected QR code image is detected by mobile_scanner and `Hello Patrol!` text appears
4. Confirm: the test passes end-to-end without tapping the shutter button
