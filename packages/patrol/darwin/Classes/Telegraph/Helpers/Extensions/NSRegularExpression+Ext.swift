//
//  NSRegularExpression+Ext.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/5/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public typealias Regex = NSRegularExpression

// MARK: Regex default arguments

extension NSRegularExpression {
  func firstMatch(in value: String, options: Regex.MatchingOptions = []) -> NSTextCheckingResult? {
    return firstMatch(in: value, options: options, range: value.fullRange)
  }

  func matches(value: String) -> Bool {
    return firstMatch(in: value) != nil
  }

  func matches(in value: String, options: Regex.MatchingOptions = []) -> [NSTextCheckingResult] {
    return matches(in: value, options: options, range: value.fullRange)
  }

  func stringByReplacingMatches(in value: String, withPattern pattern: String, options: Regex.MatchingOptions = []) -> String {
    return stringByReplacingMatches(in: value, options: options, range: value.fullRange, withTemplate: pattern)
  }
}

// MARK: Regex simple matching

struct RegexMatch {
  let value: String
  let groupValues: [String]

  init(input: String, result: NSTextCheckingResult) {
    value = input.substring(with: result.range) ?? ""
    groupValues = (1..<result.numberOfRanges).compactMap { input.substring(with: result.range(at: $0)) }
  }
}

extension NSRegularExpression {
  func matchAll(in value: String, options: Regex.MatchingOptions = []) -> [RegexMatch] {
    return matches(in: value, options: options).map { RegexMatch(input: value, result: $0) }
  }
}

// MARK: String helpers

private extension String {
  var fullRange: NSRange {
    return NSRange(location: 0, length: count)
  }

  func substring(with range: NSRange) -> String? {
    guard let range = Range(range) else { return nil }
    let from = index(startIndex, offsetBy: range.lowerBound)
    let to = index(startIndex, offsetBy: range.upperBound)
    return String(self[from..<to])
  }
}
