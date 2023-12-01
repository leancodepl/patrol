//
//  HTTPRoute.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/4/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public struct HTTPRoute {
  public let methods: Set<HTTPMethod>?
  public let handler: HTTPRequest.Handler

  public let regex: Regex?
  public let params: [HTTPRequest.Params.Key]

  /// Creates a new HTTPRoute based on a regular expression pattern.
  public init(methods: Set<HTTPMethod>? = nil, regex pattern: String? = nil, handler: @escaping HTTPRequest.Handler) throws {
    self.methods = methods
    self.handler = handler

    let (regex, params) = try HTTPRoute.regexAndParams(pattern: pattern)
    self.regex = regex
    self.params = params
  }

  /// Creates a new HTTPRoute based on a URI.
  public init(methods: Set<HTTPMethod>? = nil, uri: String, handler: @escaping HTTPRequest.Handler) throws {
    let pattern = try HTTPRoute.routePattern(basedOn: uri)
    try self.init(methods: methods, regex: pattern, handler: handler)
  }
}

// MARK: Route pattern processing

private extension HTTPRoute {
  /// The regular expression to extract parameters definitions.
  static let parameterRegex = try! Regex(pattern: #":([\w]+)"#)

  /// The regular expression replacement pattern to capture parameters.
  static let parameterCaptureGroupPattern: String = {
    if #available(iOS 9, *) {
      return #"(?<$1>[^\/]+)"#
    } else {
      return #"([^\/]+)"#
    }
  }()

  /// Breaks a route regular expression up into the regular expression that will be used
  /// for matching routes and a list of path parameters.
  static func regexAndParams(pattern: String?) throws -> (Regex?, [String]) {
    // If no regex is specified this route will match all uris
    guard var pattern = pattern else { return (nil, []) }

    // Extract the route parameters, for example /user/:id and change them to capture groups
    let params = parameterRegex.matchAll(in: pattern).flatMap { $0.groupValues }
    pattern = parameterRegex.stringByReplacingMatches(in: pattern, withPattern: parameterCaptureGroupPattern)

    return (try Regex(pattern: pattern, options: .caseInsensitive), params)
  }

  /// Creates a route regular expression pattern based on the provided URI.
  static func routePattern(basedOn uri: String) throws -> String {
    // Clean up invalid paths
    var pattern = URI(path: uri).path

    // Allow easy optional slash pattern, for example /hello(/)
    pattern = pattern.replacingOccurrences(of: "(/)", with: "/?")

    // Limit what the regex will match by fixating the start and the end
    if !pattern.hasPrefix("^") { pattern.insert("^", at: pattern.startIndex) }
    if !pattern.hasSuffix("*") { pattern.insert("$", at: pattern.endIndex) }

    return pattern
  }
}

// MARK: Route handling

public extension HTTPRoute {
  /// Indicates if the route supports the provided HTTP method.
  func canHandle(method: HTTPMethod) -> Bool {
    guard let methods = methods else { return true }
    return methods.contains(method)
  }

  /// Indicates if the route matches the provided path. Any route parameters will be extracted
  /// and returned as a separate list.
  func canHandle(path: String) -> (Bool, HTTPRequest.Params) {
    // Should we allow all patterns?
    guard let routeRegex = regex else { return (true, [:]) }

    // Test if the URI matches our route
    let matches = routeRegex.matchAll(in: path)
    if matches.isEmpty { return (false, [:]) }

    // If the URI matches our route, extract the params
    var routeParams = HTTPRequest.Params()
    let matchedParams = matches.flatMap { $0.groupValues }

    // Create a dictionary of parameter : parameter value
    for (key, value) in zip(params, matchedParams) {
      routeParams[key] = value
    }

    return (true, routeParams)
  }
}
