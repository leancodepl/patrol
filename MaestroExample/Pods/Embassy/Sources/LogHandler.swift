//
//  LogHandler.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 6/2/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

public protocol LogHandler {
    var formatter: LogFormatter? { get set }

    /// Handle given record from logger
    ///  - Parameter record: log record
    func emit(record: LogRecord)
}
