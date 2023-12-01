//
//  URL+Ext.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/10/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public extension URL {
  /// Indicates if the URL has a https, http, wss or ws scheme.
  var hasWebSocketScheme: Bool {
    return scheme == "https" || scheme == "http" || scheme == "wss" || scheme == "ws"
  }

  /// A simple port determination based on the scheme, 443 for HTTPS and 80 for HTTP.
  var portBasedOnScheme: Int {
    return isSchemeSecure ? 443 : 80
  }

  /// Indicates if the scheme is HTTPS or WSS.
  var isSchemeSecure: Bool {
    return scheme == "https" || scheme == "wss"
  }
}

public extension URL {
  /// Provides the mime-type of the url based on the path extension.
  var mimeType: String {
    return FileManager.default.mimeType(pathExtension: pathExtension)
  }
}
