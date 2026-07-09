#if PATROL_ENABLED

  import Foundation
  import XCTest
  import axeDevToolsXCUI

  final class AxeAutomator {
    static let shared = AxeAutomator()

    private var axe: AxeDevTools?

    func initSession(apiKey: String, projectId: String) throws {
      axe = try AxeDevTools.startSession(apiKey: apiKey, projectId: projectId)
    }

    func scan(uploadToDashboard: Bool, tags: [String], scanName: String?) throws {
      guard let axe else {
        throw AxeAutomatorError.sessionNotInitialized
      }

      let result = try axe.run(onElement: XCUIApplication())
      if uploadToDashboard {
        _ = try AxeBridge.postResult(
          on: axe,
          result: result,
          tags: tags,
          scanName: scanName
        )
      }
    }

    func ignoreRules(_ rulesToIgnore: [String]) {
      axe?.configuration.ignore(rules: rulesToIgnore)
    }

    func ignoreByViewIdResourceName(
      viewIdResourceName: String,
      ruleList: [String]
    ) {
      axe?.configuration.ignore(rulesFor: [viewIdResourceName: Set(ruleList)])
    }

    func ignoreExperimental() {
      axe?.configuration.ignoreExperimental()
    }
  }

  enum AxeAutomatorError: Error, LocalizedError {
    case sessionNotInitialized

    var errorDescription: String? {
      switch self {
      case .sessionNotInitialized:
        return "axe session is not initialized; call initSession first"
      }
    }
  }

#endif
