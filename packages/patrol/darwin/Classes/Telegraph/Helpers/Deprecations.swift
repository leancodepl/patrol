//
//  Deprecations.swift
//  Telegraph
//
//  Created by Yvo van Beek on 11/9/18.
//  Copyright © 2018 Building42. All rights reserved.
//

import Foundation

// MARK: - DateFormatter

public extension DateFormatter {
  @available(*, deprecated, renamed: "rfc1123")
  var rfc7231: DateFormatter {
    return .rfc1123
  }
}

// MARK: - DispatchTimer

public extension DispatchTimer {
  /// Creates and starts a timer that runs after a while, optionally repeating with a specific interval.
  @available(*, deprecated, message: "no longer supported, use start(at:) to run the timer at a later time")
  static func run(after: TimeInterval, interval: TimeInterval = 0, queue: DispatchQueue, execute block: @escaping () -> Void) -> DispatchTimer {
    let timer = DispatchTimer(interval: interval, queue: queue, execute: block)
    timer.start(at: Date() + after)
    return timer
  }

  /// (Re)starts the timer, next run will be after the specified interval.
  @available(*, deprecated, message: "no longer supported, use start(at:) to run the timer at a later time")
  func start(after: TimeInterval) {
    start(at: Date() + after)
  }
}

// MARK: - FileManager

public extension FileManager {
  /// Provides the mime-type of the url based on the path extension.
  @available(*, deprecated, message: "use <url>.mimeType")
  func mimeType(of url: URL) -> String {
    return url.mimeType
  }
}

// MARK: - HTTPHeader

@available(*, deprecated, renamed: "HTTPHeaderName")
typealias HTTPHeader = HTTPHeaderName

@available(*, deprecated, message: "use Dictionary")
typealias CustomKeyIndexable = Dictionary

// MARK: - HTTPHeaderName

public extension HTTPHeaderName {
  @available(*, deprecated, message: "construct lower cased names manually")
  static var forceLowerCased = false
}

// MARK: - HTTPMethod

public extension HTTPMethod {
  @available(*, deprecated, renamed: "GET")
  static var get = HTTPMethod.GET

  @available(*, deprecated, renamed: "HEAD")
  static var head = HTTPMethod.HEAD

  @available(*, deprecated, renamed: "DELETE")
  static var delete = HTTPMethod.DELETE

  @available(*, deprecated, renamed: "OPTIONS")
  static var options = HTTPMethod.OPTIONS

  @available(*, deprecated, renamed: "POST")
  static var post = HTTPMethod.POST

  @available(*, deprecated, renamed: "PUT")
  static var put = HTTPMethod.PUT

  @available(*, deprecated, renamed: "init(name:)")
  init(rawValue: String) {
    self.init(name: rawValue.uppercased())
  }

  @available(*, deprecated, renamed: "init(name:)")
  static func method(_ name: String) -> HTTPMethod {
    return HTTPMethod(name: name)
  }
}

// MARK: - HTTPRouteError

@available(*, deprecated, message: "these specific errors are no longer thrown")
public enum HTTPRouteError: Error {
  case invalidURI
}

// MARK: - HTTPStatus

public extension HTTPStatus {
  @available(*, deprecated, message: "return nil from your handler (this status is used by Nginx, not part of the spec)")
  static let noResponse = HTTPStatus(code: 444, phrase: "No Response")
}

// MARK: - HTTPStatusCode

@available(*, deprecated, message: "use HTTPStatus, for example .ok or .notFound")
public typealias HTTPStatusCode = HTTPStatus

// MARK: - HTTPReponse

public extension HTTPResponse {
  @available(*, deprecated, message: "use DateFormatter.rfc1123 or Date's rfc1123 variable")
  static let dateFormatter = DateFormatter.rfc1123

  @available(*, deprecated, renamed: "init(status:data:)")
  convenience init(_ status: HTTPStatus = .ok, data: Data) {
    self.init(status, body: data)
  }

  @available(*, deprecated, message: "use keepAlive instead, this setter only handles true properly")
  var closeAfterWrite: Bool {
    get { return !keepAlive }
    set { if newValue { headers.connection = "close" } }
  }
}

// MARK: - HTTPVersion

public extension HTTPVersion {
  @available(*, deprecated, renamed: "init(major:minor:)")
  init(_ major: UInt, _ minor: UInt) {
    self.init(major: major, minor: minor)
  }
}

// MARK: - Server

public extension Server {
  @available(*, deprecated, renamed: "start(port:)")
  func start(onPort port: UInt16) throws {
    try start(port: Int(port))
  }

  @available(*, deprecated, renamed: "start(port:interface:)")
  func start(onInterface interface: String?, port: UInt16 = 0) throws {
    try start(port: Int(port), interface: interface)
  }

  @available(swift, obsoleted: 5, renamed: "responseFor(request:)")
  func handleIncoming(request: HTTPRequest) throws -> HTTPResponse? { return nil }

  @available(swift, obsoleted: 5, renamed: "responseFor(error:)")
  func handleIncoming(error: Error) throws -> HTTPResponse? { return nil }
}
