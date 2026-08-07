//
//  HTTPError.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/4/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public enum HTTPError: Error {
  case unexpectedStreamEnd
  case connectionShouldBeClosed

  case protocolNotSupported

  case invalidContentLength
  case invalidHeader
  case invalidRequest
  case invalidMethod
  case invalidURI
  case invalidVersion

  case headerOverflow
  case parseFailed(code: Int)
}

extension HTTPError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .unexpectedStreamEnd: return "Unexpected end of stream"
    case .connectionShouldBeClosed: return "Connection should be closed"

    case .protocolNotSupported: return "Protocol not supported"

    case .invalidRequest: return "Invalid request"
    case .invalidVersion: return "Invalid HTTP version"
    case .invalidMethod: return "Invalid HTTP method"
    case .invalidURI: return "Invalid URI"
    case .invalidHeader: return "Invalid Header"
    case .invalidContentLength: return "Invalid content length"

    case .headerOverflow: return "Received too many headers"
    case .parseFailed(let code): return "Invalid data, parser failed with code \(code)"
    }
  }
}

extension HTTPError: LocalizedError {
  public var errorDescription: String? {
    return description
  }
}
