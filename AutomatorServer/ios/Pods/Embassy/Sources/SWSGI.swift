//
//  SWSGI.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 5/19/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation


/**
    Swift Web Server Gateway Interface

    This is a HTTP server gateway interface inspired by Python's WSGI

     - Parameter environ: environ variables for the incoming HTTP request (TODO: keys need to be defined)
     - Parameter startResponse: function to call to inform server to start sending HTTP response header to client,
                                first argument is the status text, e.g. "200 OK". The second argument is a list of
                                header key and value pair
     - Parameter sendBody: function to call to send the HTTP body to client, to end the stream, simply send an UInt8
                           with zero length

*/
public typealias SWSGI = (
    [String: Any],
    @escaping ((String, [(String, String)]) -> Void),
    @escaping ((Data) -> Void)
) -> Void

/**
    SWSGI Input interface for receiving incoming data from request.
    To receive data, pass handler function, to pause reading data, just pass nil as the handler
*/
public typealias SWSGIInput = (((Data) -> Void)?) -> Void
