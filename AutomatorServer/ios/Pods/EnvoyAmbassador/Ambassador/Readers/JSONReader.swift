//
//  JSONReader.swift
//  Ambassador
//
//  Created by Fang-Pen Lin on 6/10/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

import Embassy

public struct JSONReader {
    /// Read all data into bytes array and parse it as JSON
    ///  - Parameter input: the SWSGI input to read from
    ///  - Parameter errorHandler: the handler to be called parsing JSON failed
    ///  - Parameter handler: the handler to be called when finish reading all data and parsed as JSON
    public static func read(
        _ input: SWSGIInput,
        errorHandler: ((Error) -> Void)? = nil,
        handler: @escaping ((Any) -> Void)
    ) {
        DataReader.read(input) { data in
            do {
              let json = try JSONSerialization.jsonObject(
                  with: data,
                  options: .allowFragments
              )
              handler(json)
            } catch {
                if let errorHandler = errorHandler {
                    errorHandler(error)
                }
            }
        }
    }
}
