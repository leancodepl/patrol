//
//  IOUtils.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 5/21/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

struct IOUtils {
    /// Get blocking mode from a file descriptor
    ///  - Parameter fileDescriptor: target file descriptor
    ///  - Returns: is the file in blocking mode or not
    static func getBlocking(fileDescriptor: Int32) -> Bool {
        let flags = fcntl(fileDescriptor, F_GETFL, 0)
        return flags & O_NONBLOCK == 0
    }

    /// Set blocking mode for a file descriptor
    ///  - Parameter fileDescriptor: target file descriptor
    ///  - Parameter blocking: enable blocking mode or not
    static func setBlocking(fileDescriptor: Int32, blocking: Bool) {
        let flags = fcntl(fileDescriptor, F_GETFL, 0)
        let newFlags: Int32
        if blocking {
            newFlags = flags & ~O_NONBLOCK
        } else {
            newFlags = flags | O_NONBLOCK
        }
        let _ = fcntl(fileDescriptor, F_SETFL, newFlags)
    }

}
