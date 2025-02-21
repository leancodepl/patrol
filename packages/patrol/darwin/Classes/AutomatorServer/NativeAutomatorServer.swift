///
//  swift-format-ignore-file
//
//  Generated code. Do not modify.
//  source: schema.dart
//

protocol NativeAutomatorServer {
    func initialize() throws
    func configure(request: ConfigureRequest) throws
    func pressHome() throws
    func pressBack() throws
    func pressRecentApps() throws
    func doublePressRecentApps() throws
    func openApp(request: OpenAppRequest) throws
    func openQuickSettings(request: OpenQuickSettingsRequest) throws
    func openUrl(request: OpenUrlRequest) throws
    func getNativeUITree(request: GetNativeUITreeRequest) throws -> GetNativeUITreeRespone
    func getNativeViews(request: GetNativeViewsRequest) throws -> GetNativeViewsResponse
    func tap(request: TapRequest) throws
    func doubleTap(request: TapRequest) throws
    func tapAt(request: TapAtRequest) throws
    func enterText(request: EnterTextRequest) throws
    func swipe(request: SwipeRequest) throws
    func waitUntilVisible(request: WaitUntilVisibleRequest) throws
    func pressVolumeUp() throws
    func pressVolumeDown() throws
    func enableAirplaneMode() throws
    func disableAirplaneMode() throws
    func enableWiFi() throws
    func disableWiFi() throws
    func enableCellular() throws
    func disableCellular() throws
    func enableBluetooth() throws
    func disableBluetooth() throws
    func enableDarkMode(request: DarkModeRequest) throws
    func disableDarkMode(request: DarkModeRequest) throws
    func enableLocation() throws
    func disableLocation() throws
    func openNotifications() throws
    func closeNotifications() throws
    func closeHeadsUpNotification() throws
    func getNotifications(request: GetNotificationsRequest) throws -> GetNotificationsResponse
    func tapOnNotification(request: TapOnNotificationRequest) throws
    func isPermissionDialogVisible(request: PermissionDialogVisibleRequest) throws -> PermissionDialogVisibleResponse
    func handlePermissionDialog(request: HandlePermissionRequest) throws
    func setLocationAccuracy(request: SetLocationAccuracyRequest) throws
    func debug() throws
    func markPatrolAppServiceReady(request: MarkAppAppServiceReadyRequest) throws
}

extension NativeAutomatorServer {
    private func initializeHandler(request: HTTPRequest) throws -> HTTPResponse {
        try initialize()
        return HTTPResponse(.ok)
    }

    private func configureHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(ConfigureRequest.self, from: request.body)
        try configure(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func pressHomeHandler(request: HTTPRequest) throws -> HTTPResponse {
        try pressHome()
        return HTTPResponse(.ok)
    }

    private func pressBackHandler(request: HTTPRequest) throws -> HTTPResponse {
        try pressBack()
        return HTTPResponse(.ok)
    }

    private func pressRecentAppsHandler(request: HTTPRequest) throws -> HTTPResponse {
        try pressRecentApps()
        return HTTPResponse(.ok)
    }

    private func doublePressRecentAppsHandler(request: HTTPRequest) throws -> HTTPResponse {
        try doublePressRecentApps()
        return HTTPResponse(.ok)
    }

    private func openAppHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(OpenAppRequest.self, from: request.body)
        try openApp(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func openQuickSettingsHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(OpenQuickSettingsRequest.self, from: request.body)
        try openQuickSettings(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func openUrlHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(OpenUrlRequest.self, from: request.body)
        try openUrl(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func getNativeUITreeHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(GetNativeUITreeRequest.self, from: request.body)
        let response = try getNativeUITree(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: body)
    }

    private func getNativeViewsHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(GetNativeViewsRequest.self, from: request.body)
        let response = try getNativeViews(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: body)
    }

    private func tapHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(TapRequest.self, from: request.body)
        try tap(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func doubleTapHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(TapRequest.self, from: request.body)
        try doubleTap(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func tapAtHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(TapAtRequest.self, from: request.body)
        try tapAt(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func enterTextHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(EnterTextRequest.self, from: request.body)
        try enterText(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func swipeHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(SwipeRequest.self, from: request.body)
        try swipe(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func waitUntilVisibleHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(WaitUntilVisibleRequest.self, from: request.body)
        try waitUntilVisible(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func pressVolumeUpHandler(request: HTTPRequest) throws -> HTTPResponse {
        try pressVolumeUp()
        return HTTPResponse(.ok)
    }

    private func pressVolumeDownHandler(request: HTTPRequest) throws -> HTTPResponse {
        try pressVolumeDown()
        return HTTPResponse(.ok)
    }

    private func enableAirplaneModeHandler(request: HTTPRequest) throws -> HTTPResponse {
        try enableAirplaneMode()
        return HTTPResponse(.ok)
    }

    private func disableAirplaneModeHandler(request: HTTPRequest) throws -> HTTPResponse {
        try disableAirplaneMode()
        return HTTPResponse(.ok)
    }

    private func enableWiFiHandler(request: HTTPRequest) throws -> HTTPResponse {
        try enableWiFi()
        return HTTPResponse(.ok)
    }

    private func disableWiFiHandler(request: HTTPRequest) throws -> HTTPResponse {
        try disableWiFi()
        return HTTPResponse(.ok)
    }

    private func enableCellularHandler(request: HTTPRequest) throws -> HTTPResponse {
        try enableCellular()
        return HTTPResponse(.ok)
    }

    private func disableCellularHandler(request: HTTPRequest) throws -> HTTPResponse {
        try disableCellular()
        return HTTPResponse(.ok)
    }

    private func enableBluetoothHandler(request: HTTPRequest) throws -> HTTPResponse {
        try enableBluetooth()
        return HTTPResponse(.ok)
    }

    private func disableBluetoothHandler(request: HTTPRequest) throws -> HTTPResponse {
        try disableBluetooth()
        return HTTPResponse(.ok)
    }

    private func enableDarkModeHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(DarkModeRequest.self, from: request.body)
        try enableDarkMode(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func disableDarkModeHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(DarkModeRequest.self, from: request.body)
        try disableDarkMode(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func enableLocationHandler(request: HTTPRequest) throws -> HTTPResponse {
        try enableLocation()
        return HTTPResponse(.ok)
    }

    private func disableLocationHandler(request: HTTPRequest) throws -> HTTPResponse {
        try disableLocation()
        return HTTPResponse(.ok)
    }

    private func openNotificationsHandler(request: HTTPRequest) throws -> HTTPResponse {
        try openNotifications()
        return HTTPResponse(.ok)
    }

    private func closeNotificationsHandler(request: HTTPRequest) throws -> HTTPResponse {
        try closeNotifications()
        return HTTPResponse(.ok)
    }

    private func closeHeadsUpNotificationHandler(request: HTTPRequest) throws -> HTTPResponse {
        try closeHeadsUpNotification()
        return HTTPResponse(.ok)
    }

    private func getNotificationsHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(GetNotificationsRequest.self, from: request.body)
        let response = try getNotifications(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: body)
    }

    private func tapOnNotificationHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(TapOnNotificationRequest.self, from: request.body)
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

    private func debugHandler(request: HTTPRequest) throws -> HTTPResponse {
        try debug()
        return HTTPResponse(.ok)
    }

    private func markPatrolAppServiceReadyHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(MarkAppAppServiceReadyRequest.self, from: request.body)
        try markPatrolAppServiceReady(request: requestArg)
        return HTTPResponse(.ok)
    }
}

extension NativeAutomatorServer {
    func setupRoutes(server: Server) {
        server.route(.POST, "initialize") {
            request in handleRequest(
                request: request,
                handler: initializeHandler)
        }
        server.route(.POST, "configure") {
            request in handleRequest(
                request: request,
                handler: configureHandler)
        }
        server.route(.POST, "pressHome") {
            request in handleRequest(
                request: request,
                handler: pressHomeHandler)
        }
        server.route(.POST, "pressBack") {
            request in handleRequest(
                request: request,
                handler: pressBackHandler)
        }
        server.route(.POST, "pressRecentApps") {
            request in handleRequest(
                request: request,
                handler: pressRecentAppsHandler)
        }
        server.route(.POST, "doublePressRecentApps") {
            request in handleRequest(
                request: request,
                handler: doublePressRecentAppsHandler)
        }
        server.route(.POST, "openApp") {
            request in handleRequest(
                request: request,
                handler: openAppHandler)
        }
        server.route(.POST, "openQuickSettings") {
            request in handleRequest(
                request: request,
                handler: openQuickSettingsHandler)
        }
        server.route(.POST, "openUrl") {
            request in handleRequest(
                request: request,
                handler: openUrlHandler)
        }
        server.route(.POST, "getNativeUITree") {
            request in handleRequest(
                request: request,
                handler: getNativeUITreeHandler)
        }
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
        server.route(.POST, "tapAt") {
            request in handleRequest(
                request: request,
                handler: tapAtHandler)
        }
        server.route(.POST, "enterText") {
            request in handleRequest(
                request: request,
                handler: enterTextHandler)
        }
        server.route(.POST, "swipe") {
            request in handleRequest(
                request: request,
                handler: swipeHandler)
        }
        server.route(.POST, "waitUntilVisible") {
            request in handleRequest(
                request: request,
                handler: waitUntilVisibleHandler)
        }
        server.route(.POST, "pressVolumeUp") {
            request in handleRequest(
                request: request,
                handler: pressVolumeUpHandler)
        }
        server.route(.POST, "pressVolumeDown") {
            request in handleRequest(
                request: request,
                handler: pressVolumeDownHandler)
        }
        server.route(.POST, "enableAirplaneMode") {
            request in handleRequest(
                request: request,
                handler: enableAirplaneModeHandler)
        }
        server.route(.POST, "disableAirplaneMode") {
            request in handleRequest(
                request: request,
                handler: disableAirplaneModeHandler)
        }
        server.route(.POST, "enableWiFi") {
            request in handleRequest(
                request: request,
                handler: enableWiFiHandler)
        }
        server.route(.POST, "disableWiFi") {
            request in handleRequest(
                request: request,
                handler: disableWiFiHandler)
        }
        server.route(.POST, "enableCellular") {
            request in handleRequest(
                request: request,
                handler: enableCellularHandler)
        }
        server.route(.POST, "disableCellular") {
            request in handleRequest(
                request: request,
                handler: disableCellularHandler)
        }
        server.route(.POST, "enableBluetooth") {
            request in handleRequest(
                request: request,
                handler: enableBluetoothHandler)
        }
        server.route(.POST, "disableBluetooth") {
            request in handleRequest(
                request: request,
                handler: disableBluetoothHandler)
        }
        server.route(.POST, "enableDarkMode") {
            request in handleRequest(
                request: request,
                handler: enableDarkModeHandler)
        }
        server.route(.POST, "disableDarkMode") {
            request in handleRequest(
                request: request,
                handler: disableDarkModeHandler)
        }
        server.route(.POST, "enableLocation") {
            request in handleRequest(
                request: request,
                handler: enableLocationHandler)
        }
        server.route(.POST, "disableLocation") {
            request in handleRequest(
                request: request,
                handler: disableLocationHandler)
        }
        server.route(.POST, "openNotifications") {
            request in handleRequest(
                request: request,
                handler: openNotificationsHandler)
        }
        server.route(.POST, "closeNotifications") {
            request in handleRequest(
                request: request,
                handler: closeNotificationsHandler)
        }
        server.route(.POST, "closeHeadsUpNotification") {
            request in handleRequest(
                request: request,
                handler: closeHeadsUpNotificationHandler)
        }
        server.route(.POST, "getNotifications") {
            request in handleRequest(
                request: request,
                handler: getNotificationsHandler)
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
        server.route(.POST, "debug") {
            request in handleRequest(
                request: request,
                handler: debugHandler)
        }
        server.route(.POST, "markPatrolAppServiceReady") {
            request in handleRequest(
                request: request,
                handler: markPatrolAppServiceReadyHandler)
        }
    }
}


extension NativeAutomatorServer {
    private func handleRequest(request: HTTPRequest, handler: @escaping (HTTPRequest) throws -> HTTPResponse) -> HTTPResponse {
        do {
            return try handler(request)
        } catch let err {
            return HTTPResponse(.badRequest, headers: [:], error: err)
        }
    }
}

