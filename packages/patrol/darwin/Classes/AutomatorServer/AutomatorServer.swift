#if PATROL_ENABLED

  import Foundation

  final class AutomatorServer: MobileAutomatorServer, IosAutomatorServer {

    private let automator: Automator

    private let onAppReady: (Bool) -> Void

    func setupRoutes(server: Server) {
      setupRoutesMobileAutomator(server: server)
      setupRoutesIosAutomator(server: server)
    }

    init(automator: Automator, onAppReady: @escaping (Bool) -> Void) {
      self.automator = automator
      self.onAppReady = onAppReady
    }

    func configure(request: ConfigureRequest) throws {
      automator.configure(timeout: TimeInterval(request.findTimeoutMillis / 1000))
    }

    // MARK: General

    func pressHome() throws {
      return try runCatching {
        try automator.pressHome()
      }
    }

    func pressRecentApps() throws {
      return try runCatching {
        try automator.openAppSwitcher()
      }
    }

    func openApp(request: OpenAppRequest) throws {
      return try runCatching {
        try automator.openApp(request.appId)
      }
    }

    func openPlatformApp(request: OpenPlatformAppRequest) throws {
      return try runCatching {
        guard let appId = request.iosAppId else {
          throw PatrolError.internal("iosAppId must not be null on iOS")
        }
        try automator.openApp(appId)
      }
    }

    func openQuickSettings(request: OpenQuickSettingsRequest) throws {
      return try runCatching {
        try automator.openControlCenter()
      }
    }

    func openUrl(request: OpenUrlRequest) throws {
      return try runCatching {
        try automator.openUrl(request.url)
      }
    }

    // MARK: General UI interaction
    func getNativeViews(
      request: IOSGetNativeViewsRequest
    ) throws -> IOSGetNativeViewsResponse {
      return try runCatching {
        if let selector = request.selector {
          let roots = try automator.getNativeViews(
            on: selector,
            inApp: request.appId
          )
          return IOSGetNativeViewsResponse(roots: roots)
        } else {
          let roots = try automator.getUITreeRoots(installedApps: request.iosInstalledApps ?? [])
          return IOSGetNativeViewsResponse(roots: roots)
        }
      }
    }

    func tap(request: IOSTapRequest) throws {
      return try runCatching {
        return try automator.tap(
            on: request.selector,
            inApp: request.appId,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
      }
    }

    func doubleTap(request: IOSTapRequest) throws {
      return try runCatching {
        return try automator.doubleTap(
            on: request.selector,
            inApp: request.appId,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
      }
    }

    func tapAt(request: IOSTapAtRequest) throws {
      return try runCatching {
        try automator.tapAt(
          coordinate: CGVector(dx: request.x, dy: request.y),
          inApp: request.appId
        )
      }
    }

    func enterText(request: IOSEnterTextRequest) throws {
      return try runCatching {
        if let index = request.index {
          try automator.enterText(
            request.data,
            byIndex: Int(index),
            inApp: request.appId,
            dismissKeyboard: request.keyboardBehavior == .showAndDismiss,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) },
            dx: request.dx ?? 0.9,
            dy: request.dy ?? 0.9
          )
        } else if let selector = request.selector {
          try automator.enterText(
            request.data,
            on: selector,
            inApp: request.appId,
            dismissKeyboard: request.keyboardBehavior == .showAndDismiss,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) },
            dx: request.dx ?? 0.9,
            dy: request.dy ?? 0.9
          )
        } else {
          throw PatrolError.internal("enterText(): neither index nor selector are set")
        }
      }
    }

    func swipe(request: IOSSwipeRequest) throws {
      return try runCatching {
        try automator.swipe(
          from: CGVector(dx: request.startX, dy: request.startY),
          to: CGVector(dx: request.endX, dy: request.endY),
          inApp: request.appId
        )
      }
    }

    func waitUntilVisible(request: IOSWaitUntilVisibleRequest) throws {
      return try runCatching {
        return try automator.waitUntilVisible(
          on: request.selector,
          inApp: request.appId,
          withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
        )
      }
    }

    // MARK: Volume settings
    func pressVolumeUp() throws {
      return try runCatching {
        try automator.pressVolumeUp()
      }
    }

    func pressVolumeDown() throws {
      return try runCatching {
        try automator.pressVolumeDown()
      }
    }

    // MARK: Services

    func enableAirplaneMode() throws {
      return try runCatching {
        try automator.enableAirplaneMode()
      }
    }

    func disableAirplaneMode() throws {
      return try runCatching {
        try automator.disableAirplaneMode()
      }
    }

    func enableWiFi() throws {
      return try runCatching {
        try automator.enableWiFi()
      }
    }

    func disableWiFi() throws {
      return try runCatching {
        try automator.disableWiFi()
      }
    }

    func enableCellular() throws {
      return try runCatching {
        try automator.enableCellular()
      }
    }

    func disableCellular() throws {
      return try runCatching {
        try automator.disableCellular()
      }
    }

    func enableBluetooth() throws {
      return try runCatching {
        try automator.enableBluetooth()
      }
    }

    func disableBluetooth() throws {
      return try runCatching {
        try automator.disableBluetooth()
      }
    }

    func enableDarkMode(request: DarkModeRequest) throws {
      return try runCatching {
        try automator.enableDarkMode(request.appId)
      }
    }

    func disableDarkMode(request: DarkModeRequest) throws {
      return try runCatching {
        try automator.disableDarkMode(request.appId)
      }
    }

    // MARK: Notifications

    func openNotifications() throws {
      return try runCatching {
        try automator.openNotifications()
      }
    }

    func closeNotifications() throws {
      return try runCatching {
        try automator.closeNotifications()
      }
    }

    func closeHeadsUpNotification() throws {
      return try runCatching {
        try automator.closeHeadsUpNotification()
      }
    }

    func getNotifications(
      request: GetNotificationsRequest
    ) throws -> GetNotificationsResponse {
      return try runCatching {
        let notifications = try automator.getNotifications()
        return GetNotificationsResponse(notifications: notifications)
      }
    }

    func tapOnNotification(request: IOSTapOnNotificationRequest) throws {
      return try runCatching {
        if let index = request.index {
          try automator.tapOnNotification(
            byIndex: index,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else if let selector = request.selector {
          try automator.tapOnNotification(
            bySubstring: selector.textContains ?? String(),
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else {
          throw PatrolError.internal("tapOnNotification(): neither index nor selector are set")
        }
      }
    }

    // MARK: Permissions

    func isPermissionDialogVisible(
      request: PermissionDialogVisibleRequest
    ) throws -> PermissionDialogVisibleResponse {
      return try runCatching {
        let visible = try automator.isPermissionDialogVisible(
          timeout: TimeInterval(request.timeoutMillis / 1000)
        )

        return PermissionDialogVisibleResponse(visible: visible)

      }
    }

    func handlePermissionDialog(request: HandlePermissionRequest) throws {
      return try runCatching {
        switch request.code {
        case .whileUsing:
          try automator.allowPermissionWhileUsingApp()
        case .onlyThisTime:
          try automator.allowPermissionOnce()
        case .denied:
          try automator.denyPermission()
        }
      }
    }

    func setLocationAccuracy(request: SetLocationAccuracyRequest) throws {
      return try runCatching {
        switch request.locationAccuracy {
        case .coarse:
          try automator.selectCoarseLocation()
        case .fine:
          try automator.selectFineLocation()
        }
      }
    }

    func setMockLocation(request: SetMockLocationRequest) throws {
      return try runCatching {
        try automator.setMockLocation(latitude: request.latitude, longitude: request.longitude)
      }
    }

    // MARK: Camera

    func takeCameraPhoto(request: IOSTakeCameraPhotoRequest) throws {
      try automator.tap(
        on: request.shutterButtonSelector ?? IOSSelector(identifier: "PhotoCapture"),
        inApp: request.appId,
        withTimeout: TimeInterval(request.timeoutMillis ?? 100000 / 1000)
      )
      try automator.tap(
        on: request.doneButtonSelector ?? IOSSelector(identifier: "Done"),
        inApp: request.appId,
        withTimeout: TimeInterval(request.timeoutMillis ?? 100000 / 1000)
      )
    }

    func pickImageFromGallery(request: IOSPickImageFromGalleryRequest) throws {
      let isSimulator = try isVirtualDevice().isVirtualDevice
      if request.imageSelector != nil {
          try automator.tap(
            on: request.imageSelector!,
            inApp: request.appId,
            withTimeout: TimeInterval(request.timeoutMillis ?? 100000 / 1000)
          )
        } else {
          try automator.tap(
            on: IOSSelector(
                // Images start from index 1 on real device and index 2 on simulator
                instance: isSimulator
                  ? (request.imageIndex ?? 0) + 2 : (request.imageIndex ?? 0) + 1,
                elementType: IOSElementType.image
              ),
            inApp: request.appId,
            withTimeout: TimeInterval(request.timeoutMillis ?? 100000 / 1000)
          )
        }
    }

    func pickMultipleImagesFromGallery(request: IOSPickMultipleImagesFromGalleryRequest) throws {
      return try runCatching {
        let isSimulator = try isVirtualDevice().isVirtualDevice

        // Select multiple images
        for i in request.imageIndexes {
if let imageSelector = request.imageSelector {
              try automator.tap(
                on: imageSelector,
                inApp: request.appId,
                withTimeout: TimeInterval(request.timeoutMillis ?? 100000 / 1000)
              )
            } else {
              try automator.tap(
                on: IOSSelector(
                    // Images start from index 1 on real device and index 2 on simulator
                    instance: isSimulator ? i + 2 : i + 1,
                    elementType: IOSElementType.image
                  ),
                inApp: request.appId,
                withTimeout: TimeInterval(request.timeoutMillis ?? 100000 / 1000)
              )
            }
        }

        // Tap the "Add" button to confirm selection
        try automator.tap(
          on: IOSSelector(
            elementType: IOSElementType.button,
            identifier: "Add"
          ),
          inApp: request.appId,
          withTimeout: TimeInterval(request.timeoutMillis ?? 100000 / 1000)
        )
      }
    }

    func debug() throws {
      return try runCatching {
        try automator.debug()
      }
    }

    private func runCatching<T>(_ block: () throws -> T) throws -> T {
      // TODO: Use an interceptor (like on Android)
      // See: https://github.com/grpc/grpc-swift/issues/1148
      do {
        return try block()
      } catch let err as PatrolError {
        Logger.shared.e(err.description)
        throw err
      } catch let err as LocalizationError {
        let message = err.errorDescription ?? "Localization error"
        Logger.shared.e(message)
        throw PatrolError.localizationError(message)
      } catch let err {
        throw PatrolError.unknown(err)
      }
    }

    func markPatrolAppServiceReady() throws {
      onAppReady(true)
    }

    func isVirtualDevice() throws -> IsVirtualDeviceResponse {
      return try runCatching {
        let isSimulator = automator.isVirtualDevice()
        return IsVirtualDeviceResponse(isVirtualDevice: isSimulator)
      }
    }

    func getOsVersion() throws -> GetOsVersionResponse {
      return try runCatching {
        let version = automator.getOsVersion()
        let components = version.split(separator: ".")
        let majorVersionInt = components.first.flatMap { Int($0) }
        return GetOsVersionResponse(osVersion: majorVersionInt!)
      }
    }

  }
#endif
