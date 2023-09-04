#if PATROL_ENABLED
  import XCTest

  class Automator {
      private var timeout: TimeInterval = 10

      func configure(timeout: TimeInterval) {
          self.timeout = timeout
      }
      
      func openApp(_ bundleId: String) async throws {
           try await runAction("opening app with id \(bundleId)") {
             let app = try self.getApp(withBundleId: bundleId)
             app.activate()
           }
         }
      
      private func getApp(withBundleId bundleId: String) throws -> XCUIApplication {
           let app = XCUIApplication(bundleIdentifier: bundleId)
           // TODO: Doesn't work
           // See https://stackoverflow.com/questions/73976961/how-to-check-if-any-app-is-installed-during-xctest
           // guard app.exists else {
           //   throw PatrolError.appNotInstalled(bundleId)
           // }

           return app
         }
      
      private func runAction<T>(_ log: String, block: @escaping () throws -> T) async rethrows -> T {
           return try await MainActor.run {
             Logger.shared.i("\(log)...")
             let result = try block()
             Logger.shared.i("done \(log)")
             Logger.shared.i("result: \(result)")
             return result
           }
         }
  }

#endif
