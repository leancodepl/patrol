//
//  Logger.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 6/2/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

public enum LogLevel: Int {
    case notset = 0
    case debug = 10
    case info = 20
    case warning = 30
    case error = 40
    case critical = 50

    var name: String {
        switch self {
        case .notset:
            return "NOTSET"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        case .critical:
            return "CRITICAL"
        }
    }
}

public struct LogRecord {
    let loggerName: String
    let level: LogLevel
    let message: String
    let file: String
    let function: String
    let line: Int
    let time: Date
}

extension LogRecord {
    /// Overwrite message and return a new record
    ///  - Parameter overwrite: closure to accept self record and return overwritten string
    ///  - Returns: the overwritten log record
    public func overwriteMessage(overwrite: ((LogRecord) -> String)) -> LogRecord {
        return LogRecord(
            loggerName: loggerName,
            level: level,
            message: overwrite(self),
            file: file,
            function: function,
            line: line,
            time: time
        )
    }
}

public protocol Logger {
    /// Add a handler to the logger
    func add(handler: LogHandler)

    /// Write log record to logger
    func log(record: LogRecord)
}
