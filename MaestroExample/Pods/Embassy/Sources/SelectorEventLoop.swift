//
//  SelectorEventLoop.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 5/20/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation


private class CallbackHandle {
    let reader: (() -> Void)?
    let writer: (() -> Void)?
    init(reader: (() -> Void)? = nil, writer: (() -> Void)? = nil) {
        self.reader = reader
        self.writer = writer
    }
}

/// EventLoop uses given selector to monitor IO events, trigger callbacks when needed to
/// Follow Python EventLoop design https://docs.python.org/3/library/asyncio-eventloop.html
public final class SelectorEventLoop: EventLoop {
    private(set) public var running: Bool = false
    private let selector: Selector
    // these are for self-pipe-trick ref: https://cr.yp.to/docs/selfpipe.html
    // to be able to interrupt the blocking selector, we create a pipe and add it to the
    // selector, whenever we want to interrupt the selector, we send a byte
    private let pipeSender: Int32
    private let pipeReceiver: Int32
    // callbacks ready to be called at the next iteration
    private var readyCallbacks = Atomic<[(() -> Void)]>([])
    // callbacks scheduled to be called later
    private var scheduledCallbacks = Atomic<[(Date, (() -> Void))]>([])

    public init(selector: Selector) throws {
        self.selector = selector
        var pipeFds = [Int32](repeating: 0, count: 2)
        let pipeResult = pipeFds.withUnsafeMutableBufferPointer {
            SystemLibrary.pipe($0.baseAddress)
        }
        guard pipeResult >= 0 else {
            throw OSError.lastIOError()
        }
        pipeReceiver = pipeFds[0]
        pipeSender = pipeFds[1]
        IOUtils.setBlocking(fileDescriptor: pipeSender, blocking: false)
        IOUtils.setBlocking(fileDescriptor: pipeReceiver, blocking: false)
        // subscribe to pipe receiver read-ready event, do nothing, just allow selector
        // to be interrupted
        
        // Notice: we use a local copy of pipeReceiver to avoid referencing self
        // here, thus we won't have reference cycle problem
        let localPipeReceiver = pipeReceiver
        setReader(pipeReceiver) {
            // consume the pipe receiver, so that it won't keep triggering read event
            let size = PIPE_BUF
            var bytes = Data(count: Int(size))
            var readSize = 1
            while readSize > 0 {
                readSize = bytes.withUnsafeMutableBytes { pointer in
                    return SystemLibrary.read(localPipeReceiver, pointer, Int(size))
                }
            }
        }
    }

    deinit {
        stop()
        removeReader(pipeReceiver)
        let _ = SystemLibrary.close(pipeSender)
        let _ = SystemLibrary.close(pipeReceiver)
    }

    public func setReader(_ fileDescriptor: Int32, callback: @escaping () -> Void) {
        // we already have the file descriptor in selector, unregister it then register
        if let key = selector[fileDescriptor] {
            let oldHandle = key.data as! CallbackHandle
            let handle = CallbackHandle(reader: callback, writer: oldHandle.writer)
            try! selector.unregister(fileDescriptor)
            try! selector.register(
                fileDescriptor,
                events: key.events.union([.read]),
                data: handle
            )
        // register the new file descriptor
        } else {
            try! selector.register(
                fileDescriptor,
                events: [.read],
                data: CallbackHandle(reader: callback)
            )
        }
    }

    public func removeReader(_ fileDescriptor: Int32) {
        guard let key = selector[fileDescriptor] else {
            return
        }
        try! selector.unregister(fileDescriptor)
        let newEvents = key.events.subtracting([.read])
        guard !newEvents.isEmpty else {
            return
        }
        let oldHandle = key.data as! CallbackHandle
        let handle = CallbackHandle(reader: nil, writer: oldHandle.writer)
        try! selector.register(fileDescriptor, events: newEvents, data: handle)
    }

    public func setWriter(_ fileDescriptor: Int32, callback: @escaping () -> Void) {
        // we already have the file descriptor in selector, unregister it then register
        if let key = selector[fileDescriptor] {
            let oldHandle = key.data as! CallbackHandle
            let handle = CallbackHandle(reader: oldHandle.reader, writer: callback)
            try! selector.unregister(fileDescriptor)
            try! selector.register(
                fileDescriptor,
                events: key.events.union([.write]),
                data: handle
            )
            // register the new file descriptor
        } else {
            try! selector.register(
                fileDescriptor,
                events: [.write],
                data: CallbackHandle(writer: callback)
            )
        }
    }

    public func removeWriter(_ fileDescriptor: Int32) {
        guard let key = selector[fileDescriptor] else {
            return
        }
        try! selector.unregister(fileDescriptor)
        let newEvents = key.events.subtracting([.write])
        guard !newEvents.isEmpty else {
            return
        }
        let oldHandle = key.data as! CallbackHandle
        let handle = CallbackHandle(reader: oldHandle.reader, writer: nil)
        try! selector.register(fileDescriptor, events: newEvents, data: handle)
    }

    public func call(callback: @escaping () -> Void) {
        readyCallbacks.modify { callbacks in
            var callbacks = callbacks
            callbacks.append(callback)
            return callbacks
        }
        interruptSelector()
    }

    public func call(withDelay delay: TimeInterval, callback: @escaping () -> Void) {
        call(atTime: Date().addingTimeInterval(delay), callback: callback)
    }

    public func call(atTime time: Date, callback: @escaping () -> Void) {
        scheduledCallbacks.modify { callbacks in
            var callbacks = callbacks
            HeapSort.heapPush(&callbacks, item: (time, callback)) {
                $0.0.timeIntervalSince1970 < $1.0.timeIntervalSince1970
            }
            return callbacks
        }
        interruptSelector()
    }

    public func stop() {
        running = false
        interruptSelector()
    }

    public func runForever() {
        running = true
        while running {
            runOnce()
        }
    }

    // interrupt the selector
    private func interruptSelector() {
        let byte = [UInt8](repeating: 0, count: 1)
        let rc = write(pipeSender, byte, byte.count)
        assert(
            rc >= 0,
            "Failed to interrupt selector, errno=\(errno), message=\(lastErrorDescription())"
        )
    }

    // Run once iteration for the event loop
    private func runOnce() {
        var timeout: TimeInterval?
        scheduledCallbacks.withValue { callbacks in
            // as the scheduledCallbacks is a heap queue, the first one will be the smallest one
            // (the latest one)
            if let firstTuple = callbacks.first {
                // schedule timeout for the very next scheduled callback
                let (minTime, _) = firstTuple
                timeout = max(0, minTime.timeIntervalSince(Date()))
            } else {
                timeout = nil
            }
        }

        var events: [(SelectorKey, Set<IOEvent>)] = []
        // Poll IO events
        do {
            events = try selector.select(timeout: timeout)
        } catch OSError.ioError(let number, let message) {
            assert(number == EINTR, "Failed to call selector, errno=\(number), message=\(message)")
        } catch {
            fatalError("Failed to call selector, errno=\(errno), message=\(lastErrorDescription())")
        }
        for (key, ioEvents) in events {
            guard let handle = key.data as? CallbackHandle else {
                continue
            }
            for ioEvent in ioEvents {
                switch ioEvent {
                case .read:
                    if let callback = handle.reader {
                        callback()
                    }
                case .write:
                    if let callback = handle.writer {
                        callback()
                    }
                }
            }
        }

        // Call scheduled callbacks
        let now = Date()
        var readyScheduledCallbacks: [(() -> Void)] = []
        scheduledCallbacks.modify { callbacks in
            var notExpiredCallbacks = callbacks
            // keep poping expired callbacks
            let timestamp = now.timeIntervalSince1970
            while (
                !notExpiredCallbacks.isEmpty &&
                timestamp >= notExpiredCallbacks.first!.0.timeIntervalSince1970
            ) {
                // pop the expired callbacks from heap queue and add them to ready callback list
                let (_, callback) = HeapSort.heapPop(&notExpiredCallbacks) {
                    $0.0.timeIntervalSince1970 < $1.0.timeIntervalSince1970
                }
                readyScheduledCallbacks.append(callback)
            }
            return notExpiredCallbacks
        }

        // Call ready callbacks
        let callbacks = readyCallbacks.swap(newValue: []) + readyScheduledCallbacks
        for callback in callbacks {
            callback()
        }
    }

}
