//Generated by the protocol buffer compiler. DO NOT EDIT!
// source: contracts.proto

package pl.leancode.patrol.example.contracts;

@kotlin.jvm.JvmName("-initializenotification")
inline fun notification(block: pl.leancode.patrol.example.contracts.NotificationKt.Dsl.() -> kotlin.Unit): pl.leancode.patrol.example.contracts.Contracts.Notification =
  pl.leancode.patrol.example.contracts.NotificationKt.Dsl._create(pl.leancode.patrol.example.contracts.Contracts.Notification.newBuilder()).apply { block() }._build()
object NotificationKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  class Dsl private constructor(
    private val _builder: pl.leancode.patrol.example.contracts.Contracts.Notification.Builder
  ) {
    companion object {
      @kotlin.jvm.JvmSynthetic
      @kotlin.PublishedApi
      internal fun _create(builder: pl.leancode.patrol.example.contracts.Contracts.Notification.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
    internal fun _build(): pl.leancode.patrol.example.contracts.Contracts.Notification = _builder.build()

    /**
     * <code>optional string appName = 1;</code>
     */
    var appName: kotlin.String
      @JvmName("getAppName")
      get() = _builder.getAppName()
      @JvmName("setAppName")
      set(value) {
        _builder.setAppName(value)
      }
    /**
     * <code>optional string appName = 1;</code>
     */
    fun clearAppName() {
      _builder.clearAppName()
    }
    /**
     * <code>optional string appName = 1;</code>
     * @return Whether the appName field is set.
     */
    fun hasAppName(): kotlin.Boolean {
      return _builder.hasAppName()
    }

    /**
     * <code>string title = 2;</code>
     */
    var title: kotlin.String
      @JvmName("getTitle")
      get() = _builder.getTitle()
      @JvmName("setTitle")
      set(value) {
        _builder.setTitle(value)
      }
    /**
     * <code>string title = 2;</code>
     */
    fun clearTitle() {
      _builder.clearTitle()
    }

    /**
     * <code>string content = 3;</code>
     */
    var content: kotlin.String
      @JvmName("getContent")
      get() = _builder.getContent()
      @JvmName("setContent")
      set(value) {
        _builder.setContent(value)
      }
    /**
     * <code>string content = 3;</code>
     */
    fun clearContent() {
      _builder.clearContent()
    }

    /**
     * <code>string raw = 4;</code>
     */
    var raw: kotlin.String
      @JvmName("getRaw")
      get() = _builder.getRaw()
      @JvmName("setRaw")
      set(value) {
        _builder.setRaw(value)
      }
    /**
     * <code>string raw = 4;</code>
     */
    fun clearRaw() {
      _builder.clearRaw()
    }
  }
}
@kotlin.jvm.JvmSynthetic
inline fun pl.leancode.patrol.example.contracts.Contracts.Notification.copy(block: pl.leancode.patrol.example.contracts.NotificationKt.Dsl.() -> kotlin.Unit): pl.leancode.patrol.example.contracts.Contracts.Notification =
  pl.leancode.patrol.example.contracts.NotificationKt.Dsl._create(this.toBuilder()).apply { block() }._build()
