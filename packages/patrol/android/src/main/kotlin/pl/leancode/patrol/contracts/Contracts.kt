///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

class Contracts {
  enum class GroupEntryType {
    group,
    test,
  }

  enum class RunDartTestResponseResult {
    success,
    skipped,
    failure,
  }

  enum class KeyboardBehavior {
    showAndDismiss,
    alternative,
  }

  enum class HandlePermissionRequestCode {
    whileUsing,
    onlyThisTime,
    denied,
  }

  enum class SetLocationAccuracyRequestLocationAccuracy {
    coarse,
    fine,
  }

  data class DartGroupEntry (
    val name: String,
    val type: GroupEntryType,
    val entries: List<DartGroupEntry>
  )

  data class ListDartTestsResponse (
    val group: DartGroupEntry
  )

  data class RunDartTestRequest (
    val name: String
  )

  data class RunDartTestResponse (
    val result: RunDartTestResponseResult,
    val details: String? = null
  ){
    fun hasDetails(): Boolean {
      return details != null
    }
  }

  data class ConfigureRequest (
    val findTimeoutMillis: Long
  )

  data class OpenAppRequest (
    val appId: String
  )

  class OpenQuickSettingsRequest (

  )

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

  data class GetNativeViewsRequest (
    val selector: Selector,
    val appId: String
  )

  data class GetNativeUITreeRequest (
    val iosInstalledApps: List<String>? = null
  ){
    fun hasIosInstalledApps(): Boolean {
      return iosInstalledApps != null
    }
  }

  data class GetNativeUITreeRespone (
    val roots: List<NativeView>
  )

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

  data class GetNativeViewsResponse (
    val nativeViews: List<NativeView>
  )

  data class TapRequest (
    val selector: Selector,
    val appId: String,
    val timeoutMillis: Long? = null
  ){
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class EnterTextRequest (
    val data: String,
    val appId: String,
    val index: Long? = null,
    val selector: Selector? = null,
    val keyboardBehavior: KeyboardBehavior,
    val timeoutMillis: Long? = null
  ){
    fun hasIndex(): Boolean {
      return index != null
    }
    fun hasSelector(): Boolean {
      return selector != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class SwipeRequest (
    val appId: String,
    val startX: Double,
    val startY: Double,
    val endX: Double,
    val endY: Double,
    val steps: Long
  )

  data class WaitUntilVisibleRequest (
    val selector: Selector,
    val appId: String,
    val timeoutMillis: Long? = null
  ){
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class DarkModeRequest (
    val appId: String
  )

  data class Notification (
    val appName: String? = null,
    val title: String,
    val content: String,
    val raw: String? = null
  ){
    fun hasAppName(): Boolean {
      return appName != null
    }
    fun hasRaw(): Boolean {
      return raw != null
    }
  }

  data class GetNotificationsResponse (
    val notifications: List<Notification>
  )

  class GetNotificationsRequest (

  )

  data class TapOnNotificationRequest (
    val index: Long? = null,
    val selector: Selector? = null,
    val timeoutMillis: Long? = null
  ){
    fun hasIndex(): Boolean {
      return index != null
    }
    fun hasSelector(): Boolean {
      return selector != null
    }
    fun hasTimeoutMillis(): Boolean {
      return timeoutMillis != null
    }
  }

  data class PermissionDialogVisibleResponse (
    val visible: Boolean
  )

  data class PermissionDialogVisibleRequest (
    val timeoutMillis: Long
  )

  data class HandlePermissionRequest (
    val code: HandlePermissionRequestCode
  )

  data class SetLocationAccuracyRequest (
    val locationAccuracy: SetLocationAccuracyRequestLocationAccuracy
  )

}
