//
//  CertificateIdentity.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/26/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

open class CertificateIdentity: RawRepresentable {
  public let rawValue: SecIdentity

  /// Initializes a new CertificateIdentity instance.
  public required init(rawValue: SecIdentity) {
    self.rawValue = rawValue
  }

  /// Creates a CertificateIdentity by importing PCKS12 data.
  public convenience init?(p12Data: Data, passphrase: String) {
    guard let rawValue = KeychainManager.shared.importPKCS12(data: p12Data, passphrase: passphrase) else { return nil }
    self.init(rawValue: rawValue)
  }

  /// Creates a CertificateIdentity by importing PCKS12 data from the provided url.
  public convenience init?(p12URL: URL, passphrase: String) {
    guard let data = try? Data(contentsOf: p12URL) else { return nil }
    self.init(p12Data: data, passphrase: passphrase)
  }
}

// MARK: Keychain helpers

public extension CertificateIdentity {
  convenience init(fromKeychain label: String) throws {
    self.init(rawValue: try KeychainManager.shared.find(kSecClassIdentity, label: label))
  }

  func addToKeychain(label: String) throws {
    try KeychainManager.shared.add(value: rawValue, label: label)
  }

  static func removeFromKeychain(label: String) throws {
    try KeychainManager.shared.remove(kSecClassIdentity, label: label)
  }
}

// MARK: Optional passphrases (passphrases are required on MacOS)

#if os(iOS) || os(watchOS) || os(tvOS)

  public extension CertificateIdentity {
    /// Creates a CertificateIdentity by importing PCKS12 data, without passphrase.
    convenience init?(p12Data: Data) {
      self.init(p12Data: p12Data, passphrase: "")
    }

    /// Creates a CertificateIdentity by importing PCKS12 data from the provided url, without passphrase.
    convenience init?(p12URL: URL) {
      self.init(p12URL: p12URL, passphrase: "")
    }
  }

#endif
