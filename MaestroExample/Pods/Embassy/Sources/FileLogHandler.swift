//
//  FileLogHandler.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 6/2/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation
import Dispatch

/// A log handler which writes log records to given file handle
public struct FileLogHandler: LogHandler {
    let fileHandle: FileHandle
    public var formatter: LogFormatter?

    private let queue = DispatchQueue(
        label: "com.envoy.Embassy.logging.FileLogHandler.queue",
        attributes: []
    )

    public init(fileHandle: FileHandle, formatter: LogFormatter? = nil) {
        self.fileHandle = fileHandle
        self.formatter = formatter ?? DefaultLogFormatter()
    }

    public func emit(record: LogRecord) {
        queue.async {
            if let formatter = self.formatter {
                let msg = formatter.format(record: record) + "\n"
                self.fileHandle.write(msg.data(using: String.Encoding.utf8)!)
                self.fileHandle.synchronizeFile()
            }
        }
    }

    public static func stderrHandler() -> FileLogHandler {
        return FileLogHandler(fileHandle: FileHandle.standardError)
    }
}
