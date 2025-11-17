///
//  swift-format-ignore-file
//
//  Generated code. Do not modify.
//  source: schema.dart
//

protocol IosAutomatorServer {
    func getNativeViews(request: IOSGetNativeViewsRequest) throws -> IOSGetNativeViewsResponse
    func tap(request: IOSTapRequest) throws
    func doubleTap(request: IOSTapRequest) throws
    func enterText(request: IOSEnterTextRequest) throws
    func tapAt(request: IOSTapAtRequest) throws
    func waitUntilVisible(request: IOSWaitUntilVisibleRequest) throws
    func swipe(request: IOSSwipeRequest) throws
    func closeHeadsUpNotification() throws
    func tapOnNotification(request: IOSTapOnNotificationRequest) throws
    func isPermissionDialogVisible(request: PermissionDialogVisibleRequest) throws -> PermissionDialogVisibleResponse
    func handlePermissionDialog(request: HandlePermissionRequest) throws
    func setLocationAccuracy(request: SetLocationAccuracyRequest) throws
    func takeCameraPhoto(request: IOSTakeCameraPhotoRequest) throws
    func pickImageFromGallery(request: IOSPickImageFromGalleryRequest) throws
    func pickMultipleImagesFromGallery(request: IOSPickMultipleImagesFromGalleryRequest) throws
    func debug() throws
}

extension IosAutomatorServer {
    private func getNativeViewsHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(IOSGetNativeViewsRequest.self, from: request.body)
        let response = try getNativeViews(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: body)
    }

    private func tapHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(IOSTapRequest.self, from: request.body)
        try tap(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func doubleTapHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(IOSTapRequest.self, from: request.body)
        try doubleTap(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func enterTextHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(IOSEnterTextRequest.self, from: request.body)
        try enterText(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func tapAtHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(IOSTapAtRequest.self, from: request.body)
        try tapAt(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func waitUntilVisibleHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(IOSWaitUntilVisibleRequest.self, from: request.body)
        try waitUntilVisible(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func swipeHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(IOSSwipeRequest.self, from: request.body)
        try swipe(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func closeHeadsUpNotificationHandler(request: HTTPRequest) throws -> HTTPResponse {
        try closeHeadsUpNotification()
        return HTTPResponse(.ok)
    }

    private func tapOnNotificationHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(IOSTapOnNotificationRequest.self, from: request.body)
        try tapOnNotification(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func isPermissionDialogVisibleHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(PermissionDialogVisibleRequest.self, from: request.body)
        let response = try isPermissionDialogVisible(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: body)
    }

    private func handlePermissionDialogHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(HandlePermissionRequest.self, from: request.body)
        try handlePermissionDialog(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func setLocationAccuracyHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(SetLocationAccuracyRequest.self, from: request.body)
        try setLocationAccuracy(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func takeCameraPhotoHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(IOSTakeCameraPhotoRequest.self, from: request.body)
        try takeCameraPhoto(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func pickImageFromGalleryHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(IOSPickImageFromGalleryRequest.self, from: request.body)
        try pickImageFromGallery(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func pickMultipleImagesFromGalleryHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(IOSPickMultipleImagesFromGalleryRequest.self, from: request.body)
        try pickMultipleImagesFromGallery(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func debugHandler(request: HTTPRequest) throws -> HTTPResponse {
        try debug()
        return HTTPResponse(.ok)
    }
}

extension IosAutomatorServer {
    func setupRoutes(server: Server) {
        server.route(.POST, "getNativeViews") {
            request in handleRequest(
                request: request,
                handler: getNativeViewsHandler)
        }
        server.route(.POST, "tap") {
            request in handleRequest(
                request: request,
                handler: tapHandler)
        }
        server.route(.POST, "doubleTap") {
            request in handleRequest(
                request: request,
                handler: doubleTapHandler)
        }
        server.route(.POST, "enterText") {
            request in handleRequest(
                request: request,
                handler: enterTextHandler)
        }
        server.route(.POST, "tapAt") {
            request in handleRequest(
                request: request,
                handler: tapAtHandler)
        }
        server.route(.POST, "waitUntilVisible") {
            request in handleRequest(
                request: request,
                handler: waitUntilVisibleHandler)
        }
        server.route(.POST, "swipe") {
            request in handleRequest(
                request: request,
                handler: swipeHandler)
        }
        server.route(.POST, "closeHeadsUpNotification") {
            request in handleRequest(
                request: request,
                handler: closeHeadsUpNotificationHandler)
        }
        server.route(.POST, "tapOnNotification") {
            request in handleRequest(
                request: request,
                handler: tapOnNotificationHandler)
        }
        server.route(.POST, "isPermissionDialogVisible") {
            request in handleRequest(
                request: request,
                handler: isPermissionDialogVisibleHandler)
        }
        server.route(.POST, "handlePermissionDialog") {
            request in handleRequest(
                request: request,
                handler: handlePermissionDialogHandler)
        }
        server.route(.POST, "setLocationAccuracy") {
            request in handleRequest(
                request: request,
                handler: setLocationAccuracyHandler)
        }
        server.route(.POST, "takeCameraPhoto") {
            request in handleRequest(
                request: request,
                handler: takeCameraPhotoHandler)
        }
        server.route(.POST, "pickImageFromGallery") {
            request in handleRequest(
                request: request,
                handler: pickImageFromGalleryHandler)
        }
        server.route(.POST, "pickMultipleImagesFromGallery") {
            request in handleRequest(
                request: request,
                handler: pickMultipleImagesFromGalleryHandler)
        }
        server.route(.POST, "debug") {
            request in handleRequest(
                request: request,
                handler: debugHandler)
        }
    }
}


extension IosAutomatorServer {
    private func handleRequest(request: HTTPRequest, handler: @escaping (HTTPRequest) throws -> HTTPResponse) -> HTTPResponse {
        do {
            return try handler(request)
        } catch let err {
            return HTTPResponse(.badRequest, headers: [:], error: err)
        }
    }
}

