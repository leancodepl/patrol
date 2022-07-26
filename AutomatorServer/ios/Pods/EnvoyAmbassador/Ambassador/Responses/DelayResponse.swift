//
//  DelayResponse.swift
//  Ambassador
//
//  Created by Fang-Pen Lin on 6/10/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

import Embassy

/// A response app makes another app to delay its response for a specific time period
public struct DelayResponse: WebApp {
    public enum Delay {
        case random(min: TimeInterval, max: TimeInterval)
        case delay(seconds: TimeInterval)
        case never
        case none
    }

    public let delay: Delay
    public let delayedApp: WebApp

    public init(_ app: WebApp, delay: Delay = .random(min: 0.1, max: 3)) {
        delayedApp = app
        self.delay = delay
    }

    public func app(
        _ environ: [String: Any],
        startResponse: @escaping ((String, [(String, String)]) -> Void),
        sendBody: @escaping ((Data) -> Void)
    ) {
        var delayTime: TimeInterval!
        switch delay {
        case .none:
            delayedApp.app(environ, startResponse: startResponse, sendBody: sendBody)
            return
        case .never:
            return
        case .delay(let seconds):
            delayTime = seconds
        case .random(let min, let max):
            #if os(Linux)
                srandom(UInt32(time(nil)))
                let randomValue = (Double(random()) / 0x100000000)
            #else
                let randomValue = (Double(arc4random()) / 0x100000000)
            #endif
            delayTime = min + (max - min) * randomValue
        }
        let loop = environ["embassy.event_loop"] as! EventLoop

        let delayedStartResponse = { (status: String, headers: [(String, String)]) in
            loop.call(withDelay: delayTime) {
                startResponse(status, headers)
            }
        }
        let delayedSendBody = { (data: Data) in
            loop.call(withDelay: delayTime) {
                sendBody(data)
            }
        }
        delayedApp.app(environ, startResponse: delayedStartResponse, sendBody: delayedSendBody)
    }
}
