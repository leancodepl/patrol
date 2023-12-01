//
//  HTTPFileHandler.swift
//  Telegraph
//
//  Created by Yvo van Beek on 5/16/17.
//  Copyright © 2017 Building42. All rights reserved.
//
//

import Foundation

open class HTTPFileHandler: HTTPRequestHandler {
  public private(set) var directoryURL: URL
  public private(set) var baseURI: URI
  public private(set) var index: String?

  public typealias ByteRange = (UInt64, UInt64?)

  /// Creates a HTTPFileHandler to serve the provided directory at the provided URI.
  public init(directoryURL: URL, baseURI: URI = .root, index: String? = "index.html") {
    self.directoryURL = directoryURL
    self.baseURI = baseURI
    self.index = index
  }

  /// Creates a response to the provided request or passes it to the next handler.
  open func respond(to request: HTTPRequest, nextHandler: HTTPRequest.Handler) throws -> HTTPResponse? {
    // Only respond to GET requests targetted at our path
    guard request.method == .GET, let relativePath = request.uri.relativePath(from: baseURI.path) else {
      return try nextHandler(request)
    }

    // Construct the full resource URL
    let resourceURL = directoryURL.appendingPathComponent(relativePath)
    var byteRange: ByteRange?

    // Is a specific range requested? Fallback to a non-range request if the range isn't about bytes
    if let rangeInHeaders = request.headers.range, let byteRangeInHeaders = byteRangeFrom(rangeInHeaders) {
      byteRange = byteRangeInHeaders
    }

    return try responseForURL(resourceURL, byteRange: byteRange, request: request)
  }

  /// Creates a response that serves the provided URL.
  open func responseForURL(_ url: URL, byteRange: ByteRange?, request: HTTPRequest) throws -> HTTPResponse {
    let fileManager = FileManager.default

    // Check if the requested path exists
    guard let attributes = try? fileManager.attributesOfItem(atPath: url.path) as NSDictionary else {
      return HTTPResponse(.notFound)
    }

    // Determine the type of the requested resource
    guard let rawResourceType = attributes.fileType() else { return HTTPResponse(.forbidden) }
    let resourceType = FileAttributeType(rawValue: rawResourceType)

    // Check for symbolic link destination
    if resourceType == .typeSymbolicLink,
       let destination = try? fileManager.destinationOfSymbolicLink(atPath: url.path) {
        return try responseForURL(URL(fileURLWithPath: destination), byteRange: byteRange, request: request)
    }

    // Allow directories
    if resourceType == .typeDirectory {
      guard let index = index else { return HTTPResponse(.forbidden) }

      // Create a response based on the index file in the directory
      let indexURL = url.appendingPathComponent(index, isDirectory: false)
      return try responseForURL(indexURL, byteRange: byteRange, request: request)
    }

    // Only provide the data of files and symbolic links
    guard resourceType == .typeRegular || resourceType == .typeSymbolicLink else {
      return HTTPResponse(.forbidden)
    }

    // Construct a response
    let response = HTTPResponse()
    response.headers.contentType = url.mimeType

    // Do we know the last modified date of the file?
    if let lastModifiedDate = attributes.fileModificationDate() {
      response.headers.lastModified = lastModifiedDate.rfc1123

      // Did the client send us a last modified date?
      if let clientLastModified = request.headers.ifModifiedSince,
         let clientLastModifiedDate = DateFormatter.rfc1123.date(from: clientLastModified) {
        // Compare the two dates, round down because the local date is more precise than the one the client sent
        let lastModifiedEpoch = lastModifiedDate.timeIntervalSince1970.rounded(.down)
        let clientLastModifiedEpoch = clientLastModifiedDate.timeIntervalSince1970.rounded(.down)

        // If the client is up-to-date, send a 304 not modified and don't send a body
        if lastModifiedEpoch <= clientLastModifiedEpoch {
          response.status = .notModified
          return response
        }
      }
    }

    // Is a range requested?
    if let (byteStart, byteEndOrNil) = byteRange {
      // Open a file handle and move the pointer to the start byte
      let fileHandle = try FileHandle(forReadingFrom: url)
      fileHandle.seek(toFileOffset: byteStart)

      // Determine the size of the file and the end of the range
      let fileSize = attributes.fileSize()
      let byteEnd = byteEndOrNil ?? fileSize - 1

      // Validate the range, if something is wrong respond with a 416 (Range Not Satisfiable)
      if byteStart >= fileSize || byteEnd >= fileSize || byteEnd < byteStart {
        return HTTPResponse(.rangeNotSatisfiable, headers: [.contentRange: "bytes */\(fileSize)"])
      }

      // Add the header that describes the range in the response
      response.headers.contentRange = "bytes \(byteStart)-\(byteEnd)/\(fileSize)"

      // Add the segment from the file as the response body (range is inclusive, therefor + 1)
      response.status = .partialContent
      response.body = fileHandle.readData(ofLength: Int(byteEnd - byteStart) + 1)
    } else {
      // Add the whole file as the response body
      response.status = .ok
      response.body = try Data(contentsOf: url)
    }

    return response
  }

  /// Extracts the byte range from the provided String.
  private func byteRangeFrom(_ range: String) -> ByteRange? {
    // Make sure that the range syntax is valid (e.g. bytes=0-)
    guard range.count >= 8, range.hasPrefix("bytes=") else { return nil }
    let bytes = range.suffix(range.count - 6).split(separator: "-")

    switch bytes.count {
    case 1:
      // Only a start range? (e.g. bytes=100-)
      guard let rangeStart = UInt64(bytes[0]) else { return nil }
      return (rangeStart, nil)
    case 2:
      // Both start and end range? (e.g. bytes=0-100)
      guard let rangeStart = UInt64(bytes[0]), let rangeEnd = UInt64(bytes[1]) else { return nil }
      return (rangeStart, rangeEnd)
    default:
      // The rest is invalid
      return nil
    }
  }
}
