// Representation only. A real patrol_axe iOS pod would link the Deque
// `axeDevToolsXCUI` xcframework and be added to the UITest target.
//
// It implements core Patrol's `PatrolServerExtension` protocol. Core Patrol
// discovers it at runtime via the Objective-C runtime — no core change per
// package.

#if PATROL_ENABLED

  import Foundation
  import PatrolImpl  // provides PatrolServerExtension + PatrolRouteRegistrar
  // import axeDevToolsXCUI  // the real Deque SDK

  @objc(AxeServerExtension)
  public class AxeServerExtension: NSObject, PatrolServerExtension {
    public override required init() { super.init() }

    public var name: String { "patrol_axe" }

    public func register(on registrar: PatrolRouteRegistrar) {
      registrar.post("axeInitSession") { body in
        let req = try JSONDecoder().decode(AxeInitSessionRequest.self, from: body)
        AxeAutomator.shared.initSession(
          apiKey: req.dequeApiKey,
          projectId: req.dequeProjectId
        )
        return Data()
      }

      registrar.post("axeScan") { body in
        let req = try JSONDecoder().decode(AxeScanRequest.self, from: body)
        try AxeAutomator.shared.scan(
          uploadToDashboard: req.uploadToDashboard,
          tags: req.tags,
          scanName: req.scanName
        )
        return Data()
      }
    }
  }

  // Request models — represent patrol_gen output from schema/axe.dart.
  private struct AxeInitSessionRequest: Decodable {
    let dequeApiKey: String
    let dequeProjectId: String
  }

  private struct AxeScanRequest: Decodable {
    let uploadToDashboard: Bool
    let tags: [String]
    let scanName: String?
  }

  // Wraps the real Deque SDK (calls elided for the POC).
  final class AxeAutomator {
    static let shared = AxeAutomator()
    func initSession(apiKey: String, projectId: String) { /* AxeDevTools.startSession(...) */ }
    func scan(uploadToDashboard: Bool, tags: [String], scanName: String?) throws { /* axe.run(...) */ }
  }

#endif
