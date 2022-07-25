//
//  SWSGIUtils.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 5/23/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

// from http://stackoverflow.com/a/24052094/25077
/// Update one dictionay by another
private func += <K, V>(left: inout [K: V], right: [K: V]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

public struct SWSGIUtils {
    /// Transform given request into environ dictionary
    static func environFor(request: HTTPRequest) -> [String: Any] {
        var environ: [String: Any] = [
            "REQUEST_METHOD": String(describing: request.method),
            "SCRIPT_NAME": ""
        ]

        let queryParts = request.path.components(separatedBy: "?")
        if queryParts.count > 1 {
            environ["PATH_INFO"] = queryParts[0]
            environ["QUERY_STRING"] = queryParts[1..<queryParts.count].joined(separator: "?")
        } else {
            environ["PATH_INFO"] = request.path
        }
        if let contentType = request.headers["Content-Type"] {
            environ["CONTENT_TYPE"] = contentType
        }
        if let contentLength = request.headers["Content-Length"] {
            environ["CONTENT_LENGTH"] = contentLength
        }
        environ += environFor(headers: request.headers)
        return environ
    }

    /// Transform given header key value pair array into environ style header map,
    /// like from Content-Length to HTTP_CONTENT_LENGTH
    static func environFor(
        headers: MultiDictionary<String, String, LowercaseKeyTransform>
    ) -> [String: Any] {
        var environ: [String: Any] = [:]
        for (key, value) in headers {
            let key = "HTTP_" + key.uppercased().replacingOccurrences(
                of: "-",
                with: "_"
            )
            environ[key] = value
        }
        return environ
    }
}
