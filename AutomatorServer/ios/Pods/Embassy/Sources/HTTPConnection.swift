//
//  HTTPConnection.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 5/21/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

/// HTTPConnection represents an active HTTP connection
public final class HTTPConnection {
    enum RequestState {
        case parsingHeader
        case readingBody
    }

    enum ResponseState {
        case sendingHeader
        case sendingBody
    }

    public let logger = DefaultLogger()
    public let uuid: String = UUID().uuidString
    public let transport: Transport
    public let app: SWSGI
    public let serverName: String
    public let serverPort: Int
    /// Callback to be called when this connection closed
    var closedCallback: (() -> Void)?

    private(set) var requestState: RequestState = .parsingHeader
    private(set) var responseState: ResponseState = .sendingHeader
    private(set) public var eventLoop: EventLoop!
    private var headerParser: HTTPHeaderParser!
    private var headerElements: [HTTPHeaderParser.Element] = []
    private var request: HTTPRequest!
    private var initialBody: Data?
    private var inputHandler: ((Data) -> Void)?
    // total content length to read
    private var contentLength: Int?
    // total data bytes we've already read
    private var readDataLength: Int = 0

    public init(
        app: @escaping SWSGI,
        serverName: String,
        serverPort: Int,
        transport: Transport,
        eventLoop: EventLoop,
        logger: Logger,
        closedCallback: (() -> Void)? = nil
    ) {
        self.app = app
        self.serverName = serverName
        self.serverPort = serverPort
        self.transport = transport
        self.eventLoop = eventLoop
        self.closedCallback = closedCallback

        transport.readDataCallback = handleDataReceived
        transport.closedCallback = handleConnectionClosed

        let propagateHandler = PropagateLogHandler(logger: logger)
        let contextHandler = TransformLogHandler(
            handler: propagateHandler
        ) { [unowned self] record in
            return record.overwriteMessage { [unowned self] in"[\(self.uuid)] \($0.message)" }
        }
        self.logger.add(handler: contextHandler)
    }

    public func close() {
        transport.close()
    }

    // called to handle data received
    private func handleDataReceived(_ data: Data) {
        switch requestState {
        case .parsingHeader:
            handleHeaderData(data)
        case .readingBody:
            handleBodyData(data)
        }
    }

    // called to handle header data
    private func handleHeaderData(_ data: Data) {
        if headerParser == nil {
            headerParser = HTTPHeaderParser()
        }
        headerElements += headerParser.feed(data)
        // we only handle when there are elements in header parser
        guard let lastElement = headerElements.last else {
            return
        }
        // we only handle the it when we get the end of header
        guard case .end = lastElement else {
            return
        }

        var method: String!
        var path: String!
        var version: String!
        var headers: [(String, String)] = []
        for element in headerElements {
            switch element {
            case .head(let headMethod, let headPath, let headVersion):
                method = headMethod
                path = headPath
                version = headVersion
            case .header(let key, let value):
                headers.append((key, value))
            case .end(let bodyPart):
                initialBody = bodyPart
            }
        }
        logger.info(
            "Header parsed, method=\(method!), path=\(path.debugDescription), " +
            "version=\(version.debugDescription), headers=\(headers)"
        )
        request = HTTPRequest(
            method: HTTPRequest.Method.fromString(method),
            path: path,
            version: version,
            headers: headers
        )
        var environ = SWSGIUtils.environFor(request: request)
        environ["SERVER_NAME"] = serverName
        environ["SERVER_PORT"] = String(serverPort)
        environ["SERVER_PROTOCOL"] = "HTTP/1.1"

        // set SWSGI keys
        environ["swsgi.version"] = "0.1"
        environ["swsgi.url_scheme"] = "http"
        environ["swsgi.input"] = swsgiInput
        // TODO: add output file for error
        environ["swsgi.error"] = ""
        environ["swsgi.multithread"] = false
        environ["swsgi.multiprocess"] = false
        environ["swsgi.run_once"] = false

        // set embassy specific keys
        environ["embassy.connection"] = self
        environ["embassy.event_loop"] = eventLoop

        if
            let bundle = Bundle(identifier: "com.envoy.Embassy"),
            let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        {
            environ["embassy.version"] = version
        } else {
            // TODO: not sure what's the method we can use to get current package version for Linux,
            // just put unknown here to make test pass for now
            environ["embassy.version"] = "unknown"
        }

        if let contentLength = request.headers["Content-Length"], let length = Int(contentLength) {
            self.contentLength = length
        }

        // change state for incoming request to
        requestState = .readingBody
        // pause the reading for now, let `swsgi.input` called and resume it later
        transport.resume(reading: false)

        app(environ, startResponse, sendBody)
    }

    private func swsgiInput(_ handler: ((Data) -> Void)?) {
        inputHandler = handler
        // reading handler provided
        if handler != nil {
            if let initialBody = initialBody {
                if !initialBody.isEmpty {
                    handleBodyData(initialBody)
                }
                self.initialBody = nil
            }
            transport.resume(reading: true)
            logger.info("Resume reading")
        // if the input handler is set to nil, it means pause reading
        } else {
            logger.info("Pause reading")
            transport.resume(reading: false)
        }
    }

    private func handleBodyData(_ data: Data) {
        guard let handler = inputHandler else {
            fatalError("Not suppose to read body data when input handler is not provided")
        }
        handler(data)
        readDataLength += data.count
        // we finish reading all the content, send EOF to input handler
        if let length = contentLength, readDataLength >= length {
            handler(Data())
            inputHandler = nil
        }
    }

    private func startResponse(_ status: String, headers: [(String, String)]) {
        guard case .sendingHeader = responseState else {
            logger.error("Response is not ready for sending header")
            return
        }
        var headers = headers
        let headerList = MultiDictionary<String, String, LowercaseKeyTransform>(items: headers)
        // we don't support keep-alive connection for now, just force it to be closed
        if headerList["Connection"] == nil {
            headers.append(("Connection", "close"))
        }
        if headerList["Server"] == nil {
            headers.append(("Server", "Embassy"))
        }
        logger.debug("Start response, status=\(status.debugDescription), headers=\(headers.debugDescription)")
        let headersPart = headers.map { (key, value) in
            return "\(key): \(value)"
        }.joined(separator: "\r\n")
        let parts = [
            "HTTP/1.1 \(status)",
            headersPart,
            "\r\n"
        ]
        transport.write(string: parts.joined(separator: "\r\n"))
        responseState = .sendingBody
    }

    private func sendBody(_ data: Data) {
        guard case .sendingBody = responseState else {
            logger.error("Response is not ready for sending body")
            return
        }
        guard data.count > 0 else {
            // TODO: support keep-alive connection here?
            logger.info("Finish response")
            transport.close()
            return
        }
        transport.write(data: data)
    }

    // called to handle connection closed
    private func handleConnectionClosed(_ reason: Transport.CloseReason) {
        logger.info("Connection closed, reason=\(reason)")
        close()
        if let handler = inputHandler {
            handler(Data())
            inputHandler = nil
        }
        if let callback = closedCallback {
            callback()
        }
    }
}

extension HTTPConnection: Equatable {
}

public func == (lhs: HTTPConnection, rhs: HTTPConnection) -> Bool {
    return lhs.uuid == rhs.uuid
}

extension HTTPConnection: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
