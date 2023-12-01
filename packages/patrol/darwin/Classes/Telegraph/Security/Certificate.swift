//
//  Certificate.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/26/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation
import Security

open class Certificate: RawRepresentable {
  public let rawValue: SecCertificate

  public required init(rawValue: SecCertificate) {
    self.rawValue = rawValue
  }

  public convenience init?(derData: Data) {
    guard let rawValue = SecCertificateCreateWithData(kCFAllocatorDefault, derData as CFData) else { return nil }
    self.init(rawValue: rawValue)
  }

  public convenience init?(derURL: URL) {
    guard let data = try? Data(contentsOf: derURL) else { return nil }
    self.init(derData: data)
  }
}

// MARK: Certificate information

public extension Certificate {
  var commonName: String? {
    return SecCertificateCopySubjectSummary(rawValue) as String?
  }
}

// MARK: Keychain helpers

public extension Certificate {
  convenience init(fromKeychain label: String) throws {
    self.init(rawValue: try KeychainManager.shared.find(kSecClassCertificate, label: label))
  }

  func addToKeychain(label: String) throws {
    try KeychainManager.shared.add(value: rawValue, label: label)
  }

  static func removeFromKeychain(label: String) throws {
    try KeychainManager.shared.remove(kSecClassCertificate, label: label)
  }
}
