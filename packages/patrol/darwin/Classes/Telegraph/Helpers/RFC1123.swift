//
//  RFC1123.swift
//  Telegraph
//
//  Created by Yvo van Beek on 8/3/18.
//  Copyright © 2018 Building42. All rights reserved.
//

import Foundation

public struct RFC1123 {
  /// A shared RFC1123 DateFormatter (thread-safe since iOS 7 and macOS 10.9).
  public static var formatter = DateFormatter.rfc1123
}

public extension DateFormatter {
  /// Creates a new RFC1123 DateFormatter.
  static var rfc1123: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }
}

public extension Date {
  /// Returns the date formatted as RFC1123.
  var rfc1123: String {
    return RFC1123.formatter.string(from: self)
  }
}
