//
//  DataReader.swift
//  Ambassador
//
//  Created by Fang-Pen Lin on 6/10/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

import Embassy

public struct DataReader {
    /// Read all data into bytes array and pass it to handler
    ///  - Parameter input: the SWSGI input to read from
    ///  - Parameter handler: the handler to be called when finish reading all data
    public static func read(_ input: SWSGIInput, handler: @escaping ((Data) -> Void)) {
        var buffer: Data = Data()
        // read all data into buffer
        input { data in
            buffer.append(data)
            // EOF, flush
            if data.isEmpty {
                handler(buffer)
            }
        }
    }
}
