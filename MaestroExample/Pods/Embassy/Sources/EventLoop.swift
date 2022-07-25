//
//  EventLoop.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 5/23/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

/// EventLoop uses given selector to monitor IO events, trigger callbacks when needed to
/// Follow Python EventLoop design https://docs.python.org/3/library/asyncio-eventloop.html
public protocol EventLoop {
    /// Indicate whether is this event loop running
    var running: Bool { get }

    /// Set a read-ready callback for given fileDescriptor
    ///  - Parameter fileDescriptor: target file descriptor
    ///  - Parameter callback: callback function to be triggered when file is ready to be read
    func setReader(_ fileDescriptor: Int32, callback: @escaping () -> Void)

    /// Remove reader callback for given fileDescriptor
    ///  - Parameter fileDescriptor: target file descriptor
    func removeReader(_ fileDescriptor: Int32)

    /// Set a write-ready callback for given fileDescriptor
    ///  - Parameter fileDescriptor: target file descriptor
    ///  - Parameter callback: callback function to be triggered when file is ready to be written
    func setWriter(_ fileDescriptor: Int32, callback: @escaping () -> Void)

    /// Remove writer callback for given fileDescriptor
    ///  - Parameter fileDescriptor: target file descriptor
    func removeWriter(_ fileDescriptor: Int32)

    /// Call given callback as soon as possible (the next event loop iteration)
    ///  - Parameter callback: the callback function to be called
    func call(callback: @escaping () -> Void)

    /// Call given callback `withDelay` seconds later
    ///  - Parameter withDelay: delaying in seconds
    ///  - Parameter callback: the callback function to be called
    func call(withDelay: TimeInterval, callback: @escaping () -> Void)

    /// Call given callback at specific time
    ///  - Parameter atTime: time the callback to be called
    ///  - Parameter callback: the callback function to be called
    func call(atTime: Date, callback: @escaping () -> Void)

    /// Stop the event loop
    func stop()

    /// Run the event loop forever
    func runForever()
}
