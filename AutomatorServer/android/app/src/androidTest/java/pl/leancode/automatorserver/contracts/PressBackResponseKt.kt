//Generated by the protocol buffer compiler. DO NOT EDIT!
// source: contracts.proto

package pl.leancode.automatorserver.contracts;

@kotlin.jvm.JvmName("-initializepressBackResponse")
inline fun pressBackResponse(block: pl.leancode.automatorserver.contracts.PressBackResponseKt.Dsl.() -> kotlin.Unit): pl.leancode.automatorserver.contracts.Contracts.PressBackResponse =
  pl.leancode.automatorserver.contracts.PressBackResponseKt.Dsl._create(pl.leancode.automatorserver.contracts.Contracts.PressBackResponse.newBuilder()).apply { block() }._build()
object PressBackResponseKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  class Dsl private constructor(
    private val _builder: pl.leancode.automatorserver.contracts.Contracts.PressBackResponse.Builder
  ) {
    companion object {
      @kotlin.jvm.JvmSynthetic
      @kotlin.PublishedApi
      internal fun _create(builder: pl.leancode.automatorserver.contracts.Contracts.PressBackResponse.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
    internal fun _build(): pl.leancode.automatorserver.contracts.Contracts.PressBackResponse = _builder.build()
  }
}
@kotlin.jvm.JvmSynthetic
inline fun pl.leancode.automatorserver.contracts.Contracts.PressBackResponse.copy(block: pl.leancode.automatorserver.contracts.PressBackResponseKt.Dsl.() -> kotlin.Unit): pl.leancode.automatorserver.contracts.Contracts.PressBackResponse =
  pl.leancode.automatorserver.contracts.PressBackResponseKt.Dsl._create(this.toBuilder()).apply { block() }._build()

