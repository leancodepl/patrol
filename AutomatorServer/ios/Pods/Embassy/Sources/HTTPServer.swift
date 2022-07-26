//
//  HTTPServer.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 5/19/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

/// HTTPServerType is the protocol for basic SWSGI server
public protocol HTTPServer {
    /// The SWSGI app to serve
    var app: SWSGI { get set }
    /// Start the HTTP server
    func start() throws
    /// Stop the HTTP server.
    /// This is not thread-safe, needs to be called inside event loop, call `stopAndWait` instead
    /// from other thread
    func stop()
    /// Stop the HTTP server in thread-safe manner, also wait until the server completely stopped.
    /// If there is pending connections, they will all be closed without waiting them to finish up.
    func stopAndWait()
}
