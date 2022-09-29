import GRPC

typealias Empty = Patrol_Empty

final class NativeAutomatorServer: Patrol_NativeAutomatorAsyncProvider {
  private let automation = PatrolAutomation()
  
  func pressHome(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.pressHome()
    return Empty()
  }
  
  func pressBack(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    throw PatrolError.generic("pressBack() is not supported on iOS")
  }
  
  func pressRecentApps(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.openAppSwitcher()
    return Empty()
  }
  
  func doublePressRecentApps(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    throw PatrolError.generic("doublePressRecentApps() is not supported on iOS")
  }
  
  func openApp(
    request: Patrol_OpenAppRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.openApp(request.appID)
    return Empty()
  }
  
  func openNotifications(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.openNotifications()
    return Empty()
  }
  
  func closeNotifications(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.closeNotifications()
    return Empty()
  }
  
  func openQuickSettings(
    request: Patrol_OpenQuickSettingsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.openControlCenter()
    return Empty()
  }
  
  func enableDarkMode(
    request: Patrol_DarkModeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.enableDarkMode(request.appID)
    return Empty()
  }
  
  func disableDarkMode(
    request: Patrol_DarkModeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.disableDarkMode(request.appID)
    return Empty()
  }
  
  func enableAirplaneMode(
    request: Patrol_AirplaneModeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.enableAirplaneMode(request.appID)
    return Empty()
  }
  
  func disableAirplaneMode(
    request: Patrol_AirplaneModeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.disableAirplaneMode(request.appID)
    return Empty()
  }
  
  func enableCellular(
    request: Patrol_CellularRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.enableCellular(request.appID)
    return Empty()
  }
  
  func disableCellular(
    request: Patrol_CellularRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.disableCellular(request.appID)
    return Empty()
  }
  
  func enableWiFi(
    request: Patrol_WiFiRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.enableWiFi(request.appID)
    return Empty()
  }
  
  func disableWiFi(
    request: Patrol_WiFiRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.disableWiFi(request.appID)
    return Empty()
  }
  
  func enableBluetooth(
    request: Patrol_BluetoothRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.enableBluetooth(request.appID)
    return Empty()
  }
  
  func disableBluetooth(
    request: Patrol_BluetoothRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.disableBluetooth(request.appID)
    return Empty()
  }
  
  func getNativeWidgets(
    request: Patrol_GetNativeWidgetsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Patrol_GetNativeWidgetsResponse {
    throw PatrolError.generic("getNativeWidgets() is not supported on iOS")
  }
  
  func getNotifications(
    request: Patrol_GetNotificationsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Patrol_GetNotificationsResponse {
    throw PatrolError.generic("getNotifications() is not supported on iOS")
  }
  
  func tap(
    request: Patrol_TapRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.tap(on: request.selector.text, inApp: request.appID)
    return Empty()
  }
  
  func doubleTap(
    request: Patrol_TapRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.doubleTap(on: request.selector.text, inApp: request.appID)
    return Empty()
  }
  
  func enterText(
    request: Patrol_EnterTextRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    switch request.findBy {
    case .index(let index):
      automation.enterText(request.data, by: Int(index), inApp: request.appID)
    case .selector(let selector):
      automation.enterText(request.data, by: selector.text, inApp: request.appID)
    default:
      throw PatrolError.generic("enterText(): neither index nor selector are set")
    }
    
    return Empty()
  }
  
  func swipe(
    request: Patrol_SwipeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    throw PatrolError.generic("swipe() is not supported on iOS")
  }
  
  func handlePermissionDialog(
    request: Patrol_HandlePermissionRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    switch request.code {
    case .whileUsing:
      automation.allowPermissionWhileUsingApp()
    case .onlyThisTime:
      automation.allowPermissionOnce()
    case .denied:
      automation.denyPermission()
    case .UNRECOGNIZED:
      throw PatrolError.generic("handlePermissionDialog(): bad permission code")
    }

    return Empty()
  }
  
  func setLocationAccuracy(
    request: Patrol_SetLocationAccuracyRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    switch request.locationAccuracy {
    case .coarse:
      automation.selectCoarseLocation()
    case .fine:
      automation.selectFineLocation()
    case .UNRECOGNIZED:
      throw PatrolError.generic("unrecognized location accuracy")
    }
    
    return Empty()
  }
  
  func tapOnNotification(
    request: Patrol_TapOnNotificationRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    throw PatrolError.generic("tapOnNotification() is not supported on iOS")
  }
  
  func debug(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.debug()
    return Empty()
  }
}
