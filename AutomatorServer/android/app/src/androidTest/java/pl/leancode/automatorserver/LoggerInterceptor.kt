package pl.leancode.automatorserver

import androidx.test.uiautomator.UiObjectNotFoundException
import io.grpc.ForwardingServerCall
import io.grpc.Metadata
import io.grpc.ServerCall
import io.grpc.ServerCallHandler
import io.grpc.ServerInterceptor
import io.grpc.Status

class LoggerInterceptor : ServerInterceptor {

    /**
     * When closing a gRPC call, extract any error status information to top-level fields. Also
     * log the cause of errors.
     */
    private class ExceptionTranslatingServerCall<ReqT, RespT>(
        delegate: ServerCall<ReqT, RespT>
    ) : ForwardingServerCall.SimpleForwardingServerCall<ReqT, RespT>(delegate) {

        private fun handleErrorStatus(cause: Throwable?): Status {
            val newStatus = when (cause) {
                is IllegalArgumentException -> {
                    Status
                        .INVALID_ARGUMENT
                        .withDescription(cause.message)
                }

                is IllegalStateException -> {
                    Status
                        .FAILED_PRECONDITION
                        .withDescription(cause.message)
                }

                is UiObjectNotFoundException -> {
                    Status
                        .NOT_FOUND
                        .withDescription("selector ${cause.message} found nothing")
                }

                else -> {
                    Status
                        .UNKNOWN
                        .withDescription("Caught unknown exception $cause")
                }
            }

            return newStatus.withCause(cause)
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
