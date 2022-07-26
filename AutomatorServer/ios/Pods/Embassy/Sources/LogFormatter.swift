//
//  LogFormatter.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 6/2/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

/// Log formatter convert given log record into printable text
public protocol LogFormatter {
    func format(record: LogRecord) -> String
}
