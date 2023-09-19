// Generated by the protocol buffer compiler. DO NOT EDIT!
// source: contracts.proto

// Generated files should ignore deprecation warnings
@file:Suppress("DEPRECATION")
package pl.leancode.patrol.contracts;

@kotlin.jvm.JvmName("-initializesubmitTestResultsRequest")
public inline fun submitTestResultsRequest(block: pl.leancode.patrol.contracts.SubmitTestResultsRequestKt.Dsl.() -> kotlin.Unit): pl.leancode.patrol.contracts.Contracts.SubmitTestResultsRequest =
  pl.leancode.patrol.contracts.SubmitTestResultsRequestKt.Dsl._create(pl.leancode.patrol.contracts.Contracts.SubmitTestResultsRequest.newBuilder()).apply { block() }._build()
/**
 * Protobuf type `patrol.SubmitTestResultsRequest`
 */
public object SubmitTestResultsRequestKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  public class Dsl private constructor(
    private val _builder: pl.leancode.patrol.contracts.Contracts.SubmitTestResultsRequest.Builder
  ) {
    public companion object {
      @kotlin.jvm.JvmSynthetic
      @kotlin.PublishedApi
      internal fun _create(builder: pl.leancode.patrol.contracts.Contracts.SubmitTestResultsRequest.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
    internal fun _build(): pl.leancode.patrol.contracts.Contracts.SubmitTestResultsRequest = _builder.build()

    /**
     * An uninstantiable, behaviorless type to represent the field in
     * generics.
     */
    @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
    public class ResultsProxy private constructor() : com.google.protobuf.kotlin.DslProxy()
    /**
     * `map<string, string> results = 1;`
     */
     public val results: com.google.protobuf.kotlin.DslMap<kotlin.String, kotlin.String, ResultsProxy>
      @kotlin.jvm.JvmSynthetic
      @JvmName("getResultsMap")
      get() = com.google.protobuf.kotlin.DslMap(
        _builder.getResultsMap()
      )
    /**
     * `map<string, string> results = 1;`
     */
    @JvmName("putResults")
    public fun com.google.protobuf.kotlin.DslMap<kotlin.String, kotlin.String, ResultsProxy>
      .put(key: kotlin.String, value: kotlin.String) {
         _builder.putResults(key, value)
       }
    /**
     * `map<string, string> results = 1;`
     */
    @kotlin.jvm.JvmSynthetic
    @JvmName("setResults")
    @Suppress("NOTHING_TO_INLINE")
    public inline operator fun com.google.protobuf.kotlin.DslMap<kotlin.String, kotlin.String, ResultsProxy>
      .set(key: kotlin.String, value: kotlin.String) {
         put(key, value)
       }
    /**
     * `map<string, string> results = 1;`
     */
    @kotlin.jvm.JvmSynthetic
    @JvmName("removeResults")
    public fun com.google.protobuf.kotlin.DslMap<kotlin.String, kotlin.String, ResultsProxy>
      .remove(key: kotlin.String) {
         _builder.removeResults(key)
       }
    /**
     * `map<string, string> results = 1;`
     */
    @kotlin.jvm.JvmSynthetic
    @JvmName("putAllResults")
    public fun com.google.protobuf.kotlin.DslMap<kotlin.String, kotlin.String, ResultsProxy>
      .putAll(map: kotlin.collections.Map<kotlin.String, kotlin.String>) {
         _builder.putAllResults(map)
       }
    /**
     * `map<string, string> results = 1;`
     */
    @kotlin.jvm.JvmSynthetic
    @JvmName("clearResults")
    public fun com.google.protobuf.kotlin.DslMap<kotlin.String, kotlin.String, ResultsProxy>
      .clear() {
         _builder.clearResults()
       }
  }
}
public inline fun pl.leancode.patrol.contracts.Contracts.SubmitTestResultsRequest.copy(block: pl.leancode.patrol.contracts.SubmitTestResultsRequestKt.Dsl.() -> kotlin.Unit): pl.leancode.patrol.contracts.Contracts.SubmitTestResultsRequest =
  pl.leancode.patrol.contracts.SubmitTestResultsRequestKt.Dsl._create(this.toBuilder()).apply { block() }._build()
