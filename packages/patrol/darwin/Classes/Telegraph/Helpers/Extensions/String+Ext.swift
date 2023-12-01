//
//  String+Ext.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/10/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public extension String {
  /// Generates a base64 encoded string of this String's contents.
  var base64: String {
    return utf8Data.base64EncodedString()
  }

  /// The character bytes in UTF8 encoding.
  var utf8Data: Data {
    return data(using: .utf8)!
  }

  /// Truncates a string and optionally adds ellipses.
  func truncate(count: Int, ellipses: Bool = true) -> String {
    if self.count <= count { return self }
    return prefix(count) + (ellipses ? "..." : "")
  }
}
