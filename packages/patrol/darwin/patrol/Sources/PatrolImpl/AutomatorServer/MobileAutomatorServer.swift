///
//  swift-format-ignore-file
//
//  Generated code. Do not modify.
//  source: schema.dart
//

import Foundation

protocol MobileAutomatorServer {
    func configure(request: ConfigureRequest) throws
    func pressHome() throws
    func pressRecentApps() throws
    func openApp(request: OpenAppRequest) throws
    func openQuickSettings(request: OpenQuickSettingsRequest) throws
    func openUrl(request: OpenUrlRequest) throws
    func sendKeyboardEnter() throws
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
    func openNotifications() throws
    func closeNotifications() throws
    func getNotifications(request: GetNotificationsRequest) throws -> GetNotificationsResponse
    func isPermissionDialogVisible(request: PermissionDialogVisibleRequest) throws -> PermissionDialogVisibleResponse
    func handlePermissionDialog(request: HandlePermissionRequest) throws
    func setLocationAccuracy(request: SetLocationAccuracyRequest) throws
    func takeCameraPhoto(request: TakeCameraPhotoRequest) throws
    func pickImageFromGallery(request: PickImageFromGalleryRequest) throws
    func pickMultipleImagesFromGallery(request: PickMultipleImagesFromGalleryRequest) throws
    func axeInitSession(request: AxeInitSessionRequest) throws
    func axeScan(request: AxeScanRequest) throws
    func axeGetResult(request: AxeGetResultRequest) throws -> AxeGetResultResponse
    func axeIgnoreRules(request: AxeIgnoreRulesRequest) throws
    func axeIgnoreByViewIdResourceName(request: AxeIgnoreByViewIdResourceNameRequest) throws
    func axeIgnoreExperimental() throws
    func axeTearDown() throws
    func axeDeleteResult(request: AxeDeleteResultRequest) throws
    func debug() throws
    func setMockLocation(request: SetMockLocationRequest) throws
    func stopMockLocation() throws
    func markPatrolAppServiceReady() throws
    func isVirtualDevice() throws -> IsVirtualDeviceResponse
    func getOsVersion() throws -> GetOsVersionResponse
}

extension MobileAutomatorServer {
    private func configureHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(ConfigureRequest.self, from: request.body)
        try configure(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func pressHomeHandler(request: HTTPRequest) throws -> HTTPResponse {
        try pressHome()
        return HTTPResponse(.ok)
    }

    private func pressRecentAppsHandler(request: HTTPRequest) throws -> HTTPResponse {
        try pressRecentApps()
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

    private func sendKeyboardEnterHandler(request: HTTPRequest) throws -> HTTPResponse {
        try sendKeyboardEnter()
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

    private func openNotificationsHandler(request: HTTPRequest) throws -> HTTPResponse {
        try openNotifications()
        return HTTPResponse(.ok)
    }

    private func closeNotificationsHandler(request: HTTPRequest) throws -> HTTPResponse {
        try closeNotifications()
        return HTTPResponse(.ok)
    }

    private func getNotificationsHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(GetNotificationsRequest.self, from: request.body)
        let response = try getNotifications(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: body)
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
        let requestArg = try JSONDecoder().decode(TakeCameraPhotoRequest.self, from: request.body)
        try takeCameraPhoto(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func pickImageFromGalleryHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(PickImageFromGalleryRequest.self, from: request.body)
        try pickImageFromGallery(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func pickMultipleImagesFromGalleryHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(PickMultipleImagesFromGalleryRequest.self, from: request.body)
        try pickMultipleImagesFromGallery(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func axeInitSessionHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(AxeInitSessionRequest.self, from: request.body)
        try axeInitSession(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func axeScanHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(AxeScanRequest.self, from: request.body)
        try axeScan(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func axeGetResultHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(AxeGetResultRequest.self, from: request.body)
        let response = try axeGetResult(request: requestArg)
        let responseData = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: responseData)
    }

    private func axeIgnoreRulesHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(AxeIgnoreRulesRequest.self, from: request.body)
        try axeIgnoreRules(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func axeIgnoreByViewIdResourceNameHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(AxeIgnoreByViewIdResourceNameRequest.self, from: request.body)
        try axeIgnoreByViewIdResourceName(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func axeIgnoreExperimentalHandler(request: HTTPRequest) throws -> HTTPResponse {
        try axeIgnoreExperimental()
        return HTTPResponse(.ok)
    }

    private func axeTearDownHandler(request: HTTPRequest) throws -> HTTPResponse {
        try axeTearDown()
        return HTTPResponse(.ok)
    }

    private func axeDeleteResultHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(AxeDeleteResultRequest.self, from: request.body)
        try axeDeleteResult(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func debugHandler(request: HTTPRequest) throws -> HTTPResponse {
        try debug()
        return HTTPResponse(.ok)
    }

    private func setMockLocationHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(SetMockLocationRequest.self, from: request.body)
        try setMockLocation(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func stopMockLocationHandler(request: HTTPRequest) throws -> HTTPResponse {
        try stopMockLocation()
        return HTTPResponse(.ok)
    }

    private func markPatrolAppServiceReadyHandler(request: HTTPRequest) throws -> HTTPResponse {
        try markPatrolAppServiceReady()
        return HTTPResponse(.ok)
    }

    private func isVirtualDeviceHandler(request: HTTPRequest) throws -> HTTPResponse {
        let response = try isVirtualDevice()
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: body)
    }

    private func getOsVersionHandler(request: HTTPRequest) throws -> HTTPResponse {
        let response = try getOsVersion()
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: body)
    }
}

extension MobileAutomatorServer {
    func setupRoutesMobileAutomator(server: Server) {
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
        server.route(.POST, "pressRecentApps") {
            request in handleRequest(
                request: request,
                handler: pressRecentAppsHandler)
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
        server.route(.POST, "sendKeyboardEnter") {
            request in handleRequest(
                request: request,
                handler: sendKeyboardEnterHandler)
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
        server.route(.POST, "getNotifications") {
            request in handleRequest(
                request: request,
                handler: getNotificationsHandler)
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
        server.route(.POST, "axeInitSession") {
            request in handleRequest(
                request: request,
                handler: axeInitSessionHandler)
        }
        server.route(.POST, "axeScan") {
            request in handleRequest(
                request: request,
                handler: axeScanHandler)
        }
        server.route(.POST, "axeGetResult") {
            request in handleRequest(
                request: request,
                handler: axeGetResultHandler)
        }
        server.route(.POST, "axeIgnoreRules") {
            request in handleRequest(
                request: request,
                handler: axeIgnoreRulesHandler)
        }
        server.route(.POST, "axeIgnoreByViewIdResourceName") {
            request in handleRequest(
                request: request,
                handler: axeIgnoreByViewIdResourceNameHandler)
        }
        server.route(.POST, "axeIgnoreExperimental") {
            request in handleRequest(
                request: request,
                handler: axeIgnoreExperimentalHandler)
        }
        server.route(.POST, "axeTearDown") {
            request in handleRequest(
                request: request,
                handler: axeTearDownHandler)
        }
        server.route(.POST, "axeDeleteResult") {
            request in handleRequest(
                request: request,
                handler: axeDeleteResultHandler)
        }
        server.route(.POST, "debug") {
            request in handleRequest(
                request: request,
                handler: debugHandler)
        }
        server.route(.POST, "setMockLocation") {
            request in handleRequest(
                request: request,
                handler: setMockLocationHandler)
        }
        server.route(.POST, "stopMockLocation") {
            request in handleRequest(
                request: request,
                handler: stopMockLocationHandler)
        }
        server.route(.POST, "markPatrolAppServiceReady") {
            request in handleRequest(
                request: request,
                handler: markPatrolAppServiceReadyHandler)
        }
        server.route(.POST, "isVirtualDevice") {
            request in handleRequest(
                request: request,
                handler: isVirtualDeviceHandler)
        }
        server.route(.POST, "getOsVersion") {
            request in handleRequest(
                request: request,
                handler: getOsVersionHandler)
        }
    }
}


extension MobileAutomatorServer {
    private func handleRequest(request: HTTPRequest, handler: @escaping (HTTPRequest) throws -> HTTPResponse) -> HTTPResponse {
        do {
            return try handler(request)
        } catch let err {
            return HTTPResponse(.badRequest, headers: [:], error: err)
        }
    }
}

