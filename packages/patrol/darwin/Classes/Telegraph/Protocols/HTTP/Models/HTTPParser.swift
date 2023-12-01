//
//  HTTPParser.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/31/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

// MARK: Constants

private let continueParsing: Int32 = 0
private let stopParsing: Int32 = -1

// MARK: HTTPParser

public final class HTTPParser {
  public private(set) var message: HTTPMessage?
  public private(set) var isMessageComplete = false
  public var isUpgradeDetected: Bool { return rawParser.isUpgradeDetected }

  private var request: HTTPRequest? { return message as? HTTPRequest }
  private var response: HTTPResponse? { return message as? HTTPResponse }

  private var rawParser: HTTPRawParser
  private var rawParserSettings: HTTPRawParserSettings

  private var urlData = Data()
  private var statusData = Data()
  private var headerKeyData = Data()
  private var headerValueData = Data()
  private var headerChunkWasValue = false

  /// Creates an HTTP parser.
  public init() {
    rawParser = HTTPRawParser.make()
    rawParserSettings = HTTPRawParserSettings.make()

    // Attach ourself as the context of the raw parser
    rawParser.setContext(self)

    // Provide the callback for when the parser is starting a new message.
    rawParserSettings.on_message_begin = { rawParserPointer in
      parserCall(rawParserPointer) { $0.parserDidBeginMessage($1) }
    }

    // Provide the callback for when the parser is parsing chunks of the URL.
    rawParserSettings.on_url = { rawParserPointer, chunk, count in
      parserCall(rawParserPointer) { $0.parserDidParseURL($1, chunk: chunk, count: count) }
    }

    // Provide the callback for when the parser is parsing chunks of the HTTP status.
    rawParserSettings.on_status = { rawParserPointer, chunk, count in
      parserCall(rawParserPointer) { $0.parserDidParseStatus($1, chunk: chunk, count: count) }
    }

    // Provide the callback for when the parser is parsing chunks of the header key.
    rawParserSettings.on_header_field = { rawParserPointer, chunk, count in
      parserCall(rawParserPointer) { $0.parserDidParseHeaderField($1, chunk: chunk, count: count) }
    }

    // Provide the callback for when the parser is parsing chunks of the header key.
    rawParserSettings.on_header_value = { rawParserPointer, chunk, count in
      parserCall(rawParserPointer) { $0.parserDidParseHeaderValue($1, chunk: chunk, count: count) }
    }

    // Provide the callback for when the parser is done parsing the headers.
    rawParserSettings.on_headers_complete = { rawParserPointer in
      parserCall(rawParserPointer) { $0.parserDidCompleteHeaders($1) }
    }

    // Provide the callback for when the parser is parsing chunks of the body.
    rawParserSettings.on_body = { rawParserPointer, chunk, count in
      parserCall(rawParserPointer) { $0.parserDidParseBody($1, chunk: chunk, count: count) }
    }

    /// Provide the callback for when the parser is done parsing a whole message.
    rawParserSettings.on_message_complete = { rawParserPointer in
      parserCall(rawParserPointer) { $0.parserDidCompleteMessage($1) }
    }
  }

  /// Parses the incoming data and returns how many bytes were parsed.
  @discardableResult public func parse(data: Data) throws -> Int {
    // Check if the parser is ready, it might need a reset because of previous errors
    if !rawParser.isReady {
      HTTPRawParser.reset(parser: &rawParser)
    }

    // Parse the provided data
    let bytesParsed = HTTPRawParser.parse(parser: &rawParser, settings: &rawParserSettings, data: data)

    // Was there an error?
    if let error = rawParser.httpError {
      cleanup()
      throw error
    }

    return bytesParsed
  }

  /// Resets the parser.
  public func reset() {
    isMessageComplete = false
    message = nil
  }

  /// Clears the helper variables.
  private func cleanup() {
    urlData.count = 0
    statusData.count = 0

    headerKeyData.count = 0
    headerValueData.count = 0
    headerChunkWasValue = false
  }
}

// MARK: HTTPParser callbacks

extension HTTPParser {
  /// Raised when the raw parser starts a new message.
  func parserDidBeginMessage(_ rawParser: HTTPRawParser) -> Int32 {
    isMessageComplete = false
    message = rawParser.isParsingRequest ? HTTPRequest() : HTTPResponse()
    return continueParsing
  }

  /// Raised when the raw parser parsed part of the URL.
  func parserDidParseURL(_ rawParser: HTTPRawParser, chunk: ChunkPointer?, count: Int) -> Int32 {
    urlData.append(chunk, count: count)

    // Not done parsing the URI? Continue
    guard rawParser.isURLComplete else { return continueParsing }

    // Check that the URI is valid
    guard let uriString = String(data: urlData, encoding: .utf8),
      let uriComponents = URLComponents(string: uriString) else { return stopParsing }

    // Set the URI, method and the host header
    request?.uri = URI(components: uriComponents)
    request?.method = rawParser.httpMethod
    request?.setHostHeader(host: uriComponents.host, port: uriComponents.port)

    return continueParsing
  }

  /// Raised when the raw parser parsed part of the status.
  func parserDidParseStatus(_ rawParser: HTTPRawParser, chunk: ChunkPointer?, count: Int) -> Int32 {
    statusData.append(chunk, count: count)

    // Not done parsing the status? Continue
    guard rawParser.isStatusComplete else { return continueParsing }

    // Validate and set the status
    guard let phrase = String(data: statusData, encoding: .utf8) else { return stopParsing }
    response?.status = HTTPStatus(code: rawParser.httpStatusCode, phrase: phrase)

    return continueParsing
  }

  /// Raised when the parser parsed part of a header field.
  func parserDidParseHeaderField(_ rawParser: HTTPRawParser, chunk: ChunkPointer?, count: Int) -> Int32 {
    // For each header we first get key chunks and then value chunks,
    // when we get to a key chunk after a value chunk it means a single header is done
    if headerChunkWasValue {
      guard headerComplete() else { return stopParsing }
    }

    headerKeyData.append(chunk, count: count)
    return continueParsing
  }

  /// Raised when the parser parsed part of a header value.
  func parserDidParseHeaderValue(_ rawParser: HTTPRawParser, chunk: ChunkPointer?, count: Int) -> Int32 {
    headerChunkWasValue = true

    headerValueData.append(chunk, count: count)
    return continueParsing
  }

  /// Raised when a single header key and value is complete.
  private func headerComplete() -> Bool {
    // Reset variables after we added the header
    defer {
      headerKeyData.count = 0
      headerValueData.count = 0
      headerChunkWasValue = false
    }

    // Make sure that the header data consists of valid String content
    guard let headerKey = String(bytes: headerKeyData, encoding: .utf8) else { return false }
    guard let headerValue = String(bytes: headerValueData, encoding: .utf8) else { return false }

    // If the header already exists add it comma separated
    if let existingValue = message?.headers[headerKey] {
      message?.headers[headerKey] = "\(existingValue),\(headerValue)"
    } else {
      message?.headers[headerKey] = headerValue
    }

    return true
  }

  /// Raised when the parser parsed the headers.
  func parserDidCompleteHeaders(_ rawParser: HTTPRawParser) -> Int32 {
    guard let message = message else { return stopParsing }

    // Set the HTTP version
    message.version = rawParser.httpVersion

    // Reserve capacity for the body
    if let contentLength = message.headers.contentLength {
      message.body.reserveCapacity(contentLength)
    }

    // Complete the last header
    if headerChunkWasValue {
      guard headerComplete() else { return stopParsing }
    }

    return continueParsing
  }

  /// Raised when the parser parsed part of the body.
  func parserDidParseBody(_ rawParser: HTTPRawParser, chunk: ChunkPointer?, count: Int) -> Int32 {
    message?.body.append(chunk, count: count)
    return continueParsing
  }

  /// Raised when the parser parsed the whole message.
  func parserDidCompleteMessage(_ rawParser: HTTPRawParser) -> Int32 {
    isMessageComplete = true
    cleanup()

    return continueParsing
  }
}

// MARK: C helpers

private func parserCall(_ rawParserPointer: UnsafeMutablePointer<HTTPRawParser>?, block: (HTTPParser, HTTPRawParser) -> Int32) -> Int32 {
  guard let rawParser = rawParserPointer?.pointee else { return stopParsing }
  let parser: HTTPParser = rawParser.context()
  return block(parser, rawParser)
}

// MARK: Data extensions

private extension Data {
  /// Appends the bytes to the data object.
  mutating func append(_ chunk: ChunkPointer?, count: Int) {
    guard let chunk = chunk else { return }
    self.append(UnsafeRawPointer(chunk).assumingMemoryBound(to: UInt8.self), count: count)
  }
}
