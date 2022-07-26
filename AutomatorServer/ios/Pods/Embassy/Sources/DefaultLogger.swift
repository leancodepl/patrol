//
//  DefaultLogger.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 5/21/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

public final class DefaultLogger: Logger {
    let name: String
    let level: LogLevel
    private(set) var handlers: [LogHandler] = []

    public init(name: String, level: LogLevel = .info) {
        self.name = name
        self.level = level
    }

    public init(fileName: String = #file, level: LogLevel = .info) {
        self.name = DefaultLogger.moduleNameForFileName(fileName)
        self.level = level
    }

    /// Add handler to self logger
    ///  - Parameter handler: the handler to add
    public func add(handler: LogHandler) {
        handlers.append(handler)
    }

    public func debug(
        _ message: @autoclosure () -> String,
        caller: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        log(level: .debug, message: message(), caller: caller, file: file, line: line)
    }

    public func info(
        _ message: @autoclosure () -> String,
        caller: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        log(level: .info, message: message(), caller: caller, file: file, line: line)
    }

    public func warning(
        _ message: @autoclosure () -> String,
        caller: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        log(level: .warning, message: message(), caller: caller, file: file, line: line)
    }

    public func error(
        _ message: @autoclosure () -> String,
        caller: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        log(level: .error, message: message(), caller: caller, file: file, line: line)
    }

    public func critical(
        _ message: @autoclosure () -> String,
        caller: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        log(level: .critical, message: message(), caller: caller, file: file, line: line)
    }

    func log(
        level: LogLevel,
        message: @autoclosure () -> String,
        caller: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        let record = LogRecord(
            loggerName: name,
            level: level,
            message: message(),
            file: file,
            function: caller,
            line: line,
            time: Date()
        )
        log(record: record)
    }

    public func log(record: LogRecord) {
        guard record.level.rawValue >= level.rawValue else {
            return
        }
        for handler in handlers {
            handler.emit(record: record)
        }
    }

    /// Strip file name and return only the name part, e.g. /path/to/MySwiftModule.swift will be
    /// MySwiftModule
    ///  - Parameter fileName: file name to be stripped
    ///  - Returns: stripped file name
    static func moduleNameForFileName(_ fileName: String) -> String {
        return URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
    }
}
