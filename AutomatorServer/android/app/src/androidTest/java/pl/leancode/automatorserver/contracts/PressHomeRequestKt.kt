//Generated by the protocol buffer compiler. DO NOT EDIT!
// source: contracts.proto

package pl.leancode.automatorserver.contracts;

@kotlin.jvm.JvmName("-initializepressHomeRequest")
inline fun pressHomeRequest(block: pl.leancode.automatorserver.contracts.PressHomeRequestKt.Dsl.() -> kotlin.Unit): pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest =
  pl.leancode.automatorserver.contracts.PressHomeRequestKt.Dsl._create(pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest.newBuilder()).apply { block() }._build()
object PressHomeRequestKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  class Dsl private constructor(
    private val _builder: pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest.Builder
  ) {
    companion object {
      @kotlin.jvm.JvmSynthetic
      @kotlin.PublishedApi
      internal fun _create(builder: pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
    internal fun _build(): pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest = _builder.build()
  }
}
@kotlin.jvm.JvmSynthetic
inline fun pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest.copy(block: pl.leancode.automatorserver.contracts.PressHomeRequestKt.Dsl.() -> kotlin.Unit): pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest =
  pl.leancode.automatorserver.contracts.PressHomeRequestKt.Dsl._create(this.toBuilder()).apply { block() }._build()

