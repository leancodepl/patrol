package pl.leancode.patrol

import androidx.test.uiautomator.UiObjectNotFoundException
import io.grpc.ForwardingServerCall
import io.grpc.Metadata
import io.grpc.ServerCall
import io.grpc.ServerCallHandler
import io.grpc.ServerInterceptor
import io.grpc.Status

class LoggerInterceptor : ServerInterceptor {

    private class ExceptionTranslatingServerCall<ReqT, RespT>(
        delegate: ServerCall<ReqT, RespT>
    ) : ForwardingServerCall.SimpleForwardingServerCall<ReqT, RespT>(delegate) {

        private fun handleErrorStatus(exception: Throwable?): Status {
            val newStatus = when (exception) {
                is UiObjectNotFoundException -> {
                    Status
                        .NOT_FOUND
                        .withDescription("selector ${exception.message} found nothing")
                }

                is NotImplementedError -> {
                    Status
                        .UNIMPLEMENTED
                        .withDescription("method ${exception.message}() is not implemented on Android")
                }

                else -> {
                    Status
                        .UNKNOWN
                        .withDescription("unknown error: $exception")
                }
            }

            return newStatus.withCause(exception)
        }

        override fun close(status: Status, trailers: Metadata) {
            if (status.isOk) {
                return super.close(status, trailers)
            }
            val cause = status.cause

            val newStatus = if (status.code == Status.Code.UNKNOWN) {
                Logger.e("Error handling gRPC endpoint", cause)
                handleErrorStatus(cause)
            } else {
                status
            }

            super.close(newStatus, trailers)
        }
    }

    override fun <ReqT : Any?, RespT : Any?> interceptCall(
        call: ServerCall<ReqT, RespT>,
        headers: Metadata,
        next: ServerCallHandler<ReqT, RespT>
    ): ServerCall.Listener<ReqT> {
        return next.startCall(ExceptionTranslatingServerCall(call), headers)
    }
}
