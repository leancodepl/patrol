//
//  Array+Ext.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/19/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public extension Array {
  /// Returns the first item in an array that conforms to the provided type.
  func first<T>(ofType: T.Type) -> T? {
    return first { $0 as? T != nil } as? T
  }

  /// Returns only the items that match the provided type.
  func filter<T>(ofType: T.Type) -> [T] {
    return compactMap { $0 as? T }
  }
}
