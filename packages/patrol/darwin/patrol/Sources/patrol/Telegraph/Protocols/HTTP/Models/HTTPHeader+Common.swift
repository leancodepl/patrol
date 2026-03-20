//
//  HTTPHeader+Common.swift
//  Telegraph
//
//  Created by Yvo van Beek on 7/3/19.
//  Copyright © 2019 Building42. All rights reserved.
//

import Foundation

extension HTTPHeaderName {
  public static let accept = HTTPHeaderName("Accept")
  public static let acceptCharset = HTTPHeaderName("Accept-Charset")
  public static let acceptEncoding = HTTPHeaderName("Accept-Encoding")
  public static let acceptLanguage = HTTPHeaderName("Accept-Language")
  public static let acceptRanges = HTTPHeaderName("Accept-Ranges")
  public static let accessControlAllowOrigin = HTTPHeaderName("Access-Control-Allow-Origin")
  public static let accessControlAllowHeaders = HTTPHeaderName("Access-Control-Allow-Headers")
  public static let accessControlAllowMethods = HTTPHeaderName("Access-Control-Allow-Methods")
  public static let accessControlMaxAge = HTTPHeaderName("Access-Control-Max-Age")
  public static let age = HTTPHeaderName("Age")
  public static let allow = HTTPHeaderName("Allow")
  public static let authorization = HTTPHeaderName("Authorization")
  public static let cacheControl = HTTPHeaderName("Cache-Control")
  public static let connection = HTTPHeaderName("Connection")
  public static let cookie = HTTPHeaderName("Cookie")
  public static let contentDisposition = HTTPHeaderName("Content-Disposition")
  public static let contentEncoding = HTTPHeaderName("Content-Encoding")
  public static let contentLanguage = HTTPHeaderName("Content-Language")
  public static let contentLength = HTTPHeaderName("Content-Length")
  public static let contentRange = HTTPHeaderName("Content-Range")
  public static let contentType = HTTPHeaderName("Content-Type")
  public static let date = HTTPHeaderName("Date")
  public static let eTag = HTTPHeaderName("ETag")
  public static let expect = HTTPHeaderName("Expect")
  public static let expires = HTTPHeaderName("Expires")
  public static let forwarded = HTTPHeaderName("Forwarded")
  public static let host = HTTPHeaderName("Host")
  public static let ifModifiedSince = HTTPHeaderName("If-Modified-Since")
  public static let lastModified = HTTPHeaderName("Last-Modified")
  public static let location = HTTPHeaderName("Location")
  public static let origin = HTTPHeaderName("Origin")
  public static let pragma = HTTPHeaderName("Pragma")
  public static let range = HTTPHeaderName("Range")
  public static let referer = HTTPHeaderName("Referer")
  public static let refresh = HTTPHeaderName("Refresh")
  public static let server = HTTPHeaderName("Server")
  public static let setCookie = HTTPHeaderName("Set-Cookie")
  public static let strictTransportSecurity = HTTPHeaderName("Strict-Transport-Security")
  public static let transferEncoding = HTTPHeaderName("Transfer-Encoding")
  public static let userAgent = HTTPHeaderName("User-Agent")
  public static let upgrade = HTTPHeaderName("Upgrade")
}

extension Dictionary where Key == HTTPHeaderName, Value == String {
  public var accept: String? {
    get { return self[.accept] }
    set { self[.accept] = newValue }
  }

  public var acceptCharset: String? {
    get { return self[.acceptCharset] }
    set { self[.acceptCharset] = newValue }
  }

  public var acceptEncoding: String? {
    get { return self[.acceptEncoding] }
    set { self[.acceptEncoding] = newValue }
  }

  public var acceptLanguage: String? {
    get { return self[.acceptLanguage] }
    set { self[.acceptLanguage] = newValue }
  }

  public var acceptRanges: String? {
    get { return self[.acceptRanges] }
    set { self[.acceptRanges] = newValue }
  }

  public var accessControlAllowOrigin: String? {
    get { return self[.accessControlAllowOrigin] }
    set { self[.accessControlAllowOrigin] = newValue }
  }

  public var accessControlAllowHeaders: String? {
    get { return self[.accessControlAllowHeaders] }
    set { self[.accessControlAllowHeaders] = newValue }
  }

  public var accessControlAllowMethods: String? {
    get { return self[.accessControlAllowMethods] }
    set { self[.accessControlAllowMethods] = newValue }
  }

  public var accessControlMaxAge: String? {
    get { return self[.accessControlMaxAge] }
    set { self[.accessControlMaxAge] = newValue }
  }

  public var age: String? {
    get { return self[.age] }
    set { self[.age] = newValue }
  }

  public var allow: String? {
    get { return self[.allow] }
    set { self[.allow] = newValue }
  }

  public var authorization: String? {
    get { return self[.authorization] }
    set { self[.authorization] = newValue }
  }

  public var cacheControl: String? {
    get { return self[.cacheControl] }
    set { self[.cacheControl] = newValue }
  }

  public var connection: String? {
    get { return self[.connection] }
    set { self[.connection] = newValue }
  }

  public var cookie: String? {
    get { return self[.cookie] }
    set { self[.cookie] = newValue }
  }

  public var contentDisposition: String? {
    get { return self[.contentDisposition] }
    set { self[.contentDisposition] = newValue }
  }

  public var contentEncoding: String? {
    get { return self[.contentEncoding] }
    set { self[.contentEncoding] = newValue }
  }

  public var contentLanguage: String? {
    get { return self[.contentLanguage] }
    set { self[.contentLanguage] = newValue }
  }

  public var contentLength: Int? {
    get { return Int(self[.contentLength] ?? "") }
    set { self[.contentLength] = newValue == nil ? nil : "\(newValue!)" }
  }

  public var contentRange: String? {
    get { return self[.contentRange] }
    set { self[.contentRange] = newValue }
  }

  public var contentType: String? {
    get { return self[.contentType] }
    set { self[.contentType] = newValue }
  }

  public var date: String? {
    get { return self[.date] }
    set { self[.date] = newValue }
  }

  public var eTag: String? {
    get { return self[.eTag] }
    set { self[.eTag] = newValue }
  }

  public var expect: String? {
    get { return self[.expect] }
    set { self[.expect] = newValue }
  }

  public var expires: String? {
    get { return self[.expires] }
    set { self[.expires] = newValue }
  }

  public var forwarded: String? {
    get { return self[.forwarded] }
    set { self[.forwarded] = newValue }
  }

  public var host: String? {
    get { return self[.host] }
    set { self[.host] = newValue }
  }

  public var ifModifiedSince: String? {
    get { return self[.ifModifiedSince] }
    set { self[.ifModifiedSince] = newValue }
  }

  public var lastModified: String? {
    get { return self[.lastModified] }
    set { self[.lastModified] = newValue }
  }

  public var location: String? {
    get { return self[.location] }
    set { self[.location] = newValue }
  }

  public var origin: String? {
    get { return self[.origin] }
    set { self[.origin] = newValue }
  }

  public var pragma: String? {
    get { return self[.pragma] }
    set { self[.pragma] = newValue }
  }

  public var range: String? {
    get { return self[.range] }
    set { self[.range] = newValue }
  }

  public var referer: String? {
    get { return self[.referer] }
    set { self[.referer] = newValue }
  }

  public var refresh: String? {
    get { return self[.refresh] }
    set { self[.refresh] = newValue }
  }

  public var server: String? {
    get { return self[.server] }
    set { self[.server] = newValue }
  }

  public var setCookie: String? {
    get { return self[.setCookie] }
    set { self[.setCookie] = newValue }
  }

  public var strictTransportSecurity: String? {
    get { return self[.strictTransportSecurity] }
    set { self[.strictTransportSecurity] = newValue }
  }

  public var transferEncoding: String? {
    get { return self[.transferEncoding] }
    set { self[.transferEncoding] = newValue }
  }

  public var userAgent: String? {
    get { return self[.userAgent] }
    set { self[.userAgent] = newValue }
  }

  public var upgrade: String? {
    get { return self[.upgrade] }
    set { self[.upgrade] = newValue }
  }
}
