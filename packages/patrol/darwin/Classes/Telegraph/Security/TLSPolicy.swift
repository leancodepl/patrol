//
//  TLSPolicy.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/30/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

open class TLSPolicy {
  public var commonName: String?
  public var certificates: [Certificate]

  /// Creates a policy that can check the common name and certificate chain.
  public init(commonName: String? = nil, certificates: [Certificate] = []) {
    self.commonName = commonName
    self.certificates = certificates
  }

  /// Evaluates the trust, returns a boolean indicating that it can be trusted or not.
  public func evaluate(trust: SecTrust) -> Bool {
    // Perform common name checks?
    if let commonName = commonName {
      let hostPolicy = SecPolicyCreateSSL(true, commonName.isEmpty ? nil : commonName as CFString)
      SecTrustSetPolicies(trust, hostPolicy)
    }

    // Perform certificate check?
    if !certificates.isEmpty {
      SecTrustSetAnchorCertificates(trust, certificates.map { $0.rawValue } as CFArray)
    }

    // Evaluate the trust
    var result: SecTrustResultType = .invalid
    SecTrustEvaluate(trust, &result)

    return result == .unspecified || result == .proceed
  }
}

// MARK: URLSession helper

public extension TLSPolicy {
  /// Evaluates the trust, returns a credential if it can be trusted or nil if not.
  func evaluateSession(trust: SecTrust?) -> URLCredential? {
    guard let trust = trust, evaluate(trust: trust) else { return nil }
    return URLCredential(trust: trust)
  }
}
