//Generated by the protocol buffer compiler. DO NOT EDIT!
// source: contracts.proto

package pl.leancode.patrol.contracts;

@kotlin.jvm.JvmName("-initializepermissionDialogVisibleResponse")
public inline fun permissionDialogVisibleResponse(block: pl.leancode.patrol.contracts.PermissionDialogVisibleResponseKt.Dsl.() -> kotlin.Unit): pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse =
  pl.leancode.patrol.contracts.PermissionDialogVisibleResponseKt.Dsl._create(pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse.newBuilder()).apply { block() }._build()
public object PermissionDialogVisibleResponseKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  public class Dsl private constructor(
    private val _builder: pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse.Builder
  ) {
    public companion object {
      @kotlin.jvm.JvmSynthetic
      @kotlin.PublishedApi
      internal fun _create(builder: pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
    internal fun _build(): pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse = _builder.build()

    /**
     * <code>bool visible = 1;</code>
     */
    public var visible: kotlin.Boolean
      @JvmName("getVisible")
      get() = _builder.getVisible()
      @JvmName("setVisible")
      set(value) {
        _builder.setVisible(value)
      }
    /**
     * <code>bool visible = 1;</code>
     */
    public fun clearVisible() {
      _builder.clearVisible()
    }
  }
}
public inline fun pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse.copy(block: pl.leancode.patrol.contracts.PermissionDialogVisibleResponseKt.Dsl.() -> kotlin.Unit): pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse =
  pl.leancode.patrol.contracts.PermissionDialogVisibleResponseKt.Dsl._create(this.toBuilder()).apply { block() }._build()

