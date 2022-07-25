//
//  HTTPRequest.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 5/21/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

public struct HTTPRequest {
    public enum Method: CustomStringConvertible {
        case get
        case head
        case post
        case put
        case delete
        case trace
        case options
        case connect
        case patch
        case other(name: String)

        public var description: String {
            switch self {
            case .get:
                return "GET"
            case .head:
                return "HEAD"
            case .post:
                return "POST"
            case .put:
                return "PUT"
            case .delete:
                return "DELETE"
            case .trace:
                return "TRACE"
            case .options:
                return "OPTIONS"
            case .connect:
                return "CONNECT"
            case .patch:
                return "PATCH"
            case .other(name: let name):
                return name
            }
        }

        public static func fromString(_ name: String) -> Method {
            switch name.uppercased() {
            case "GET":
                return .get
            case "HEAD":
                return .head
            case "POST":
                return .post
            case "PUT":
                return .put
            case "DELETE":
                return .delete
            case "TRACE":
                return .trace
            case "OPTIONS":
                return .options
            case "CONNECT":
                return .connect
            case "PATCH":
                return .patch
            default:
                return .other(name: name)
            }
        }
    }

    /// Request method
    let method: Method
    /// Request path
    let path: String
    /// Request HTTP version (e.g. HTTP/1.0)
    let version: String
    /// Request headers
    let headers: MultiDictionary<String, String, LowercaseKeyTransform>

    public init(method: Method, path: String, version: String, headers: [(String, String)]) {
        self.method = method
        self.path = path
        self.version = version
        self.headers = MultiDictionary(items: headers)
    }
}
