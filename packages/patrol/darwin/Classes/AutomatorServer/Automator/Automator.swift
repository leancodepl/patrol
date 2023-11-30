#if PATROL_ENABLED
  import XCTest
  import os

  protocol Automator {
    func configure(timeout: TimeInterval)
    func openApp(_ bundleId: String) throws
  }

#endif
