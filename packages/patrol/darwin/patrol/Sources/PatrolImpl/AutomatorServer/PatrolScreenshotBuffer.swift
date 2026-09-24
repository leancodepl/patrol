#if PATROL_ENABLED && os(iOS)

  import XCTest

  /// Collects on-demand screenshots (`$.takeNativeScreenshot(...)`) taken while a
  /// Dart test runs, so the runner can attach them to that test's `.xcresult`.
  ///
  /// The automation server handles requests on a background thread, but XCTest
  /// attachments must be added from the test method. So the automator captures
  /// the image and parks it here; the runner drains the buffer on the test
  /// thread once the Dart test finishes (see PatrolIntegrationTestIosRunner.h).
  @objc(PatrolScreenshotBuffer) public class PatrolScreenshotBuffer: NSObject {
    @objc public static let sharedBuffer = PatrolScreenshotBuffer()

    private let lock = NSLock()
    private var pending: [(name: String, screenshot: XCUIScreenshot)] = []

    private override init() {
      super.init()
    }

    /// Parks a captured [screenshot] under [name] for later attachment.
    func add(name: String, screenshot: XCUIScreenshot) {
      lock.lock()
      defer { lock.unlock() }
      pending.append((name: name, screenshot: screenshot))
    }

    /// Attaches every parked screenshot to [testCase] and clears the buffer.
    @objc public func drainAttaching(to testCase: XCTestCase) {
      lock.lock()
      let items = pending
      pending.removeAll()
      lock.unlock()

      for item in items {
        let attachment = XCTAttachment(screenshot: item.screenshot)
        attachment.name = item.name
        attachment.lifetime = .keepAlways
        testCase.add(attachment)
      }
    }

    /// Captures the current device screen and attaches it to [testCase] under
    /// [name]. Used on failure paths (e.g. the app never reports readiness)
    /// where the Dart test never runs, so no `failure` screenshot is buffered
    /// but the on-screen state still explains what went wrong.
    // Explicit selector: Swift would export `attachCurrentScreenWithNamed:to:`.
    @objc(attachCurrentScreenNamed:to:)
    public static func attachCurrentScreen(named name: String, to testCase: XCTestCase) {
      let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
      attachment.name = name
      attachment.lifetime = .keepAlways
      testCase.add(attachment)
    }
  }

#endif
