//
//  URL+Ext.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/10/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

extension URL {
  /// Indicates if the URL has a https, http, wss or ws scheme.
  public var hasWebSocketScheme: Bool {
    return scheme == "https" || scheme == "http" || scheme == "wss" || scheme == "ws"
  }

  /// A simple port determination based on the scheme, 443 for HTTPS and 80 for HTTP.
  public var portBasedOnScheme: Int {
    return isSchemeSecure ? 443 : 80
  }

  /// Indicates if the scheme is HTTPS or WSS.
  public var isSchemeSecure: Bool {
    return scheme == "https" || scheme == "wss"
  }
}

extension URL {
  /// Provides the mime-type of the url based on the path extension.
  public var mimeType: String {
    return FileManager.default.mimeType(pathExtension: pathExtension)
  }
}
