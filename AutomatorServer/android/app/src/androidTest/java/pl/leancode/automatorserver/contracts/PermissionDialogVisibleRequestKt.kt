//Generated by the protocol buffer compiler. DO NOT EDIT!
// source: contracts.proto

package pl.leancode.automatorserver.contracts;

@kotlin.jvm.JvmName("-initializepermissionDialogVisibleRequest")
inline fun permissionDialogVisibleRequest(block: pl.leancode.automatorserver.contracts.PermissionDialogVisibleRequestKt.Dsl.() -> kotlin.Unit): pl.leancode.automatorserver.contracts.Contracts.PermissionDialogVisibleRequest =
  pl.leancode.automatorserver.contracts.PermissionDialogVisibleRequestKt.Dsl._create(pl.leancode.automatorserver.contracts.Contracts.PermissionDialogVisibleRequest.newBuilder()).apply { block() }._build()
object PermissionDialogVisibleRequestKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  class Dsl private constructor(
    private val _builder: pl.leancode.automatorserver.contracts.Contracts.PermissionDialogVisibleRequest.Builder
  ) {
    companion object {
      @kotlin.jvm.JvmSynthetic
      @kotlin.PublishedApi
      internal fun _create(builder: pl.leancode.automatorserver.contracts.Contracts.PermissionDialogVisibleRequest.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
    internal fun _build(): pl.leancode.automatorserver.contracts.Contracts.PermissionDialogVisibleRequest = _builder.build()

    /**
     * <code>uint64 timeout = 1;</code>
     */
    var timeout: kotlin.Long
      @JvmName("getTimeout")
      get() = _builder.getTimeout()
      @JvmName("setTimeout")
      set(value) {
        _builder.setTimeout(value)
      }
    /**
     * <code>uint64 timeout = 1;</code>
     */
    fun clearTimeout() {
      _builder.clearTimeout()
    }
  }
}
@kotlin.jvm.JvmSynthetic
inline fun pl.leancode.automatorserver.contracts.Contracts.PermissionDialogVisibleRequest.copy(block: pl.leancode.automatorserver.contracts.PermissionDialogVisibleRequestKt.Dsl.() -> kotlin.Unit): pl.leancode.automatorserver.contracts.Contracts.PermissionDialogVisibleRequest =
  pl.leancode.automatorserver.contracts.PermissionDialogVisibleRequestKt.Dsl._create(this.toBuilder()).apply { block() }._build()

