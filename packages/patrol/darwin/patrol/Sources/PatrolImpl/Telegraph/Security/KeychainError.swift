//
//  KeychainError.swift
//  Telegraph
//
//  Created by Yvo van Beek on 6/26/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public enum KeychainError: Error {
  case invalidResult
  case itemAlreadyExists
  case itemNotFound
  case other(code: OSStatus)

  init(code: OSStatus) {
    switch code {
    case errSecDuplicateItem:
      self = .itemAlreadyExists
    case errSecItemNotFound:
      self = .itemNotFound
    default:
      self = .other(code: code)
    }
  }
}

extension KeychainError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .invalidResult:
      return "The keychain item returned wasn't of the expected type"
    case .itemAlreadyExists:
      return "The keychain item already exists"
    case .itemNotFound:
      return "The keychain item doesn't exist"
    case .other(let code):
      return "The keychain operation failed with code \(code)"
    }
  }
}

extension KeychainError: LocalizedError {
  public var errorDescription: String? {
    return description
  }
}
