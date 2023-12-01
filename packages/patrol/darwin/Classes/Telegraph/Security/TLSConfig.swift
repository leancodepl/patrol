//
//  TLSConfig.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/7/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public struct TLSConfig {
  public let identity: CertificateIdentity?
  public let certificates: [Certificate]

  public init(serverIdentity: CertificateIdentity, caCertificates: [Certificate]) {
    self.identity = serverIdentity
    self.certificates = caCertificates
  }

  public init(clientCertificates: [Certificate] = []) {
    self.identity = nil
    self.certificates = clientCertificates
  }
}

// MARK: CFNetwork raw config

extension TLSConfig {
  internal var rawConfig: [String: NSObject] {
    var rawConfig = [String: NSObject]()
    var isServerSide = false

    // Convert the certificates
    var allCertificates = certificates.map { $0.rawValue as AnyObject }

    // If an identity is set, insert it as the first one
    if let identity = identity {
      allCertificates.insert(identity.rawValue, at: 0)
      isServerSide = true
    }

    // Set the certificate
    if !allCertificates.isEmpty {
      rawConfig[kCFStreamSSLCertificates as String] = allCertificates as CFArray
    }

    // Inform TLS if we are server or client side
    rawConfig[kCFStreamSSLIsServer as String] = isServerSide as CFBoolean

    return rawConfig
  }
}
