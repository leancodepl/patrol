import GRPC

final class NativeAutomatorServer: Patrol_NativeAutomatorAsyncProvider {
  private let automation = PatrolAutomation()
  
  func pressHome(request: Patrol_PressHomeRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_PressHomeResponse {
    automation.pressHome()
    return Patrol_PressHomeResponse()
  }
  
  func pressBack(request: Patrol_PressBackRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_PressBackResponse {
    throw PatrolError.generic("pressBack() is not supported on iOS")
  }
  
  func pressRecentApps(request: Patrol_PressRecentAppsRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_PressRecentAppsResponse {
    automation.openAppSwitcher()
    return Patrol_PressRecentAppsResponse()
  }
  
  func doublePressRecentApps(request: Patrol_DoublePressRecentAppsRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_DoublePressRecentAppsResponse {
    throw PatrolError.generic("doublePressRecentApps() is not supported on iOS")
  }
  
  func openApp(request: Patrol_OpenAppRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_OpenAppResponse {
    automation.openApp(request.appID)
    return Patrol_OpenAppResponse()
  }
  
  func openNotifications(request: Patrol_OpenNotificationsRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_OpenNotificationsResponse {
    throw PatrolError.generic("openNotifications() is not supported on iOS")
  }
  
  func openQuickSettings(request: Patrol_OpenQuickSettingsRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_OpenQuickSettingsResponse {
    throw PatrolError.generic("openQuickSettings() is not supported on iOS")
  }
  
  func enableDarkMode(request: Patrol_DarkModeRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_DarkModeResponse {
    automation.enableDarkMode(request.appID)
    return Patrol_DarkModeResponse()
  }
  
  func disableDarkMode(request: Patrol_DarkModeRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_DarkModeResponse {
    automation.disableDarkMode(request.appID)
    return Patrol_DarkModeResponse()
  }
  
  func enableWiFi(request: Patrol_WiFiRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_WiFiResponse {
    throw PatrolError.generic("enableWiFi() is not supported on iOS")
  }
  
  func disableWiFi(request: Patrol_WiFiRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_WiFiResponse {
    throw PatrolError.generic("disableWiFi() is not supported on iOS")
  }
  
  func enableCellular(request: Patrol_CellularRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_CellularResponse {
    throw PatrolError.generic("enableCellular() is not supported on iOS")
  }
  
  func disableCellular(request: Patrol_CellularRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_CellularResponse {
    throw PatrolError.generic("disableCellular() is not supported on iOS")
  }
  
  func getNativeWidgets(request: Patrol_GetNativeWidgetsRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_GetNativeWidgetsResponse {
    throw PatrolError.generic("getNativeWidgets() is not supported on iOS")
  }
  
  func getNotifications(request: Patrol_GetNotificationsRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_GetNotificationsResponse {
    throw PatrolError.generic("getNotifications() is not supported on iOS")
  }
  
  func tap(request: Patrol_TapRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_TapResponse {
    automation.tap(on: request.selector.text, inApp: request.appID)
    return Patrol_TapResponse()
  }
  
  func doubleTap(request: Patrol_TapRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_TapResponse {
    automation.doubleTap(on: request.selector.text, inApp: request.appID)
    return Patrol_TapResponse()
  }
  
  func enterText(request: Patrol_EnterTextRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_EnterTextResponse {
    automation.enterText(request.data, by: request.selector.text, inApp: request.appID)
    return Patrol_EnterTextResponse()
  }
  
  func swipe(request: Patrol_SwipeRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_SwipeResponse {
    throw PatrolError.generic("swipe() is not supported on iOS")
  }
  
  func handlePermissionDialog(request: Patrol_HandlePermissionRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_HandlePermissionResponse {
    switch request.code {
    case .whileUsing:
      automation.allowPermissionWhileUsingApp()
    case .onlyThisTime:
      automation.allowPermissionOnce()
    case .denied:
      automation.denyPermission()
    case .UNRECOGNIZED:
      throw PatrolError.generic("unrecognized permission code")
    }

    return Patrol_HandlePermissionResponse()
  }
  
  func setLocationAccuracy(request: Patrol_SetLocationAccuracyRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_SetLocationAccuracyResponse {
    switch request.locationAccuracy {
    case .coarse:
      automation.selectCoarseLocation()
    case .fine:
      automation.selectFineLocation()
    case .UNRECOGNIZED:
      throw PatrolError.generic("unrecognized location accuracy")
    }
    
    return Patrol_SetLocationAccuracyResponse()
  }
  
  func tapOnNotification(request: Patrol_TapOnNotificationRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Patrol_TapOnNotificationResponse {
    throw PatrolError.generic("tapOnNotification() is not supported on iOS")
  }
}
