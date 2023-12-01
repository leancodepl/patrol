//
//  Stream.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/2/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public protocol ReadStream {
  func read(timeout: TimeInterval)
}

public protocol WriteStream {
  func flush()
  func write(data: Data, timeout: TimeInterval)
}
