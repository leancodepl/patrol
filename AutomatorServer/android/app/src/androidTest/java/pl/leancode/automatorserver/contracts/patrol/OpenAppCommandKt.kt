//Generated by the protocol buffer compiler. DO NOT EDIT!
// source: contracts.proto

package patrol;

@kotlin.jvm.JvmName("-initializeopenAppCommand")
inline fun openAppCommand(block: patrol.OpenAppCommandKt.Dsl.() -> kotlin.Unit): patrol.Contracts.OpenAppCommand =
  patrol.OpenAppCommandKt.Dsl._create(patrol.Contracts.OpenAppCommand.newBuilder()).apply { block() }._build()
object OpenAppCommandKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  class Dsl private constructor(
    private val _builder: patrol.Contracts.OpenAppCommand.Builder
  ) {
    companion object {
      @kotlin.jvm.JvmSynthetic
      @kotlin.PublishedApi
      internal fun _create(builder: patrol.Contracts.OpenAppCommand.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
    internal fun _build(): patrol.Contracts.OpenAppCommand = _builder.build()

    /**
     * <code>string appId = 1;</code>
     */
    var appId: kotlin.String
      @JvmName("getAppId")
      get() = _builder.getAppId()
      @JvmName("setAppId")
      set(value) {
        _builder.setAppId(value)
      }
    /**
     * <code>string appId = 1;</code>
     */
    fun clearAppId() {
      _builder.clearAppId()
    }
  }
}
@kotlin.jvm.JvmSynthetic
inline fun patrol.Contracts.OpenAppCommand.copy(block: patrol.OpenAppCommandKt.Dsl.() -> kotlin.Unit): patrol.Contracts.OpenAppCommand =
  patrol.OpenAppCommandKt.Dsl._create(this.toBuilder()).apply { block() }._build()

