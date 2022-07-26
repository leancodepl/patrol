//
//  PropagateLogHandler.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 6/2/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

/// A log handler which propagates record to another logger
public struct PropagateLogHandler: LogHandler {
    public let logger: Logger
    public var formatter: LogFormatter?

    public init(logger: Logger) {
        self.logger = logger
    }

    public func emit(record: LogRecord) {
        logger.log(record: record)
    }
}
