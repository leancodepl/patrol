//
//  JSONResponse.swift
//  Ambassador
//
//  Created by Fang-Pen Lin on 6/10/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

import Embassy

/// A response app for responding JSON data
public struct JSONResponse: WebApp {
    /// Underlying data response
    let dataResponse: DataResponse

    public init(
        statusCode: Int = 200,
        statusMessage: String = "OK",
        contentType: String = "application/json",
        jsonWritingOptions: JSONSerialization.WritingOptions = .prettyPrinted,
        headers: [(String, String)] = [],
        handler: @escaping (_ environ: [String: Any], _ sendJSON: @escaping (Any) -> Void) -> Void
    ) {
        dataResponse = DataResponse(
            statusCode: statusCode,
            statusMessage: statusMessage,
            contentType: contentType,
            headers: headers
        ) { environ, sendData in
            handler(environ) { json in
                let data = try! JSONSerialization.data(withJSONObject: json, options: jsonWritingOptions)
                sendData(data)
            }
        }
    }

    public init(
        statusCode: Int = 200,
        statusMessage: String = "OK",
        contentType: String = "application/json",
        jsonWritingOptions: JSONSerialization.WritingOptions = .prettyPrinted,
        headers: [(String, String)] = [],
        handler: ((_ environ: [String: Any]) -> Any)? = nil
    ) {
        dataResponse = DataResponse(
            statusCode: statusCode,
            statusMessage: statusMessage,
            contentType: contentType,
            headers: headers
        ) { environ, sendData in
            let data: Data
            if let handler = handler {
                let json = handler(environ)
                data = try! JSONSerialization.data(withJSONObject: json, options: jsonWritingOptions)
            } else {
                data = Data()
            }
            sendData(data)
        }
    }

    public func app(
        _ environ: [String: Any],
        startResponse: @escaping ((String, [(String, String)]) -> Void),
        sendBody: @escaping ((Data) -> Void)
    ) {
        return dataResponse.app(environ, startResponse: startResponse, sendBody: sendBody)
    }
}
