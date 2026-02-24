# Integrating BrowserStack Camera Image Injection into the Patrol Framework (iOS)

## Context

The patrol framework currently provides a `takeCameraPhoto` method that uses XCUITest to tap the camera shutter and done buttons on real/simulated camera UIs. When running tests on BrowserStack's Device Cloud, there is no physical camera. BrowserStack provides a **Camera Image Injection** feature that intercepts iOS camera APIs and returns pre-uploaded images instead of real camera input. This document describes in full detail every step needed to integrate BrowserStack's image injection into the patrol framework via a new `injectCameraPhoto` method on iOS. This method only handles the injection step; users then call the existing `takeCameraPhoto` to trigger the camera capture, which will return the injected image.

---

## 1. How BrowserStack Camera Image Injection Works

### 1.1 High-Level Flow

1. **Images are uploaded** to BrowserStack's media service via REST API, yielding media IDs (`media://...`).
2. When creating an XCUITest build on BrowserStack, capabilities `enableCameraImageInjection: "true"` and `cameraInjectionMedia: ["media://...", ...]` are set.
3. BrowserStack **re-signs the app** (requires `resignApp: "true"`) and **patches it** with its Camera code module.
4. The patched app has its camera APIs intercepted:
   - `UIImagePickerController` (`didFinishPickingMediaWithInfo`)
   - `AVCapturePhoto` (from `AVCapturePhotoOutput`)
   - `AVCaptureStillImageOutput` (`jpegStillImageNSDataRepresentation`)
5. In the XCUITest target, a BrowserStack-provided `injector` object is used to call `injectImage(imageName:)` **before** triggering the camera UI. This tells BrowserStack which image to return when the camera APIs are called.
6. After injection, the test opens the camera normally. Instead of capturing from the physical camera, the app receives the injected image.

### 1.2 The `BrowserStackTestHelper` Framework

BrowserStack provides a Swift framework called `BrowserStackTestHelper` that must be:
- **Imported** in the XCUITest target: `import BrowserStackTestHelper`
- **Linked** in the XCUITest target's Build Phases > Frameworks and Libraries

The framework exposes:
```swift
let injector: InjectorProtocol = createInstance()
injector.injectImage(imageName: "image.png") { response in
    print(response.toDictionary())
}
```

- `createInstance()` returns an `InjectorProtocol` conforming object
- `injectImage(imageName:completion:)` is an async method with a callback
- `imageName` refers to the filename of the image that was uploaded to BrowserStack (not a local path; the image must have been uploaded and referenced in `cameraInjectionMedia` capabilities)

### 1.3 Prerequisites & Limitations

- **iOS 13+** only
- **Enterprise-signed apps are NOT supported** (the app must be re-signable)
- **Only still images** (no video capture)
- **Image specs**: JPG, JPEG, PNG; max 10 MB per file
- Requires BrowserStack plan: Device Cloud Pro, Device Cloud Pro + Visual Cloud, or Enterprise Pro

---

## 2. Patrol Framework Architecture Overview (Relevant to This Integration)

### 2.1 Communication Model

```
Dart Test Code
  -> PlatformAutomator (platform_automator.dart)
    -> IOSAutomator interface (ios_automator.dart)
      -> IOSAutomatorNative implementation (ios_automator_native.dart)
        -> IosAutomatorClient HTTP client (ios_automator_client.dart) [GENERATED]
          -- HTTP POST over localhost:{PORT} -->
            -> IosAutomatorServer protocol (IosAutomatorServer.swift) [GENERATED]
              -> AutomatorServer implementation (AutomatorServer.swift)
                -> IOSAutomator (IOSAutomator.swift) [XCUITest calls]
```

### 2.2 Code Generation Pipeline

The single source of truth is **`/schema.dart`** at the repo root. The `patrol_gen` package reads this file and generates:
- **Dart side**: `contracts.dart` (data models), `ios_automator_client.dart` (HTTP client methods)
- **iOS/macOS side**: `Contracts.swift` (data models), `IosAutomatorServer.swift` (protocol + HTTP routes)

Adding a new method means:
1. Define the request class and method signature in `schema.dart`
2. Run `patrol_gen` to regenerate all contract files
3. Implement the actual logic in `AutomatorServer.swift`

### 2.3 Existing `takeCameraPhoto` Implementation

**`schema.dart`** (lines 317-322):
```dart
class IOSTakeCameraPhotoRequest {
  IOSSelector? shutterButtonSelector;
  IOSSelector? doneButtonSelector;
  late int? timeoutMillis;
  late String appId;
}
```

**`AutomatorServer.swift`** (lines 328-339): Simply calls `automator.tap()` twice - once on the shutter button (default accessibility ID `"PhotoCapture"`), once on the done button (default accessibility ID `"Done"`).

**`ios_automator_native.dart`** (lines 495-510): Wraps the request and forwards via HTTP client.

**`platform_automator.dart`** (lines 886-903): Top-level Dart API that dispatches to iOS or Android.

### 2.4 Key Files

| Purpose | Path |
|---------|------|
| Schema (source of truth) | `/schema.dart` |
| Code generator | `/packages/patrol_gen/` |
| Dart iOS interface | `/packages/patrol/lib/src/platform/ios/ios_automator.dart` |
| Dart iOS native impl | `/packages/patrol/lib/src/platform/ios/ios_automator_native.dart` |
| Dart iOS empty (stub) impl | `/packages/patrol/lib/src/platform/ios/ios_automator_empty.dart` |
| Dart platform automator | `/packages/patrol/lib/src/platform/platform_automator.dart` |
| Generated Dart HTTP client | `/packages/patrol/lib/src/platform/contracts/ios_automator_client.dart` |
| Generated Dart contracts | `/packages/patrol/lib/src/platform/contracts/contracts.dart` |
| Swift generated protocol + routes | `/packages/patrol/darwin/Classes/AutomatorServer/IosAutomatorServer.swift` |
| Swift generated contracts | `/packages/patrol/darwin/Classes/AutomatorServer/Contracts.swift` |
| Swift implementation | `/packages/patrol/darwin/Classes/AutomatorServer/AutomatorServer.swift` |
| Swift Automator protocol | `/packages/patrol/darwin/Classes/AutomatorServer/Automator/Automator.swift` |
| Swift IOSAutomator (XCUITest) | `/packages/patrol/darwin/Classes/AutomatorServer/Automator/IOSAutomator.swift` |
| CocoaPods podspec | `/packages/patrol/darwin/patrol.podspec` |
| Example Podfile | `/packages/patrol/example/ios/Podfile` |
| Example XCUITest runner | `/packages/patrol/example/ios/RunnerUITests/RunnerUITests.m` |
| XCUITest runner macro | `/packages/patrol/darwin/Classes/PatrolIntegrationTestIosRunner.h` |

---

## 3. Integration Steps

### Step 3.1: Add `BrowserStackTestHelper` as an Optional iOS Dependency

The `BrowserStackTestHelper` framework needs to be available in the XCUITest target at build time. Since patrol's iOS code is distributed via CocoaPods (the `patrol.podspec`), there are two approaches:

**Approach A: User-side Podfile addition (Recommended)**

Do NOT add BrowserStackTestHelper as a dependency of the patrol podspec itself, because:
- Not all patrol users use BrowserStack
- The framework may not be publicly available on CocoaPods
- It would create a hard dependency

Instead, **document** that users must add BrowserStackTestHelper to their `Podfile` in the `RunnerUITests` target:

```ruby
target 'RunnerUITests' do
  inherit! :complete
  pod 'BrowserStackTestHelper'  # or however BS distributes it
end
```

If BrowserStack distributes the framework as a `.framework` file rather than a CocoaPod, users would need to:
1. Download `BrowserStackTestHelper.framework` from BrowserStack
2. Add it to the Xcode project
3. Link it in the RunnerUITests target's "Frameworks and Libraries" build phase

**What patrol should do**: In the patrol Swift code, use **weak linking / conditional imports** so that the BrowserStackTestHelper framework is only loaded when available. This means:
- Use `@_weakLinked import BrowserStackTestHelper` or runtime checks
- Alternatively, use `#if canImport(BrowserStackTestHelper)` to conditionally compile the injection code
- If the framework is not available and `injectCameraPhoto` is called, throw a clear error

### Step 3.2: Define the New Request Type in `schema.dart`

Add a new request class alongside the existing `IOSTakeCameraPhotoRequest`:

```dart
class IOSInjectCameraPhotoRequest {
  /// The name of the image to inject (must match filename uploaded to BrowserStack).
  late String imageName;
  late String appId;
}
```

**Key field**: `imageName` is the filename (e.g., `"test_image.png"`) that was uploaded to BrowserStack and included in the `cameraInjectionMedia` capability. The `appId` is the bundle identifier of the app under test (automatically provided by the framework).

### Step 3.3: Add the New Method to the `IosAutomator` Service in `schema.dart`

In the `IosAutomator` abstract class in `schema.dart`, add under the `// camera` section:

```dart
abstract class IosAutomator<IOSServer, DartClient> {
  // ... existing methods ...

  // camera
  void takeCameraPhoto(IOSTakeCameraPhotoRequest request);
  void injectCameraPhoto(IOSInjectCameraPhotoRequest request); // NEW
  void pickImageFromGallery(IOSPickImageFromGalleryRequest request);
  void pickMultipleImagesFromGallery(IOSPickMultipleImagesFromGalleryRequest request);
}
```

**Important**: This method is iOS-only. Do NOT add it to the `AndroidAutomator` abstract class.

### Step 3.4: Run Code Generation

Run the `patrol_gen` tool to regenerate all contract/client/server files:

```bash
cd /path/to/patrol
dart run packages/patrol_gen/bin/main.dart
```

This will regenerate:
- **Dart**: `contracts.dart` (adds `IOSInjectCameraPhotoRequest` class with JSON serialization), `ios_automator_client.dart` (adds `injectCameraPhoto` HTTP method)
- **Swift**: `Contracts.swift` (adds `IOSInjectCameraPhotoRequest` struct), `IosAutomatorServer.swift` (adds protocol method, HTTP handler, and route for `POST /injectCameraPhoto`)

### Step 3.5: Implement the Swift-Side Logic in `AutomatorServer.swift`

In `AutomatorServer.swift`, add a new method in the `// MARK: Camera` section, following the pattern of `takeCameraPhoto`:

```swift
func injectCameraPhoto(request: IOSInjectCameraPhotoRequest) throws {
    // Call BrowserStack's injector to stage the image for the next camera capture.
    // After this call completes, the next time the app opens the camera,
    // it will receive this injected image instead of real camera input.
    // The user must then call takeCameraPhoto() separately to trigger the capture.
    #if canImport(BrowserStackTestHelper)
    import BrowserStackTestHelper

    let injector = createInstance()
    let semaphore = DispatchSemaphore(value: 0)
    var injectionError: Error? = nil

    injector.injectImage(imageName: request.imageName) { response in
        let result = response.toDictionary()
        // Optionally check response for success
        // If BrowserStack reports an error, capture it
        semaphore.signal()
    }

    // Wait for injection to complete (with a reasonable timeout)
    let waitResult = semaphore.wait(timeout: .now() + 30)
    if waitResult == .timedOut {
        throw PatrolError.generic("BrowserStack image injection timed out")
    }
    if let error = injectionError {
        throw error
    }
    #else
    throw PatrolError.generic(
        "BrowserStackTestHelper framework is not available. " +
        "To use injectCameraPhoto, add BrowserStackTestHelper to your project " +
        "and ensure it is linked with the RunnerUITests target."
    )
    #endif
    // NOTE: This method ONLY injects the image. It does NOT tap any camera buttons.
    // The user should call takeCameraPhoto() after this to actually trigger the
    // camera capture and accept the photo.
}
```

**Critical detail**: The `injectImage` call is **asynchronous** (takes a completion handler), but patrol's server handlers are **synchronous** (they return `HTTPResponse` directly). The implementation must use a `DispatchSemaphore` or similar mechanism to block until the injection completes before returning. This is consistent with how other blocking operations work in the patrol framework (e.g., `IOSAutomator.swift` uses `DispatchQueue.main.sync` for XCUITest operations).

**Alternative approach**: If `#if canImport` does not work reliably with the BrowserStackTestHelper framework (e.g., if it's a dynamic framework loaded at runtime), then use runtime reflection (`NSClassFromString`, `NSSelectorFromString`) to dynamically call the BrowserStack APIs without a compile-time dependency. This would look something like:

```swift
guard let helperClass = NSClassFromString("BrowserStackTestHelper.SomeClass") else {
    throw PatrolError.generic("BrowserStackTestHelper not available")
}
// Use performSelector or protocol casting to call methods
```

### Step 3.6: Add the Method to the Dart `IOSAutomator` Interface

In `/packages/patrol/lib/src/platform/ios/ios_automator.dart`, add:

```dart
/// Inject an image for BrowserStack Camera Image Injection.
///
/// This method stages the specified [imageName] so that the next time the
/// app opens the camera, it will receive the injected image instead of real
/// camera input. After calling this, use [takeCameraPhoto] to trigger the
/// actual camera capture.
///
/// [imageName] must match the filename of an image uploaded to BrowserStack
/// and included in the `cameraInjectionMedia` build capability.
///
/// This only works when running on BrowserStack with:
/// - `enableCameraImageInjection: "true"` capability
/// - `resignApp: "true"` capability
/// - `BrowserStackTestHelper` framework linked in the XCUITest target
Future<void> injectCameraPhoto({
  required String imageName,
});
```

**Note**: The empty stub implementation (`ios_automator_empty.dart`) does NOT need changes. It uses `noSuchMethod` with `UnimplementedError`, so any new method is automatically stubbed.

### Step 3.7: Implement in `ios_automator_native.dart`

Add the implementation following the exact same pattern as `takeCameraPhoto`:

```dart
@override
Future<void> injectCameraPhoto({
  required String imageName,
}) async {
  await wrapRequest('injectCameraPhoto', () async {
    await _client.injectCameraPhoto(
      IOSInjectCameraPhotoRequest(
        imageName: imageName,
        appId: resolvedAppId,
      ),
    );
  });
}
```

### Step 3.8: Add to `PlatformAutomator` (Top-Level Dart API)

In `/packages/patrol/lib/src/platform/platform_automator.dart`, add a new method. Since this is iOS-only, it should NOT dispatch to Android:

```dart
/// Inject an image for BrowserStack Camera Image Injection (iOS only).
///
/// Stages [imageName] so that the next camera capture returns this image
/// instead of real camera input. Call [takeCameraPhoto] after this to
/// trigger the actual capture.
///
/// This only works on iOS when running on BrowserStack with the
/// appropriate capabilities enabled.
Future<void> injectCameraPhoto({
  required String imageName,
}) {
  return platform.ios.injectCameraPhoto(
    imageName: imageName,
  );
}
```

**Note**: Unlike `takeCameraPhoto` which uses `platform.action.mobile(android: ..., ios: ...)`, this method calls `platform.ios` directly since there is no Android equivalent.

### Step 3.9: Export the New Method

Ensure the method is accessible from the public patrol API. Check that `ios_automator.dart` is exported through the package's barrel files. Since it follows the same pattern as existing methods, it should be automatically available via:

```dart
import 'package:patrol/patrol.dart';
```

Users would call it as:

```dart
// Inject the image first
await $.platform.ios.injectCameraPhoto(imageName: 'test_photo.png');
// Then take the photo normally - the injected image will be used
await $.platform.mobile.takeCameraPhoto();
```

---

## 4. What the App Developer (Patrol User) Must Do

The patrol framework integration handles the test-side logic. But for image injection to work end-to-end, the app developer must also:

### 4.1 Upload Images to BrowserStack

```bash
curl -u "USERNAME:ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@/path/to/test_photo.png" \
  -F "custom_id=TestPhoto"
```

Response:
```json
{
  "media_url": "media://7717712ffda8581f04455427b64ec581e35222a9"
}
```

### 4.2 Add BrowserStackTestHelper to Their iOS Project

Either via CocoaPods in their `Podfile`:

```ruby
target 'RunnerUITests' do
  inherit! :complete
  pod 'BrowserStackTestHelper'
end
```

Or by manually adding the `.framework` file to their Xcode project and linking it in the RunnerUITests target.

### 4.3 Configure BrowserStack Build Capabilities

When creating the XCUITest build on BrowserStack:

```bash
curl -u "USERNAME:ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
  -H "Content-Type: application/json" \
  -d '{
    "app": "bs://APP_HASH",
    "testSuite": "bs://TEST_SUITE_HASH",
    "devices": ["iPhone 14 Pro-16"],
    "resignApp": "true",
    "enableCameraImageInjection": "true",
    "cameraInjectionMedia": [
      "media://7717712ffda8581f04455427b64ec581e35222a9"
    ]
  }'
```

### 4.4 Ensure App Uses Supported Camera APIs

The app must use one of these iOS camera APIs for injection to work:
- `UIImagePickerController` (most common in Flutter via `image_picker` plugin)
- `AVCapturePhoto` / `AVCapturePhotoOutput`
- `AVCaptureStillImageOutput`

The Flutter `image_picker` plugin uses `UIImagePickerController` under the hood, so it is compatible.

---

## 5. Example Test Code (End Result)

After integration, a patrol test using BrowserStack image injection would look like:

```dart
patrolTest('camera with injected image on BrowserStack', ($) async {
  await $.pumpWidgetAndSettle(const MyApp());

  await $('Take a photo').tap();

  if (await $.platform.mobile.isPermissionDialogVisible()) {
    await $.platform.mobile.grantPermissionWhenInUse();
  }

  // Step 1: Inject the image BEFORE triggering the camera capture.
  // 'test_photo.png' must have been uploaded to BrowserStack
  // and included in cameraInjectionMedia capability.
  await $.platform.ios.injectCameraPhoto(
    imageName: 'test_photo.png',
  );

  // Step 2: Take the camera photo as usual. Because the image was
  // injected above, the app will receive 'test_photo.png' instead
  // of real camera input.
  await $.platform.mobile.takeCameraPhoto();

  await $.pumpAndSettle(duration: const Duration(seconds: 1));

  expect($(Image), findsOneWidget);
});
```

---

## 6. Testing & Verification

### 6.1 Local Development (Without BrowserStack)

- The new method should compile even without BrowserStackTestHelper present (thanks to `#if canImport` or runtime checks)
- Calling `injectCameraPhoto` locally should throw a clear error: "BrowserStackTestHelper framework is not available"
- All existing tests must continue to pass (no regressions)

### 6.2 On BrowserStack

- Upload a test image to BrowserStack
- Create a build with `enableCameraImageInjection` and `cameraInjectionMedia` set
- Run a test that calls `injectCameraPhoto` followed by `takeCameraPhoto`
- Verify the app receives the injected image (not a blank/error image)
- Verify the callback response from `injectImage` indicates success

### 6.3 Code Generation Verification

- After modifying `schema.dart`, run `patrol_gen` and verify all generated files are consistent
- Verify the generated Swift protocol includes `injectCameraPhoto`
- Verify the generated Dart client includes the HTTP method
- Verify the generated contracts include `IOSInjectCameraPhotoRequest`

---

## 7. Summary of Files to Modify

| File | Action | What Changes |
|------|--------|-------------|
| `/schema.dart` | Edit | Add `IOSInjectCameraPhotoRequest` class and `injectCameraPhoto` method to `IosAutomator` |
| (run `patrol_gen`) | Generate | Regenerates `contracts.dart`, `ios_automator_client.dart`, `Contracts.swift`, `IosAutomatorServer.swift` |
| `/packages/patrol/darwin/Classes/AutomatorServer/AutomatorServer.swift` | Edit | Add `injectCameraPhoto` implementation with BrowserStack injector call |
| `/packages/patrol/lib/src/platform/ios/ios_automator.dart` | Edit | Add `injectCameraPhoto` method signature to interface |
| `/packages/patrol/lib/src/platform/ios/ios_automator_native.dart` | Edit | Add `injectCameraPhoto` implementation |
| `/packages/patrol/lib/src/platform/platform_automator.dart` | Edit | Add top-level `injectCameraPhoto` method (iOS-only) |

**No changes needed** to:
- `ios_automator_empty.dart` (uses `noSuchMethod`, auto-stubs)
- `patrol.podspec` (BrowserStackTestHelper is a user-side dependency)
- Android code (this is iOS-only)

---

## 8. Open Questions & Risks

1. **BrowserStackTestHelper distribution**: How exactly is it distributed? CocoaPod? Manual framework download? SPM? This affects how users add it and how patrol conditionally imports it. Need to verify with BrowserStack documentation or test on their platform.

2. **`#if canImport` reliability**: Swift's `canImport` works at compile time. If BrowserStackTestHelper is a dynamic framework added only in CI, this may not work. Runtime reflection might be more robust but less type-safe.

3. **Async injection callback**: BrowserStack's `injectImage` uses a completion handler. The patrol server handlers are synchronous. Using `DispatchSemaphore` to bridge this works but needs careful handling to avoid deadlocks (must not block the main thread if the completion handler dispatches to main).

4. **`injector` lifecycle**: Is the `createInstance()` call safe to make multiple times? Should the injector be cached? Need to test on BrowserStack.

5. **Error handling**: What does BrowserStack return in the `response.toDictionary()` when injection fails? Need to handle error cases gracefully and propagate meaningful error messages back to Dart.
