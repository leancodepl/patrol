//
//  URLParametersReader.swift
//  Ambassador
//
//  Created by Fang-Pen Lin on 6/10/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

import Embassy

public struct URLParametersReader {
    public enum LocalError: Error {
        case utf8EncodingError
    }

    /// Read all data into bytes array and parse it as URL parameter
    ///  - Parameter input: the SWSGI input to read from
    ///  - Parameter errorHandler: the handler to be called when failed to read URL parameters
    ///  - Parameter handler: the handler to be called when finish reading all data and parsed as URL
    ///                       parameter
    public static func read(
        _ input: SWSGIInput,
        errorHandler: ((Error) -> Void)? = nil,
        handler: @escaping (([(String, String)]) -> Void)
    ) {
        DataReader.read(input) { data in
            do {
                guard let string = String(bytes: data, encoding: .utf8) else {
                    throw LocalError.utf8EncodingError
                }
                let parameters = URLParametersReader.parseURLParameters(string)
                handler(parameters)
            } catch {
                if let errorHandler = errorHandler {
                    errorHandler(error)
                }
            }
        }
    }

    /// Parse given string as URL parameters
    ///  - Parameter string: URL encoded parameter string to parse
    ///  - Returns: array of (key, value) pairs of URL encoded parameters
    public static func parseURLParameters(_ string: String) -> [(String, String)] {
        let parameters = string.components(separatedBy: "&")
        return parameters.map { parameter in
            let parts = parameter.components(separatedBy: "=")
            let key = parts[0]
            let value = Array(parts[1..<parts.count]).joined(separator: "=")
            return (
                key.removingPercentEncoding ?? key,
                value.removingPercentEncoding ?? value
            )
        }
    }
}
