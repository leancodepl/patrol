//
//  DataResponse.swift
//  Ambassador
//
//  Created by Fang-Pen Lin on 6/10/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

import Embassy

// TODO: maybe we should move these stuff to Embassy instead
/// Data response responses data from given handler immediately to the client
public struct DataResponse: WebApp {
    /// The status code to response
    public let statusCode: Int
    /// The status message to response
    public let statusMessage: String
    /// Headers to response
    public let headers: [(String, String)]
    /// Function for generating JSON response
    public let handler: (_ environ: [String: Any], _ sendData: @escaping (Data) -> Void) -> Void
    /// The Content type to response
    public let contentType: String

    public init(
        statusCode: Int = 200,
        statusMessage: String = "OK",
        contentType: String = "application/octet-stream",
        headers: [(String, String)] = [],
        handler: @escaping (_ environ: [String: Any], _ sendData: @escaping (Data) -> Void) -> Void
    ) {
        self.statusCode = statusCode
        self.statusMessage = statusMessage
        self.contentType = contentType
        self.headers = headers
        self.handler = handler
    }

    public init(
        statusCode: Int = 200,
        statusMessage: String = "OK",
        contentType: String = "application/octet-stream",
        headers: [(String, String)] = [],
        handler: ((_ environ: [String: Any]) -> Data)? = nil
    ) {
        self.statusCode = statusCode
        self.statusMessage = statusMessage
        self.contentType = contentType
        self.headers = headers
        self.handler = { environ, sendData in
            if let handler = handler {
                let data = handler(environ)
                sendData(data)
            } else {
                sendData(Data())
            }
        }
    }

    public func app(
        _ environ: [String: Any],
        startResponse: @escaping ((String, [(String, String)]) -> Void),
        sendBody: @escaping ((Data) -> Void)
    ) {
        handler(environ) { data in
            var headers = self.headers
            let headerDict = MultiDictionary<String, String, LowercaseKeyTransform>(items: headers)
            if headerDict["Content-Type"] == nil {
                headers.append(("Content-Type", self.contentType))
            }
            if headerDict["Content-Length"] == nil {
                headers.append(("Content-Length", String(data.count)))
            }

            startResponse("\(self.statusCode) \(self.statusMessage)", headers)
            if !data.isEmpty {
                sendBody(data)
            }
            sendBody(Data())
        }
    }
}
