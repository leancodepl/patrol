//
//  URI.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/5/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public struct URI: Hashable, Equatable {
  private var components: URLComponents

  /// Creates a URI from the provided path and query string.
  public init(path: String = "/", query: String? = nil) {
    self.components = URLComponents()
    self.components.path = path
    self.components.query = query
  }

  /// Creates a URI from URLComponents.
  public init(components: URLComponents) {
    self.components = URLComponents()
    self.components.percentEncodedPath = components.percentEncodedPath
    self.components.percentEncodedQuery = components.percentEncodedQuery
  }

  /// Creates a URI from the provided URL.
  public init?(url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
    self.init(components: components)
  }

  /// Creates a URI from the provided string.
  public init?(_ string: String) {
    guard let components = URLComponents(string: string) else { return nil }
    self.init(components: components)
  }
}

public extension URI {
  /// The path of the URI. Always starts with a slash.
  var path: String {
    get { return components.path.ensurePrefix("/") }
    set { components.path = newValue }
  }

  /// The query string of the URI.
  var query: String? {
    get { return components.query }
    set { components.query = newValue }
  }

  /// The query string items of the URI as an array.
  var queryItems: [URLQueryItem]? {
    get { return components.queryItems }
    set { components.queryItems = newValue }
  }
}

public extension URI {
  /// Creates a URI from the provided percent encoded path and query string.
  init(percentEncodedPath: String, percentEncodedQuery: String? = nil) {
    self.components = URLComponents()
    self.components.percentEncodedPath = percentEncodedPath
    self.components.percentEncodedQuery = percentEncodedQuery
  }

  /// The path of the URI percent encoded.
  var percentEncodedPath: String {
    get { return components.percentEncodedPath.ensurePrefix("/") }
    set { components.percentEncodedPath = newValue }
  }

  /// The query string of the URI percent encoded.
  var percentEncodedQuery: String? {
    get { return components.percentEncodedQuery }
    set { components.percentEncodedQuery = newValue }
  }

  /// A string representing the entire URI.
  var string: String {
    guard let encodedQuery = percentEncodedQuery else { return percentEncodedPath }
    return percentEncodedPath + "?" + encodedQuery
  }
}

public extension URI {
  /// Returns a URI indicating the root.
  static let root = URI(path: "/")

  /// Returns the part of the path that doesn't overlap.
  /// For example '/files/today' with argument '/files' returns 'today'.
  func relativePath(from path: String) -> String? {
    var result = self.path

    // Remove the part of the path that overlaps
    guard let range = result.range(of: path) else { return nil }
    result = result.replacingCharacters(in: range, with: "")

    // Remove leading slash
    if result.hasPrefix("/") { result.remove(at: result.startIndex) }

    return result
  }
}

extension URI: CustomStringConvertible {
  public var description: String {
    return self.string
  }
}

private extension String {
  /// Ensures that this String has a specific prefix.
  func ensurePrefix(_ prefix: String) -> String {
    if hasPrefix(prefix) { return self }
    return prefix + self
  }
}
