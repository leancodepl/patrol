//
//  SWGIWebApp.swift
//  Ambassador
//
//  Created by Fang-Pen Lin on 6/30/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

import Embassy

/// SWGIWebApp is a WebApp for building web app with any SWSGI handler
public struct SWGIWebApp: WebApp {
    private let handler: SWSGI
    public init(handler: @escaping SWSGI) {
        self.handler = handler
    }

    public func app(
        _ environ: [String: Any],
        startResponse: @escaping ((String, [(String, String)]) -> Void),
        sendBody: @escaping ((Data) -> Void)
    ) {
        handler(environ, startResponse, sendBody)
    }
}
