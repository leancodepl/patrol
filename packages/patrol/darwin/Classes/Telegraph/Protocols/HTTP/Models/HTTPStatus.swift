//
//  HTTPStatus.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/30/17.
//  Copyright © 2017 Building42. All rights reserved.
//
//  For more information see:
//  https://httpwg.org/specs/rfc7231.html#status.codes
//  https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
//

public struct HTTPStatus: Hashable {
  /// The numeric code of the status (e.g. 404).
  public let code: Int

  /// The phrase describing the status (e.g. "Not Found").
  public let phrase: String

  /// Indicates if the status is compared on code and phrase (true) or code only (false).
  public let strict: Bool

  /// Creates a HTTPStatus.
  /// - Parameter code: The numeric code of the status (e.g. 404)
  /// - Parameter phrase: The phrase describing the status (e.g. "Not Found").
  /// - Parameter strict: The status is compared on code and phrase (true) or code only (false).
  public init(code: Int, phrase: String, strict: Bool = false) {
    self.code = code
    self.phrase = phrase
    self.strict = strict
  }
}

// MARK: Variables

public extension HTTPStatus {
  /// Indicates if the status is used for informational purposes.
  var isInformational: Bool {
    return code >= 100 && code < 200
  }

  /// Indicates if the status describes a succesful operation.
  var isSuccess: Bool {
    return code >= 200 && code < 300
  }

  /// Indicates if the status describes a redirection.
  var isRedirection: Bool {
    return code >= 300 && code < 400
  }
  /// Indicates if the status describes a client error.
  var isClientError: Bool {
    return code >= 400 && code < 500
  }
  /// Indicates if the status describes a server error.
  var isServerError: Bool {
    return code >= 500 && code < 600
  }

  /// Indicates if the message should have a body when this status is used.
  var supportsBody: Bool {
    return !isInformational && self != .noContent && self != .notModified
  }
}

// MARK: Equatable implementation

public extension HTTPStatus {
  static func == (lhs: HTTPStatus, rhs: HTTPStatus) -> Bool {
    if lhs.code != rhs.code { return false }
    if lhs.strict == false && rhs.strict == false { return true }
    return lhs.phrase == rhs.phrase
  }
}

// MARK: CustomStringConvertible implementation

extension HTTPStatus: CustomStringConvertible {
  public var description: String {
    return "\(code) \(phrase)"
  }
}

// MARK: - Status: Informational

public extension HTTPStatus {
  /// 100 Continue: the server has received the request headers and the client should proceed to send the request body.
  static let `continue` = HTTPStatus(code: 100, phrase: "Continue")

  /// 101 Switching Protocols: requester has asked the server to switch protocols and the server has agreed to do so.
  static let switchingProtocols = HTTPStatus(code: 101, phrase: "Switching Protocols")

  /// 102 Processing: server has received and is processing the request, but no response is available yet.
  static let processing = HTTPStatus(code: 102, phrase: "Processing")
}

// MARK: - Status: Success

public extension HTTPStatus {
  /// 200 OK: standard response for successful HTTP requests.
  static let ok = HTTPStatus(code: 200, phrase: "OK")

  /// 201 Created: request has been fulfilled, resulting in the creation of a new resource.
  static let created = HTTPStatus(code: 201, phrase: "Created")

  /// 202 Accepted: request has been accepted for processing, but the processing has not been completed.
  static let accepted = HTTPStatus(code: 202, phrase: "Accepted")

  /// 203 Non-Authoritative Information: server is a transforming proxy that received a 200 OK from its origin,
  /// but is returning a modified version of the origin's response.
  static let nonAuthoritativeInformation = HTTPStatus(code: 203, phrase: "Non-Authoritative Information")

  /// 204 No Content: server successfully processed the request and is not returning any content.
  static let noContent = HTTPStatus(code: 204, phrase: "No Content")

  /// 205 Reset Content: same as 204 No Content, but requires the requester to reset the document view.
  static let resetContent = HTTPStatus(code: 205, phrase: "Reset Content")

  /// 206 Partial Content: server is delivering only part of the resource due to a range header sent by the client.
  static let partialContent = HTTPStatus(code: 206, phrase: "Partial Content")

  /// 207 Multi-Status: message body that follows is by default an XML message and can contain a number of separate
  /// response codes, depending on how many sub-requests were made.
  static let multiStatus = HTTPStatus(code: 207, phrase: "Multi-Status")

  /// 208 Already Reported: members of a DAV binding have already been enumerated in a preceding part of
  /// the (multistatus) response, and are not being included again.
  static let alreadyReported = HTTPStatus(code: 208, phrase: "Already Reported")

  /// 226 IM Used: server has fulfilled a request for the resource, and the response is a representation of
  /// the result of one or more instance-manipulations applied to the current instance.
  static let imUsed = HTTPStatus(code: 226, phrase: "IM Used")
}

// MARK: - Status: Redirection

public extension HTTPStatus {
  /// 300 Multiple Choices: indicates multiple options for the resource from which the client may
  /// choose via agent-driven content negotiation.
  static let multipleChoices = HTTPStatus(code: 300, phrase: "Multiple Choices")

  /// 301 Moved Permanently: this and all future requests should be directed to the given URI.
  static let movedPermanently = HTTPStatus(code: 301, phrase: "Moved Permanently")

  /// 302 Found: tells the client to browse to another url. 302 has been superseded by 303 and 307.
  static let found = HTTPStatus(code: 302, phrase: "Found")

  /// 303 See Other: response to the request can be found under another URI using the GET method.
  static let seeOther = HTTPStatus(code: 303, phrase: "See Other")

  /// 304 Not Modified: the resource has not been modified since the version specified by the request
  /// headers If-Modified-Since or If-None-Match.
  static let notModified = HTTPStatus(code: 304, phrase: "Not Modified")

  /// 305 Use Proxy: resource is available only through a proxy, the address is provided in the response.
  static let useProxy = HTTPStatus(code: 305, phrase: "Use Proxy")

  /// 307 Temporary Redirect: request should be repeated with another URI; however, future requests
  /// should still use the original URI.
  static let temporaryRedirect = HTTPStatus(code: 307, phrase: "Temporary Redirect")

  /// 308 Permanent Redirect: request and all future requests should be repeated using another URI.
  /// 307 and 308 parallel the behaviors of 302 and 301, but do not allow the HTTP method to change.
  static let permanentRedirect = HTTPStatus(code: 308, phrase: "Permanent Redirect")
}

// MARK: - Status: Client Errors

public extension HTTPStatus {
  /// 400 Bad Request: server cannot or will not process the request due to an apparent client error.
  static let badRequest = HTTPStatus(code: 400, phrase: "Bad Request")

  /// 401 Unauthorized: similar to 403 Forbidden, but specifically for use when authentication is
  /// required and has failed or has not yet been provided.
  static let unauthorized = HTTPStatus(code: 401, phrase: "Unauthorized")

  /// 402 Payment Required: reserved for future use, can be used to signal that the resource is
  /// temporarily not available because fees have not been paid.
  static let paymentRequired = HTTPStatus(code: 402, phrase: "Payment Required")

  /// 403 Forbidden: request was valid, but the server is refusing action. The user might not
  /// have the necessary permissions for a resource, or may need an account of some sort.
  static let forbidden = HTTPStatus(code: 403, phrase: "Forbidden")

  /// 404 Not Found: requested resource could not be found but may be available in the future.
  static let notFound = HTTPStatus(code: 404, phrase: "Not Found")

  /// 405 Method Not Allowed: request method is not supported for the requested resource.
  static let methodNotAllowed = HTTPStatus(code: 405, phrase: "Method Not Allowed")

  /// 406 Not Acceptable: equested resource is capable of generating only content not acceptable
  /// according to the Accept headers sent in the request.
  static let notAcceptable = HTTPStatus(code: 406, phrase: "Not Acceptable")

  /// 407 Proxy Authentication Required: client must first authenticate itself with the proxy.
  static let proxyAuthenticationRequired = HTTPStatus(code: 407, phrase: "Proxy Authentication Required")

  /// 408 Request Timneout: server timed out waiting for the request.
  static let requestTimeout = HTTPStatus(code: 408, phrase: "Request Timeout")

  /// 409 Conflict: the request could not be processed because of conflict in the current state
  /// of the resource. such as an edit conflict between multiple simultaneous updates.
  static let conflict = HTTPStatus(code: 409, phrase: "Conflict")

  /// 410 Gone: the resource requested is no longer available and will not be available again.
  static let gone = HTTPStatus(code: 410, phrase: "Gone")

  /// 411 Length Required: request did not specify the length of its content, which is
  /// required by the requested resource.
  static let lengthRequired = HTTPStatus(code: 411, phrase: "Length Required")

  /// 412 Precondition Failed: server does not meet one of the preconditions that the requester put on the request.
  static let preconditionFailed = HTTPStatus(code: 412, phrase: "Precondition Failed")

  /// 413 Payload Too Large: request is larger than the server is willing or able to process.
  static let payloadTooLarge = HTTPStatus(code: 413, phrase: "Payload Too Large")

  /// 414 URI Too Long: the URI provided was too long for the server to process.
  static let uriTooLong = HTTPStatus(code: 414, phrase: "URI Too Long")

  /// 415 Unsupported Media Type: request entity has a media type which the server or resource does not support.
  static let unsupportedMediaType = HTTPStatus(code: 415, phrase: "Unsupported Media Type")

  /// 416 Range Not Satisfiable: client has asked for a portion of the file, but the server cannot
  /// supply that portion.
  static let rangeNotSatisfiable = HTTPStatus(code: 416, phrase: "Range Not Satisfiable")

  /// 417 Expectation Failed: server cannot meet the requirements of the Expect request-header field.
  static let expectationFailed = HTTPStatus(code: 417, phrase: "Expectation Failed")

  /// 421 Misdirected Request: request was directed at a server that is not able to produce a response
  /// (for example because of connection reuse).
  static let misdirectedRequest = HTTPStatus(code: 421, phrase: "Misdirected Request")

  /// 422 Unprocessable Entity: request was well-formed but was unable to be followed due to semantic errors.
  static let unprocessableEntity = HTTPStatus(code: 422, phrase: "Unprocessable Entity")

  /// 423 Locked: resource that is being accessed is locked.
  static let locked = HTTPStatus(code: 423, phrase: "Locked")

  /// 424 Failed Dependency: request failed because it depended on another request and that request failed.
  static let failedDependency = HTTPStatus(code: 424, phrase: "Failed Dependency")

  /// 426 Upgrade Required: client should switch to the protocol specified by the Upgrade header field.
  static let upgradeRequired = HTTPStatus(code: 426, phrase: "Upgrade Required")

  /// 428 Precondition Required: origin server requires the request to be conditional. Intended to prevent
  /// the 'lost update' problem, where a client GETs a resource's state, modifies it, and PUTs it back to
  /// the server, when meanwhile a third party has modified the state on the server, leading to a conflict.
  static let preconditionRequired = HTTPStatus(code: 428, phrase: "Precondition Required")

  /// 429 Too Many Requests: user has sent too many requests in a given amount of time. Intended for use
  /// with rate-limiting schemes.
  static let tooManyRequests = HTTPStatus(code: 429, phrase: "Too Many Requests")

  /// 431 Request Header Fields Too Large: server is unwilling to process the request because either an
  /// individual header field, or all the header fields collectively, are too large.
  static let requestHeaderFieldsTooLarge = HTTPStatus(code: 431, phrase: "Request Header Fields Too Large")

  /// 451 Unavailable For Legal Reasons: server operator has received a legal demand to deny access to
  /// a resource or to a set of resources that includes the requested resource.
  static let unavailableForLegalReasons = HTTPStatus(code: 451, phrase: "Unavailable For Legal Reasons")
}

// MARK: - Status: Server Errors

public extension HTTPStatus {
  /// 500 Internal Server Error: generic error message, given when an unexpected condition was encountered
  /// and no more specific message is suitable
  static let internalServerError = HTTPStatus(code: 500, phrase: "Internal Server Error")

  /// 501 Not Implemented: server either does not recognize the request method, or it lacks the ability
  /// to fulfil the request.
  static let notImplemented = HTTPStatus(code: 501, phrase: "Not Implemented")

  /// 502 Bad Gateway: server was acting as a gateway or proxy and received an invalid response
  /// from the upstream server.
  static let badGateway = HTTPStatus(code: 502, phrase: "Bad Gateway")

  /// 503 Service Unavailable: server is currently unavailable (e.g. overloaded or down for maintenance).
  static let serviceUnavailable = HTTPStatus(code: 503, phrase: "Service Unavailable")

  /// 504 Gateway Timeout: server was acting as a gateway or proxy and did not receive a timely response
  /// from the upstream server.
  static let gatewayTimeout = HTTPStatus(code: 504, phrase: "Gateway Timeout")

  /// 505 HTTP Version Not Supported: server does not support the HTTP protocol version used in the request.
  static let httpVersionNotSupported = HTTPStatus(code: 505, phrase: "HTTP Version Not Supported")

  /// 506 Vairant Also Negotiates: transparent content negotiation for the request results in a circular reference.
  static let variantAlsoNegotiates = HTTPStatus(code: 506, phrase: "Variant Also Negotiates")

  /// 507 Insufficient Storage: server is unable to store the representation needed to complete the request.
  static let insufficientStorage = HTTPStatus(code: 507, phrase: "Insufficient Storage")

  /// 508 Loop Detected: server detected an infinite loop while processing the request.
  static let loopDetected = HTTPStatus(code: 508, phrase: "Loop Detected")

  /// 510 Not Extended: further extensions to the request are required for the server to fulfill it.
  static let notExtended = HTTPStatus(code: 510, phrase: "Not Extended")

  /// 511 Network Authentication Required: client needs to authenticate to gain network access.
  /// Intended for use by intercepting proxies used to control access to the network.
  static let networkAuthenticationRequired = HTTPStatus(code: 511, phrase: "Network Authentication Required")
}
