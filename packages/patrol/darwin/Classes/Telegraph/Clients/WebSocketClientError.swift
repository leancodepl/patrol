//
//  WebSocketClientError.swift
//  Telegraph
//
//  Created by Yvo van Beek on 10/11/18.
//  Copyright © 2018 Building42. All rights reserved.
//

import Foundation

enum WebSocketClientError: Error {
  case invalidURL
  case invalidScheme
  case invalidHost
  case handshakeFailed(response: HTTPResponse)
}

extension WebSocketClientError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .invalidURL: return "The provided URL is not a valid"
    case .invalidScheme: return "The provided URL does not have a WebSocket scheme (http, https, ws or wss)"
    case .invalidHost: return "The provided URL should have a host"
    case let .handshakeFailed(response): return "The handshake request failed with status \(response.status)"
    }
  }
}

extension WebSocketClientError: LocalizedError {
  public var errorDescription: String? {
    return description
  }
}
