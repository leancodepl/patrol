//Generated by the protocol buffer compiler. DO NOT EDIT!
// source: contracts.proto

package pl.leancode.patrol.automator.contracts;

@kotlin.jvm.JvmName("-initializegetNativeViewsResponse")
public inline fun getNativeViewsResponse(block: pl.leancode.patrol.automator.contracts.GetNativeViewsResponseKt.Dsl.() -> kotlin.Unit): pl.leancode.patrol.automator.contracts.Contracts.GetNativeViewsResponse =
  pl.leancode.patrol.automator.contracts.GetNativeViewsResponseKt.Dsl._create(pl.leancode.patrol.automator.contracts.Contracts.GetNativeViewsResponse.newBuilder()).apply { block() }._build()
public object GetNativeViewsResponseKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  public class Dsl private constructor(
    private val _builder: pl.leancode.patrol.automator.contracts.Contracts.GetNativeViewsResponse.Builder
  ) {
    public companion object {
      @kotlin.jvm.JvmSynthetic
      @kotlin.PublishedApi
      internal fun _create(builder: pl.leancode.patrol.automator.contracts.Contracts.GetNativeViewsResponse.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
    internal fun _build(): pl.leancode.patrol.automator.contracts.Contracts.GetNativeViewsResponse = _builder.build()

    /**
     * An uninstantiable, behaviorless type to represent the field in
     * generics.
     */
    @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
    public class NativeViewsProxy private constructor() : com.google.protobuf.kotlin.DslProxy()
    /**
     * <code>repeated .patrol.NativeView nativeViews = 2;</code>
     */
     public val nativeViews: com.google.protobuf.kotlin.DslList<pl.leancode.patrol.automator.contracts.Contracts.NativeView, NativeViewsProxy>
      @kotlin.jvm.JvmSynthetic
      get() = com.google.protobuf.kotlin.DslList(
        _builder.getNativeViewsList()
      )
    /**
     * <code>repeated .patrol.NativeView nativeViews = 2;</code>
     * @param value The nativeViews to add.
     */
    @kotlin.jvm.JvmSynthetic
    @kotlin.jvm.JvmName("addNativeViews")
    public fun com.google.protobuf.kotlin.DslList<pl.leancode.patrol.automator.contracts.Contracts.NativeView, NativeViewsProxy>.add(value: pl.leancode.patrol.automator.contracts.Contracts.NativeView) {
      _builder.addNativeViews(value)
    }
    /**
     * <code>repeated .patrol.NativeView nativeViews = 2;</code>
     * @param value The nativeViews to add.
     */
    @kotlin.jvm.JvmSynthetic
    @kotlin.jvm.JvmName("plusAssignNativeViews")
    @Suppress("NOTHING_TO_INLINE")
    public inline operator fun com.google.protobuf.kotlin.DslList<pl.leancode.patrol.automator.contracts.Contracts.NativeView, NativeViewsProxy>.plusAssign(value: pl.leancode.patrol.automator.contracts.Contracts.NativeView) {
      add(value)
    }
    /**
     * <code>repeated .patrol.NativeView nativeViews = 2;</code>
     * @param values The nativeViews to add.
     */
    @kotlin.jvm.JvmSynthetic
    @kotlin.jvm.JvmName("addAllNativeViews")
    public fun com.google.protobuf.kotlin.DslList<pl.leancode.patrol.automator.contracts.Contracts.NativeView, NativeViewsProxy>.addAll(values: kotlin.collections.Iterable<pl.leancode.patrol.automator.contracts.Contracts.NativeView>) {
      _builder.addAllNativeViews(values)
    }
    /**
     * <code>repeated .patrol.NativeView nativeViews = 2;</code>
     * @param values The nativeViews to add.
     */
    @kotlin.jvm.JvmSynthetic
    @kotlin.jvm.JvmName("plusAssignAllNativeViews")
    @Suppress("NOTHING_TO_INLINE")
    public inline operator fun com.google.protobuf.kotlin.DslList<pl.leancode.patrol.automator.contracts.Contracts.NativeView, NativeViewsProxy>.plusAssign(values: kotlin.collections.Iterable<pl.leancode.patrol.automator.contracts.Contracts.NativeView>) {
      addAll(values)
    }
    /**
     * <code>repeated .patrol.NativeView nativeViews = 2;</code>
     * @param index The index to set the value at.
     * @param value The nativeViews to set.
     */
    @kotlin.jvm.JvmSynthetic
    @kotlin.jvm.JvmName("setNativeViews")
    public operator fun com.google.protobuf.kotlin.DslList<pl.leancode.patrol.automator.contracts.Contracts.NativeView, NativeViewsProxy>.set(index: kotlin.Int, value: pl.leancode.patrol.automator.contracts.Contracts.NativeView) {
      _builder.setNativeViews(index, value)
    }
    /**
     * <code>repeated .patrol.NativeView nativeViews = 2;</code>
     */
    @kotlin.jvm.JvmSynthetic
    @kotlin.jvm.JvmName("clearNativeViews")
    public fun com.google.protobuf.kotlin.DslList<pl.leancode.patrol.automator.contracts.Contracts.NativeView, NativeViewsProxy>.clear() {
      _builder.clearNativeViews()
    }
  }
}
public inline fun pl.leancode.patrol.automator.contracts.Contracts.GetNativeViewsResponse.copy(block: pl.leancode.patrol.automator.contracts.GetNativeViewsResponseKt.Dsl.() -> kotlin.Unit): pl.leancode.patrol.automator.contracts.Contracts.GetNativeViewsResponse =
  pl.leancode.patrol.automator.contracts.GetNativeViewsResponseKt.Dsl._create(this.toBuilder()).apply { block() }._build()
