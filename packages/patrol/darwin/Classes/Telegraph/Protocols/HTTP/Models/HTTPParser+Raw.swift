//
//  HTTPParser+Raw.swift
//  Telegraph
//
//  Created by Yvo van Beek on 10/12/18.
//  Copyright © 2018 Building42. All rights reserved.
//

// import HTTPParserC

// MARK: Types

typealias HTTPRawParser = http_parser
typealias HTTPRawParserSettings = http_parser_settings
typealias HTTPRawParserErrorCode = http_errno
typealias ChunkPointer = UnsafePointer<Int8>

// MARK: HTTPRawParser

extension HTTPRawParser {
  /// Creates a new HTTPRawParser.
  static func make() -> HTTPRawParser {
    var parser = HTTPRawParser()
    http_parser_init(&parser, HTTP_BOTH)
    return parser
  }

  /// Parses the incoming data and returns how many bytes were parsed.
  static func parse(
    parser: UnsafeMutablePointer<HTTPRawParser>,
    settings: UnsafeMutablePointer<HTTPRawParserSettings>, data: Data
  ) -> Int {
    return data.withUnsafeBytes {
      let pointer = $0.bindMemory(to: Int8.self).baseAddress
      return http_parser_execute(parser, settings, pointer, data.count)
    }
  }

  /// Resets the parser.
  static func reset(parser: UnsafeMutablePointer<HTTPRawParser>) {
    http_parser_init(parser, HTTP_BOTH)
  }

  /// Returns the context.
  func context<T: AnyObject>() -> T {
    return Unmanaged<T>.fromOpaque(data).takeUnretainedValue()
  }

  /// Sets the context.
  mutating func setContext<T: AnyObject>(_ context: T) {
    data = Unmanaged.passUnretained(context).toOpaque()
  }
}

extension HTTPRawParser {
  /// Returns the content length header.
  var contentLength: Int {
    return content_length > Int.max ? 0 : Int(content_length)
  }

  /// Returns the error that occurred during parsing.
  var httpError: HTTPError? {
    if http_errno == HPE_OK.rawValue { return nil }
    return HTTPError(code: HTTPRawParserErrorCode(http_errno))
  }

  /// Returns the HTTP method.
  var httpMethod: HTTPMethod {
    let methodCode = http_method(method)
    let methodName = String(cString: http_method_str(methodCode))
    return HTTPMethod(name: methodName)
  }

  /// Returns the HTTP status.
  var httpStatusCode: Int {
    return Int(status_code)
  }

  /// Returns the HTTP version.
  var httpVersion: HTTPVersion {
    return HTTPVersion(major: UInt(http_major), minor: UInt(http_minor))
  }

  /// Returns a boolean indicating if the parser is parsing a HTTP request.
  var isParsingRequest: Bool {
    return type == HTTP_REQUEST.rawValue
  }

  /// Returns a boolean indicating if the parser is parsing a HTTP request.
  var isParsingResponse: Bool {
    return type == HTTP_RESPONSE.rawValue
  }

  /// Returns a boolean indicating if the parser is ready to parse.
  var isReady: Bool {
    return http_errno == HPE_OK.rawValue
  }

  /// Returns a boolean indicating if the status has been fully parsed.
  var isStatusComplete: Bool {
    return state >= 16
  }

  /// Returns a boolean indicating if the parser detected a connection upgrade.
  var isUpgradeDetected: Bool {
    return upgrade == 1
  }

  /// Returns a boolean indicating if the URL has been fully parsed.
  var isURLComplete: Bool {
    return state >= 31
  }
}

// MARK: HTTPRawParserSettings

extension HTTPRawParserSettings {
  /// Creates a new HTTPRawParserSettings.
  static func make() -> HTTPRawParserSettings {
    var settings = HTTPRawParserSettings()
    http_parser_settings_init(&settings)
    return settings
  }
}

// MARK: RawParserErrorCode to HTTPError mapping

extension HTTPError {
  init(code: HTTPRawParserErrorCode) {
    switch code {
    case HPE_INVALID_EOF_STATE:
      self = .unexpectedStreamEnd
    case HPE_CLOSED_CONNECTION:
      self = .connectionShouldBeClosed
    case HPE_INVALID_VERSION:
      self = .invalidVersion
    case HPE_INVALID_METHOD:
      self = .invalidMethod
    case HPE_INVALID_URL, HPE_INVALID_HOST, HPE_INVALID_PORT, HPE_INVALID_PATH,
      HPE_INVALID_QUERY_STRING, HPE_INVALID_FRAGMENT:
      self = .invalidURI
    case HPE_INVALID_HEADER_TOKEN:
      self = .invalidHeader
    case HPE_INVALID_CONTENT_LENGTH:
      self = .invalidContentLength
    case HPE_HEADER_OVERFLOW:
      self = .headerOverflow
    default:
      self = .parseFailed(code: Int(code.rawValue))
    }
  }
}
