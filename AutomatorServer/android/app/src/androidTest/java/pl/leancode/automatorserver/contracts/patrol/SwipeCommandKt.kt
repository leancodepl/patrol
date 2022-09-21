//Generated by the protocol buffer compiler. DO NOT EDIT!
// source: contracts.proto

package patrol;

@kotlin.jvm.JvmName("-initializeswipeCommand")
inline fun swipeCommand(block: patrol.SwipeCommandKt.Dsl.() -> kotlin.Unit): patrol.Contracts.SwipeCommand =
  patrol.SwipeCommandKt.Dsl._create(patrol.Contracts.SwipeCommand.newBuilder()).apply { block() }._build()
object SwipeCommandKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  class Dsl private constructor(
    private val _builder: patrol.Contracts.SwipeCommand.Builder
  ) {
    companion object {
      @kotlin.jvm.JvmSynthetic
      @kotlin.PublishedApi
      internal fun _create(builder: patrol.Contracts.SwipeCommand.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
    internal fun _build(): patrol.Contracts.SwipeCommand = _builder.build()

    /**
     * <code>float startX = 1;</code>
     */
    var startX: kotlin.Float
      @JvmName("getStartX")
      get() = _builder.getStartX()
      @JvmName("setStartX")
      set(value) {
        _builder.setStartX(value)
      }
    /**
     * <code>float startX = 1;</code>
     */
    fun clearStartX() {
      _builder.clearStartX()
    }

    /**
     * <code>float startY = 2;</code>
     */
    var startY: kotlin.Float
      @JvmName("getStartY")
      get() = _builder.getStartY()
      @JvmName("setStartY")
      set(value) {
        _builder.setStartY(value)
      }
    /**
     * <code>float startY = 2;</code>
     */
    fun clearStartY() {
      _builder.clearStartY()
    }

    /**
     * <code>float endX = 3;</code>
     */
    var endX: kotlin.Float
      @JvmName("getEndX")
      get() = _builder.getEndX()
      @JvmName("setEndX")
      set(value) {
        _builder.setEndX(value)
      }
    /**
     * <code>float endX = 3;</code>
     */
    fun clearEndX() {
      _builder.clearEndX()
    }

    /**
     * <code>float endY = 4;</code>
     */
    var endY: kotlin.Float
      @JvmName("getEndY")
      get() = _builder.getEndY()
      @JvmName("setEndY")
      set(value) {
        _builder.setEndY(value)
      }
    /**
     * <code>float endY = 4;</code>
     */
    fun clearEndY() {
      _builder.clearEndY()
    }

    /**
     * <pre>
     * TODO: should be uint32?
     * </pre>
     *
     * <code>int32 steps = 5;</code>
     */
    var steps: kotlin.Int
      @JvmName("getSteps")
      get() = _builder.getSteps()
      @JvmName("setSteps")
      set(value) {
        _builder.setSteps(value)
      }
    /**
     * <pre>
     * TODO: should be uint32?
     * </pre>
     *
     * <code>int32 steps = 5;</code>
     */
    fun clearSteps() {
      _builder.clearSteps()
    }
  }
}
@kotlin.jvm.JvmSynthetic
inline fun patrol.Contracts.SwipeCommand.copy(block: patrol.SwipeCommandKt.Dsl.() -> kotlin.Unit): patrol.Contracts.SwipeCommand =
  patrol.SwipeCommandKt.Dsl._create(this.toBuilder()).apply { block() }._build()

