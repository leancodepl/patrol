#if PATROL_ENABLED

  import Foundation

  final class AutomatorServer: NativeAutomatorServer {
    private let automator: Automator

    private let onAppReady: (Bool) -> Void

    init(automator: Automator, onAppReady: @escaping (Bool) -> Void) {
      self.automator = automator
      self.onAppReady = onAppReady
    }

    func initialize() throws {}

    func configure(request: ConfigureRequest) throws {
      automator.configure(timeout: TimeInterval(request.findTimeoutMillis / 1000))
    }

    // MARK: General

    func pressHome() throws {
      return try runCatching {
        try automator.pressHome()
      }
    }

    func pressBack() throws {
      return try runCatching {
        throw PatrolError.methodNotImplemented("pressBack")
      }
    }

    func pressRecentApps() throws {
      return try runCatching {
        try automator.openAppSwitcher()
      }
    }

    func doublePressRecentApps() throws {
      return try runCatching {
        throw PatrolError.methodNotImplemented("doublePressRecentApps")
      }
    }

    func openApp(request: OpenAppRequest) throws {
      return try runCatching {
        try automator.openApp(request.appId)
      }
    }

    func openQuickSettings(request: OpenQuickSettingsRequest) throws {
      return try runCatching {
        try automator.openControlCenter()
      }
    }

    // MARK: General UI interaction

    func getNativeViews(
      request: GetNativeViewsRequest
    ) throws -> GetNativeViewsResponse {
      return try runCatching {
        let nativeViews = try automator.getNativeViews(
          byText: request.selector.text ?? String(),
          inApp: request.appId
        )

        return GetNativeViewsResponse(nativeViews: nativeViews)
      }
    }

    func tap(request: TapRequest) throws {
      return try runCatching {
        try automator.tap(
          onText: request.selector.text ?? String(),
          inApp: request.appId,
          atIndex: request.selector.instance ?? 0
        )
      }
    }

    func doubleTap(request: TapRequest) throws {
      return try runCatching {
        try automator.doubleTap(
          onText: request.selector.text ?? String(),
          inApp: request.appId
        )
      }
    }

    func enterText(request: EnterTextRequest) throws {
      return try runCatching {
        if let index = request.index {
          try automator.enterText(
            request.data,
            byIndex: Int(index),
            inApp: request.appId,
            dismissKeyboard: request.keyboardBehavior == .showAndDismiss
          )
        } else if let selector = request.selector {
          try automator.enterText(
            request.data,
            byText: selector.text ?? String(),
            atIndex: selector.instance ?? 0,
            inApp: request.appId,
            dismissKeyboard: request.keyboardBehavior == .showAndDismiss
          )
        } else {
          throw PatrolError.internal("enterText(): neither index nor selector are set")
        }
      }
    }

    func swipe(request: SwipeRequest) throws {
      return try runCatching {
        throw PatrolError.methodNotImplemented("swipe")
      }
    }

    func waitUntilVisible(request: WaitUntilVisibleRequest) throws {
      return try runCatching {
        try automator.waitUntilVisible(
          onText: request.selector.text ?? String(),
          inApp: request.appId
        )
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

    func tapOnNotification(request: TapOnNotificationRequest) throws {
      return try runCatching {
        if let index = request.index {
          try automator.tapOnNotification(
            byIndex: index
          )
        } else if let selector = request.selector {
          try automator.tapOnNotification(
            bySubstring: selector.textContains ?? String()
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
        let visible = automator.isPermissionDialogVisible(
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
      } catch let err {
        throw PatrolError.unknown(err)
      }
    }

    func markPatrolAppServiceReady() throws {
      onAppReady(true)
    }
  }

#endif
