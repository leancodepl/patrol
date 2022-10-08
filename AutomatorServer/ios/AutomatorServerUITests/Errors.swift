import Foundation
import XCTest
import GRPC

enum PatrolError: Error {
  case viewNotExists(_ elementDescription: String)
  case appNotInstalled(_ bundleId: String)
  case generic(_ message: String)
  case unknown(_ error: Error)
}


extension PatrolError: CustomStringConvertible, GRPCStatusTransformable {
  var description: String {
    switch self {
    case .viewNotExists(let elementDescription):
      return "\(elementDescription) doesn't exist"
    case .appNotInstalled(let bundleId):
      return "app \(format: bundleId) is not installed"
    case .generic(let message):
      return message
    case .unknown(let err):
      return "\(err)"
    }
  }
  
  func makeGRPCStatus() -> GRPC.GRPCStatus {
    switch self {
    case .viewNotExists, .appNotInstalled:
      return GRPCStatus(code: .notFound, message: self.description)
    case .generic:
      return GRPCStatus(code: .internalError, message: self.description)
    case .unknown(let err):
      return GRPCStatus(code: .unknown, message: "unknown error: \(err)")
    }
  }
}
