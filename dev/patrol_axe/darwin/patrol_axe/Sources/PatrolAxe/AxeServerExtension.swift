#if PATROL_ENABLED

  import Foundation

  #if canImport(PatrolImpl)
    import PatrolImpl
  #else
    import patrol
  #endif

  @objc(AxeServerExtension)
  public class AxeServerExtension: NSObject, PatrolServerExtension {
    public override required init() { super.init() }

    public var name: String { "patrol_axe" }

    public func register(on registrar: PatrolRouteRegistrar) {
      registrar.post("axeInitSession") { body in
        let req = try JSONDecoder().decode(AxeInitSessionRequest.self, from: body)
        try AxeAutomator.shared.initSession(apiKey: req.dequeApiKey, projectId: req.dequeProjectId)
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

      registrar.post("axeIgnoreRules") { body in
        let req = try JSONDecoder().decode(AxeIgnoreRulesRequest.self, from: body)
        AxeAutomator.shared.ignoreRules(req.rulesToIgnore)
        return Data()
      }

      registrar.post("axeIgnoreByViewIdResourceName") { body in
        let req = try JSONDecoder().decode(AxeIgnoreByViewIdResourceNameRequest.self, from: body)
        AxeAutomator.shared.ignoreByViewIdResourceName(
          viewIdResourceName: req.viewIdResourceName,
          ruleList: req.ruleList
        )
        return Data()
      }

      registrar.post("axeIgnoreExperimental") { _ in
        AxeAutomator.shared.ignoreExperimental()
        return Data()
      }
    }
  }

  private struct AxeInitSessionRequest: Decodable {
    let dequeApiKey: String
    let dequeProjectId: String
  }

  private struct AxeScanRequest: Decodable {
    let uploadToDashboard: Bool
    let tags: [String]
    let scanName: String?
  }

  private struct AxeIgnoreRulesRequest: Decodable {
    let rulesToIgnore: [String]
  }

  private struct AxeIgnoreByViewIdResourceNameRequest: Decodable {
    let viewIdResourceName: String
    let ruleList: [String]
  }

#endif
