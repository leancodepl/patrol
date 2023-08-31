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
    val details: String? = null
  ){
    fun hasDetails(): Boolean {
      return details != null
    }
  }

  @Serializable
  data class ConfigureRequest (
    val findTimeoutMillis: Long
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
    val text: String? = null,
    val textStartsWith: String? = null,
    val textContains: String? = null,
    val className: String? = null,
    val contentDescription: String? = null,
    val contentDescriptionStartsWith: String? = null,
    val contentDescriptionContains: String? = null,
    val resourceId: String? = null,
    val instance: Long? = null,
    val enabled: Boolean? = null,
    val focused: Boolean? = null,
    val pkg: String? = null
  ){
    fun hasText(): Boolean {
      return text != null
    }
    fun hasTextStartsWith(): Boolean {
      return textStartsWith != null
    }
    fun hasTextContains(): Boolean {
      return textContains != null
    }
    fun hasClassName(): Boolean {
      return className != null
    }
    fun hasContentDescription(): Boolean {
      return contentDescription != null
    }
    fun hasContentDescriptionStartsWith(): Boolean {
      return contentDescriptionStartsWith != null
    }
    fun hasContentDescriptionContains(): Boolean {
      return contentDescriptionContains != null
    }
    fun hasResourceId(): Boolean {
      return resourceId != null
    }
    fun hasInstance(): Boolean {
      return instance != null
    }
    fun hasEnabled(): Boolean {
      return enabled != null
    }
    fun hasFocused(): Boolean {
      return focused != null
    }
    fun hasPkg(): Boolean {
      return pkg != null
    }
  }

  @Serializable
  data class GetNativeViewsRequest (
    val selector: Selector,
    val appId: String
  )

  @Serializable
  data class NativeView (
    val className: String? = null,
    val text: String? = null,
    val contentDescription: String? = null,
    val focused: Boolean,
    val enabled: Boolean,
    val childCount: Long? = null,
    val resourceName: String? = null,
    val applicationPackage: String? = null,
    val children: List<NativeView>
  ){
    fun hasClassName(): Boolean {
      return className != null
    }
    fun hasText(): Boolean {
      return text != null
    }
    fun hasContentDescription(): Boolean {
      return contentDescription != null
    }
    fun hasChildCount(): Boolean {
      return childCount != null
    }
    fun hasResourceName(): Boolean {
      return resourceName != null
    }
    fun hasApplicationPackage(): Boolean {
      return applicationPackage != null
    }
  }

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
    val index: Long? = null,
    val selector: Selector? = null,
    val showKeyboard: Boolean
  ){
    fun hasIndex(): Boolean {
      return index != null
    }
    fun hasSelector(): Boolean {
      return selector != null
    }
  }

  @Serializable
  data class SwipeRequest (
    val startX: Double,
    val startY: Double,
    val endX: Double,
    val endY: Double,
    val steps: Long
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
    val appName: String? = null,
    val title: String,
    val content: String,
    val raw: String
  ){
    fun hasAppName(): Boolean {
      return appName != null
    }
  }

  @Serializable
  data class GetNotificationsResponse (
    val notifications: List<Notification>
  )

  @Serializable
  class GetNotificationsRequest (

  )

  @Serializable
  data class TapOnNotificationRequest (
    val index: Long? = null,
    val selector: Selector? = null
  ){
    fun hasIndex(): Boolean {
      return index != null
    }
    fun hasSelector(): Boolean {
      return selector != null
    }
  }

  @Serializable
  data class PermissionDialogVisibleResponse (
    val visible: Boolean
  )

  @Serializable
  data class PermissionDialogVisibleRequest (
    val timeoutMillis: Long
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
