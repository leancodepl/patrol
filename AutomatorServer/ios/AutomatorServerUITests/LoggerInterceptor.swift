import Foundation
import GRPC
import NIOCore

class LoggerInterceptor<ReqT, ResT>: ServerInterceptor<ReqT, ResT> {
  override func send(
    _ part: GRPCServerResponsePart<ResT>,
    promise: EventLoopPromise<Void>?,
    context: ServerInterceptorContext<ReqT, ResT>
  ) {
    context.send(part, promise: promise)
  }
}
