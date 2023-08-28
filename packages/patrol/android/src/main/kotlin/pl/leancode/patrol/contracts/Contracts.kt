///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

import kotlinx.serialization.Serializable

class Contracts {
  @Serializable
  enum class RunDartTestResponseResult {
    success,
    skipped,
    failure,
  }

  @Serializable
  enum class HandlePermissionRequestCode {
    whileUsing,
    onlyThisTime,
    denied,
  }

  @Serializable
  enum class SetLocationAccuracyRequestLocationAccuracy {
    coarse,
    fine,
  }

  @Serializable
  data class DartTestCase (
    val name: String
  )

  @Serializable
  data class DartTestGroup (
    val name: String,
    val tests: List<DartTestCase>,
    val groups: List<DartTestGroup>
  )

  @Serializable
  data class ListDartTestsResponse (
    val group: DartTestGroup
  )

  @Serializable
  data class RunDartTestRequest (
    val name: String
  )

  @Serializable
  data class RunDartTestResponse (
    val result: RunDartTestResponseResult,
    val details: String?
  )

  @Serializable
  data class ConfigureRequest (
    val findTimeoutMillis: Int
  )

  @Serializable
  data class OpenAppRequest (
    val appId: String
  )

  @Serializable
  class OpenQuickSettingsRequest (

  )

  @Serializable
  data class Selector (
    val text: String?,
    val textStartsWith: String?,
    val textContains: String?,
    val className: String?,
    val contentDescription: String?,
    val contentDescriptionStartsWith: String?,
    val contentDescriptionContains: String?,
    val resourceId: String?,
    val instance: Int?,
    val enabled: Boolean?,
    val focused: Boolean?,
    val pkg: String?
  )

  @Serializable
  data class GetNativeViewsRequest (
    val selector: Selector,
    val appId: String
  )

  @Serializable
  data class NativeView (
    val className: String,
    val text: String,
    val contentDescription: String,
    val focused: Boolean,
    val enabled: Boolean,
    val childCount: Int,
    val resourceName: String,
    val applicationPackage: String,
    val children: List<NativeView>
  )

  @Serializable
  data class GetNativeViewsResponse (
    val nativeViews: List<NativeView>
  )

  @Serializable
  data class TapRequest (
    val selector: Selector,
    val appId: String
  )

  @Serializable
  data class EnterTextRequest (
    val data: String,
    val appId: String,
    val index: Int?,
    val selector: Selector?,
    val showKeyboard: Boolean?
  )

  @Serializable
  data class SwipeRequest (
    val startX: Double,
    val startY: Double,
    val endX: Double,
    val endY: Double,
    val steps: Int
  )

  @Serializable
  data class WaitUntilVisibleRequest (
    val selector: Selector,
    val appId: String
  )

  @Serializable
  data class DarkModeRequest (
    val appId: String
  )

  @Serializable
  data class Notification (
    val appName: String?,
    val title: String,
    val content: String,
    val raw: String
  )

  @Serializable
  data class GetNotificationsResponse (
    val notifications: List<Notification>
  )

  @Serializable
  class GetNotificationsRequest (

  )

  @Serializable
  data class TapOnNotificationRequest (
    val index: Int?,
    val selector: Selector?
  )

  @Serializable
  data class PermissionDialogVisibleResponse (
    val visible: Boolean
  )

  @Serializable
  data class PermissionDialogVisibleRequest (
    val timeoutMillis: Int
  )

  @Serializable
  data class HandlePermissionRequest (
    val code: HandlePermissionRequestCode
  )

  @Serializable
  data class SetLocationAccuracyRequest (
    val locationAccuracy: SetLocationAccuracyRequestLocationAccuracy
  )

}
