//
//  DataStream.swift
//  Telegraph
//
//  Created by Yvo van Beek on 7/24/18.
//  Copyright © 2018 Building42. All rights reserved.
//

import Foundation

public final class DataStream {
  private let data: Data
  public private (set) var position: Int

  /// Initializes a new DataStream.
  public init(data: Data = Data()) {
    self.data = data
    self.position = 0
  }

  /// Returns if there are more bytes to read.
  public var hasBytesAvailable: Bool {
    return position < data.count
  }

  /// Returns the next byte.
  public func read() -> UInt8? {
    guard position < data.count else { return nil }

    defer { position += 1 }
    return data[position]
  }

  /// Returns the next chunk of the data. Note: the data is copied.
  public func read(count: Int) -> Data {
    guard position < data.count else { return Data() }

    let endPosition = min(position + count, data.count)

    defer { position = endPosition }
    return data.subdata(in: position..<endPosition)
  }

  /// Returns the remaining chunk of data. Note: the data is copied.
  public func readToEnd() -> Data {
    return read(count: data.count)
  }
}
