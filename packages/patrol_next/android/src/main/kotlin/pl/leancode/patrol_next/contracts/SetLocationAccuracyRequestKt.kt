//Generated by the protocol buffer compiler. DO NOT EDIT!
// source: contracts.proto

package pl.leancode.patrol_next.contracts;

@kotlin.jvm.JvmName("-initializesetLocationAccuracyRequest")
inline fun setLocationAccuracyRequest(block: pl.leancode.patrol_next.contracts.SetLocationAccuracyRequestKt.Dsl.() -> kotlin.Unit): pl.leancode.patrol_next.contracts.Contracts.SetLocationAccuracyRequest =
  pl.leancode.patrol_next.contracts.SetLocationAccuracyRequestKt.Dsl._create(pl.leancode.patrol_next.contracts.Contracts.SetLocationAccuracyRequest.newBuilder()).apply { block() }._build()
object SetLocationAccuracyRequestKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  class Dsl private constructor(
    private val _builder: pl.leancode.patrol_next.contracts.Contracts.SetLocationAccuracyRequest.Builder
  ) {
    companion object {
      @kotlin.jvm.JvmSynthetic
      @kotlin.PublishedApi
      internal fun _create(builder: pl.leancode.patrol_next.contracts.Contracts.SetLocationAccuracyRequest.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
    internal fun _build(): pl.leancode.patrol_next.contracts.Contracts.SetLocationAccuracyRequest = _builder.build()

    /**
     * <code>.patrol.SetLocationAccuracyRequest.LocationAccuracy locationAccuracy = 1;</code>
     */
     var locationAccuracy: pl.leancode.patrol_next.contracts.Contracts.SetLocationAccuracyRequest.LocationAccuracy
      @JvmName("getLocationAccuracy")
      get() = _builder.getLocationAccuracy()
      @JvmName("setLocationAccuracy")
      set(value) {
        _builder.setLocationAccuracy(value)
      }
    /**
     * <code>.patrol.SetLocationAccuracyRequest.LocationAccuracy locationAccuracy = 1;</code>
     */
    fun clearLocationAccuracy() {
      _builder.clearLocationAccuracy()
    }
  }
}
@kotlin.jvm.JvmSynthetic
inline fun pl.leancode.patrol_next.contracts.Contracts.SetLocationAccuracyRequest.copy(block: pl.leancode.patrol_next.contracts.SetLocationAccuracyRequestKt.Dsl.() -> kotlin.Unit): pl.leancode.patrol_next.contracts.Contracts.SetLocationAccuracyRequest =
  pl.leancode.patrol_next.contracts.SetLocationAccuracyRequestKt.Dsl._create(this.toBuilder()).apply { block() }._build()
