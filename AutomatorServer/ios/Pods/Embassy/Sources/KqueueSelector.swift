//
//  KqueueSelector.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 5/20/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

#if !os(Linux)

public final class KqueueSelector: Selector {
    enum Error: Swift.Error {
        case keyError(fileDescriptor: Int32)
    }

    // the maximum event number to select from kqueue at once (one kevent call)
    private let selectMaximumEvent: Int
    private let kqueue: Int32
    private var fileDescriptorMap: [Int32: SelectorKey] = [:]

    public init(selectMaximumEvent: Int = 1024) throws {
        kqueue = Darwin.kqueue()
        guard kqueue >= 0 else {
            throw OSError.lastIOError()
        }
        self.selectMaximumEvent = selectMaximumEvent
    }

    deinit {
        close()
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

        var kevents: [Darwin.kevent] = []
        for event in events {
            let filter: Int16
            switch event {
            case .read:
                filter = Int16(EVFILT_READ)
            case .write:
                filter = Int16(EVFILT_WRITE)
            }
            let kevent = Darwin.kevent(
                ident: UInt(fileDescriptor),
                filter: filter,
                flags: UInt16(EV_ADD),
                fflags: UInt32(0),
                data: Int(0),
                udata: nil
            )
            kevents.append(kevent)
        }

        // register events to kqueue

        // Notice: we need to get the event count before we go into
        // `withUnsafeMutableBufferPointer`, as we cannot rely on it inside the closure
        // (you can read the offical document)
        let keventCount = kevents.count
        guard kevents.withUnsafeMutableBufferPointer({ pointer in
            kevent(kqueue, pointer.baseAddress, Int32(keventCount), nil, Int32(0), nil) >= 0
        }) else {
            throw OSError.lastIOError()
        }
        return key
    }

    @discardableResult
    public func unregister(_ fileDescriptor: Int32) throws -> SelectorKey {
        // ensure the file descriptor exists
        guard let key = fileDescriptorMap[fileDescriptor] else {
            throw Error.keyError(fileDescriptor: fileDescriptor)
        }
        fileDescriptorMap.removeValue(forKey: fileDescriptor)
        var kevents: [Darwin.kevent] = []
        for event in key.events {
            let filter: Int16
            switch event {
            case .read:
                filter = Int16(EVFILT_READ)
            case .write:
                filter = Int16(EVFILT_WRITE)
            }
            let kevent = Darwin.kevent(
                ident: UInt(fileDescriptor),
                filter: filter,
                flags: UInt16(EV_DELETE),
                fflags: UInt32(0),
                data: Int(0),
                udata: nil
            )
            kevents.append(kevent)
        }

        // unregister events from kqueue

        // Notice: we need to get the event count before we go into
        // `withUnsafeMutableBufferPointer`, as we cannot rely on it inside the closure
        // (you can read the offical document)
        let keventCount = kevents.count
        guard kevents.withUnsafeMutableBufferPointer({ pointer in
            kevent(kqueue, pointer.baseAddress, Int32(keventCount), nil, Int32(0), nil) >= 0
        }) else {
            throw OSError.lastIOError()
        }
        return key
    }

    public func close() {
        _ = Darwin.close(kqueue)
    }

    public func select(timeout: TimeInterval?) throws -> [(SelectorKey, Set<IOEvent>)] {
        var timeSpec: timespec?
        let timeSpecPointer: UnsafePointer<timespec>?
        if let timeout = timeout {
            if timeout > 0 {
                var integer = 0.0
                let nsec = Int(modf(timeout, &integer) * Double(NSEC_PER_SEC))
                timeSpec = timespec(tv_sec: Int(timeout), tv_nsec: nsec)
            } else {
                timeSpec = timespec()
            }
            timeSpecPointer = withUnsafePointer(to: &timeSpec!) { $0 }
        } else {
            timeSpecPointer = nil
        }

        var kevents = Array<Darwin.kevent>(repeating: Darwin.kevent(), count: selectMaximumEvent)
        let eventCount = kevents.withUnsafeMutableBufferPointer { pointer in
             return kevent(
                kqueue,
                nil,
                0,
                pointer.baseAddress,
                Int32(selectMaximumEvent),
                timeSpecPointer
            )
        }
        guard eventCount >= 0 else {
            throw OSError.lastIOError()
        }

        var fileDescriptorIOEvents = [Int32: Set<IOEvent>]()
        for index in 0..<Int(eventCount) {
            let event = kevents[index]
            let fileDescriptor = Int32(event.ident)
            var ioEvents = fileDescriptorIOEvents[fileDescriptor] ?? Set<IOEvent>()
            if event.filter == Int16(EVFILT_READ) {
                ioEvents.insert(.read)
            } else if event.filter == Int16(EVFILT_WRITE) {
                ioEvents.insert(.write)
            }
            fileDescriptorIOEvents[fileDescriptor] = ioEvents
        }
        return Array(fileDescriptorIOEvents.map { (fileDescriptorMap[$0.0]!, $0.1) })
    }

    public subscript(fileDescriptor: Int32) -> SelectorKey? {
        get {
            return fileDescriptorMap[fileDescriptor]
        }
    }
}

#endif
