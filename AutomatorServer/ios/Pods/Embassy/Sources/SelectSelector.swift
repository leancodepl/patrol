//
//  SelectSelector.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 1/6/17.
//  Copyright © 2017 Fang-Pen Lin. All rights reserved.
//

import Foundation

public final class SelectSelector: Selector {
    enum Error: Swift.Error {
        case keyError(fileDescriptor: Int32)
    }

    private var fileDescriptorMap: [Int32: SelectorKey] = [:]

    public init() throws {
    }

    @discardableResult
    public func register(
        _ fileDescriptor: Int32,
        events: Set<IOEvent>,
        data: Any?
    ) throws -> SelectorKey {
        // ensure the file descriptor doesn't exist already
        guard fileDescriptorMap[fileDescriptor] == nil else {
            throw Error.keyError(fileDescriptor: fileDescriptor)
        }
        let key = SelectorKey(fileDescriptor: fileDescriptor, events: events, data: data)
        fileDescriptorMap[fileDescriptor] = key
        return key
    }

    @discardableResult
    public func unregister(_ fileDescriptor: Int32) throws -> SelectorKey {
        // ensure the file descriptor exists
        guard let key = fileDescriptorMap[fileDescriptor] else {
            throw Error.keyError(fileDescriptor: fileDescriptor)
        }
        fileDescriptorMap.removeValue(forKey: fileDescriptor)
        return key
    }

    public func close() {
    }

    public func select(timeout: TimeInterval?) throws -> [(SelectorKey, Set<IOEvent>)] {
        var readSet = fd_set()
        var writeSet = fd_set()

        var maxFd: Int32 = 0
        for (fd, key) in fileDescriptorMap {
            if fd > maxFd {
                maxFd = fd
            }
            if key.events.contains(.read) {
                SystemLibrary.fdSet(fd: fd, set: &readSet)
            }
            if key.events.contains(.write) {
                SystemLibrary.fdSet(fd: fd, set: &writeSet)
            }
        }
        let status: Int32
        let microsecondsPerSecond = 1000000
        if let timeout = timeout {
            var timeoutVal = timeval()
            #if os(Linux)
            timeoutVal.tv_sec = Int(timeout)
            timeoutVal.tv_usec = Int(
                Int(timeout * Double(microsecondsPerSecond)) -
                timeoutVal.tv_sec * microsecondsPerSecond
            )
            #else
            // TODO: not sure is the calculation correct here
            timeoutVal.tv_sec = Int(timeout)
            timeoutVal.tv_usec = __darwin_suseconds_t(
                Int(timeout * Double(microsecondsPerSecond)) -
                timeoutVal.tv_sec * microsecondsPerSecond
            )
            #endif
            status = SystemLibrary.select(maxFd + 1, &readSet, &writeSet, nil, &timeoutVal)
        } else {
            status = SystemLibrary.select(maxFd + 1, &readSet, &writeSet, nil, nil)
        }
        switch status {
        case 0:
            // TODO: timeout?
            return []
        // Error
        case -1:
            throw OSError.lastIOError()
        default:
            break
        }

        var result: [(SelectorKey, Set<IOEvent>)] = []
        for (fd, key) in fileDescriptorMap {
            var events = Set<IOEvent>()
            if SystemLibrary.fdIsSet(fd: fd, set: &readSet) {
                events.insert(.read)
            }
            if SystemLibrary.fdIsSet(fd: fd, set: &writeSet) {
                events.insert(.write)
            }
            if events.count > 0 {
                result.append((key, events))
            }
        }
        return result
    }

    public subscript(fileDescriptor: Int32) -> SelectorKey? {
        get {
            return fileDescriptorMap[fileDescriptor]
        }
    }
}
