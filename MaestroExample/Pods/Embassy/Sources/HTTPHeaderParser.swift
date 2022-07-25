//
//  HTTPHeaderParser.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 5/19/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

extension String {
    /// String without leading spaces
    var withoutLeadingSpaces: String {
        var firstNoneSpace: Int = count
        for (i, char) in enumerated() {
            if char != " " {
                firstNoneSpace = i
                break
            }
        }
        return String(suffix(from: index(startIndex, offsetBy: firstNoneSpace)))
    }
}

/// Parser for HTTP headers
public struct HTTPHeaderParser {
    private static let CR = UInt8(13)
    private static let LF = UInt8(10)
    private static let NEWLINE = (CR, LF)

    public enum Element {
        case head(method: String, path: String, version: String)
        case header(key: String, value: String)
        case end(bodyPart: Data)
    }

    private enum State {
        case head
        case headers
    }
    private var state: State = .head
    private var buffer: Data = Data()

    /// Feed data to HTTP parser
    ///  - Parameter data: the data to feed
    ///  - Returns: parsed headers elements
    mutating func feed(_ data: Data) -> [Element] {
        buffer.append(data)
        var elements = [Element]()
        while buffer.count > 0 {
            // pair of (0th, 1st), (1st, 2nd), (2nd, 3rd) ... chars, so that we can find <LF><CR>
            let charPairs: [(UInt8, UInt8)] = Array(zip(
                buffer[0..<buffer.count - 1],
                buffer[1..<buffer.count]
            ))
            // ensure we have <CR><LF> in current buffer
            guard let index = (charPairs).firstIndex(where: { $0 == HTTPHeaderParser.NEWLINE }) else {
                // no <CR><LF> found, just return the current elements
                return elements
            }
            let bytes = Array(buffer[0..<index])
            let string = String(bytes: bytes, encoding: String.Encoding.utf8)!
            buffer = buffer.subdata(in: (index + 2)..<buffer.count)

            // TODO: the initial usage of this HTTP server is for iOS API server mocking only,
            // we don't usually see malform requests, but if it's necessary, like if we want to put
            // this server in real production, we should handle malform header then
            switch state {
            case .head:
                let parts = string.components(separatedBy: " ")
                elements.append(.head(method: parts[0], path: parts[1], version: parts[2..<parts.count].joined(separator: " ")))
                state = .headers
            case .headers:
                // end of headers
                guard bytes.count > 0 else {
                    elements.append(.end(bodyPart: buffer))
                    return elements
                }
                let parts = string.components(separatedBy: ":")
                let key = parts[0]
                let value = parts[1..<parts.count].joined(separator: ":").withoutLeadingSpaces
                elements.append(.header(key: key, value: value))
            }
        }
        return elements
    }
}
