import GRPC

typealias Empty = Patrol_Empty
typealias DefaultResponse = Patrol_Empty

final class NativeAutomatorServer: Patrol_NativeAutomatorAsyncProvider {
  private let automation = PatrolAutomation()
  
  func configure(
    request: Patrol_ConfigureRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    return Empty()
  }
  
  // MARK: General
  
  func pressHome(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.pressHome()
      return DefaultResponse()
    }
  }
  
  func pressBack(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      throw PatrolError.methodNotImplemented("pressBack")
    }
  }
  
  func pressRecentApps(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.openAppSwitcher()
      return DefaultResponse()
    }
  }
  
  func doublePressRecentApps(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      throw PatrolError.methodNotImplemented("doublePressRecentApps")
    }
  }
  
  func openApp(
    request: Patrol_OpenAppRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.openApp(request.appID)
      return DefaultResponse()
    }
  }
  
  func openQuickSettings(
    request: Patrol_OpenQuickSettingsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.openControlCenter()
      return DefaultResponse()
    }
  }
  
  // MARK: General UI interaction
  
  func getNativeViews(
    request: Patrol_GetNativeViewsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Patrol_GetNativeViewsResponse {
    return try await runCatching {
      throw PatrolError.internal("getNativeViews() is not supported on iOS")
    }
  }
  
  func tap(
    request: Patrol_TapRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.tap(on: request.selector.text, inApp: request.appID)
      return DefaultResponse()
    }
  }
  
  func doubleTap(
    request: Patrol_TapRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.doubleTap(on: request.selector.text, inApp: request.appID)
      return DefaultResponse()
    }
  }
  
  func enterText(
    request: Patrol_EnterTextRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      switch request.findBy {
      case .index(let index):
        try automation.enterText(request.data, by: Int(index), inApp: request.appID)
      case .selector(let selector):
        try automation.enterText(request.data, by: selector.text, inApp: request.appID)
      default:
        throw PatrolError.internal("enterText(): neither index nor selector are set")
      }
      
      return DefaultResponse()
    }
  }
  
  func swipe(
    request: Patrol_SwipeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      throw PatrolError.methodNotImplemented("swipe")
    }
  }
  
  // MARK: Services
  
  func enableAirplaneMode(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.enableAirplaneMode()
      return DefaultResponse()
    }
  }
  
  func disableAirplaneMode(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.disableAirplaneMode()
      return DefaultResponse()
    }
  }
  
  func enableWiFi(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.enableWiFi()
      return DefaultResponse()
    }
  }
  
  func disableWiFi(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.disableWiFi()
      return DefaultResponse()
    }
  }
  
  func enableCellular(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.enableCellular()
      return DefaultResponse()
    }
  }
  
  func disableCellular(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.disableCellular()
      return DefaultResponse()
    }
  }
  
  func enableBluetooth(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.enableBluetooth()
      return DefaultResponse()
    }
  }
  
  func disableBluetooth(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.disableBluetooth()
      return DefaultResponse()
    }
  }
  
  func enableDarkMode(
    request: Patrol_DarkModeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.enableDarkMode(request.appID)
      return DefaultResponse()
    }
  }
  
  func disableDarkMode(
    request: Patrol_DarkModeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.disableDarkMode(request.appID)
      return DefaultResponse()
    }
  }
  
  // MARK: Notifications
  
  func openNotifications(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.openNotifications()
      return DefaultResponse()
    }
  }
  
  func closeNotifications(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.closeNotifications()
      return DefaultResponse()
    }
  }
  
  func closeHeadsUpNotification(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try await automation.closeHeadsUpNotification()
      return DefaultResponse()
    }
  }
  
  func getNotifications(
    request: Patrol_GetNotificationsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Patrol_GetNotificationsResponse {
    return try await runCatching {
      let notifications = try automation.getNotifications()
      return Patrol_GetNotificationsResponse.with {
        $0.notifications = notifications
      }
    }
  }
  
  func tapOnNotification(
    request: Patrol_TapOnNotificationRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      switch request.findBy {
        case .index(let index):
          try automation.tapOnNotification(by: Int(index))
        case .selector(let selector):
          try automation.tapOnNotification(by: selector.textContains)
        default:
          throw PatrolError.internal("tapOnNotification(): neither index nor selector are set")
      }
      
      return DefaultResponse()
    }
  }
  
  // MARK: Permissions
  
  func handlePermissionDialog(
    request: Patrol_HandlePermissionRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      switch request.code {
      case .whileUsing:
        try automation.allowPermissionWhileUsingApp()
      case .onlyThisTime:
        try automation.allowPermissionOnce()
      case .denied:
        try automation.denyPermission()
      case .UNRECOGNIZED:
        throw PatrolError.internal("handlePermissionDialog(): bad permission code")
      }
      
      return DefaultResponse()
    }
  }
  
  func setLocationAccuracy(
    request: Patrol_SetLocationAccuracyRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      switch request.locationAccuracy {
      case .coarse:
        try automation.selectCoarseLocation()
      case .fine:
        try automation.selectFineLocation()
      case .UNRECOGNIZED:
        throw PatrolError.internal("unrecognized location accuracy")
      }
      
      return DefaultResponse()
    }
  }
  
  func debug(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return try await runCatching {
      try automation.debug()
      return DefaultResponse()
    }
  }
  
  private func runCatching<T>(_ block: () async throws -> T) async throws -> T {
    // TODO: Use an interceptor (like on Android)
    // See: https://github.com/grpc/grpc-swift/issues/1148
    do {
      return try await block()
    } catch let err as PatrolError {
      throw err
    } catch let err {
      throw PatrolError.unknown(err)
    }
  }
}
