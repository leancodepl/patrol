//Generated by the protocol buffer compiler. DO NOT EDIT!
// source: contracts.proto

package pl.leancode.automatorserver.contracts;

@kotlin.jvm.JvmName("-initializecellularRequest")
inline fun cellularRequest(block: pl.leancode.automatorserver.contracts.CellularRequestKt.Dsl.() -> kotlin.Unit): pl.leancode.automatorserver.contracts.Contracts.CellularRequest =
  pl.leancode.automatorserver.contracts.CellularRequestKt.Dsl._create(pl.leancode.automatorserver.contracts.Contracts.CellularRequest.newBuilder()).apply { block() }._build()
object CellularRequestKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  class Dsl private constructor(
    private val _builder: pl.leancode.automatorserver.contracts.Contracts.CellularRequest.Builder
  ) {
    companion object {
      @kotlin.jvm.JvmSynthetic
      @kotlin.PublishedApi
      internal fun _create(builder: pl.leancode.automatorserver.contracts.Contracts.CellularRequest.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
    internal fun _build(): pl.leancode.automatorserver.contracts.Contracts.CellularRequest = _builder.build()
  }
}
@kotlin.jvm.JvmSynthetic
inline fun pl.leancode.automatorserver.contracts.Contracts.CellularRequest.copy(block: pl.leancode.automatorserver.contracts.CellularRequestKt.Dsl.() -> kotlin.Unit): pl.leancode.automatorserver.contracts.Contracts.CellularRequest =
  pl.leancode.automatorserver.contracts.CellularRequestKt.Dsl._create(this.toBuilder()).apply { block() }._build()

