//Generated by the protocol buffer compiler. DO NOT EDIT!
// source: contracts.proto

package pl.leancode.patrol.automator.contracts;

@kotlin.jvm.JvmName("-initializetapOnNotificationRequest")
public inline fun tapOnNotificationRequest(block: pl.leancode.patrol.automator.contracts.TapOnNotificationRequestKt.Dsl.() -> kotlin.Unit): pl.leancode.patrol.automator.contracts.Contracts.TapOnNotificationRequest =
  pl.leancode.patrol.automator.contracts.TapOnNotificationRequestKt.Dsl._create(pl.leancode.patrol.automator.contracts.Contracts.TapOnNotificationRequest.newBuilder()).apply { block() }._build()
public object TapOnNotificationRequestKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  public class Dsl private constructor(
    private val _builder: pl.leancode.patrol.automator.contracts.Contracts.TapOnNotificationRequest.Builder
  ) {
    public companion object {
      @kotlin.jvm.JvmSynthetic
      @kotlin.PublishedApi
      internal fun _create(builder: pl.leancode.patrol.automator.contracts.Contracts.TapOnNotificationRequest.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
    internal fun _build(): pl.leancode.patrol.automator.contracts.Contracts.TapOnNotificationRequest = _builder.build()

    /**
     * <code>uint32 index = 1;</code>
     */
    public var index: kotlin.Int
      @JvmName("getIndex")
      get() = _builder.getIndex()
      @JvmName("setIndex")
      set(value) {
        _builder.setIndex(value)
      }
    /**
     * <code>uint32 index = 1;</code>
     */
    public fun clearIndex() {
      _builder.clearIndex()
    }
    /**
     * <code>uint32 index = 1;</code>
     * @return Whether the index field is set.
     */
    public fun hasIndex(): kotlin.Boolean {
      return _builder.hasIndex()
    }

    /**
     * <code>.patrol.Selector selector = 2;</code>
     */
    public var selector: pl.leancode.patrol.automator.contracts.Contracts.Selector
      @JvmName("getSelector")
      get() = _builder.getSelector()
      @JvmName("setSelector")
      set(value) {
        _builder.setSelector(value)
      }
    /**
     * <code>.patrol.Selector selector = 2;</code>
     */
    public fun clearSelector() {
      _builder.clearSelector()
    }
    /**
     * <code>.patrol.Selector selector = 2;</code>
     * @return Whether the selector field is set.
     */
    public fun hasSelector(): kotlin.Boolean {
      return _builder.hasSelector()
    }
    public val findByCase: pl.leancode.patrol.automator.contracts.Contracts.TapOnNotificationRequest.FindByCase
      @JvmName("getFindByCase")
      get() = _builder.getFindByCase()

    public fun clearFindBy() {
      _builder.clearFindBy()
    }
  }
}
public inline fun pl.leancode.patrol.automator.contracts.Contracts.TapOnNotificationRequest.copy(block: pl.leancode.patrol.automator.contracts.TapOnNotificationRequestKt.Dsl.() -> kotlin.Unit): pl.leancode.patrol.automator.contracts.Contracts.TapOnNotificationRequest =
  pl.leancode.patrol.automator.contracts.TapOnNotificationRequestKt.Dsl._create(this.toBuilder()).apply { block() }._build()

public val pl.leancode.patrol.automator.contracts.Contracts.TapOnNotificationRequestOrBuilder.selectorOrNull: pl.leancode.patrol.automator.contracts.Contracts.Selector?
  get() = if (hasSelector()) getSelector() else null
