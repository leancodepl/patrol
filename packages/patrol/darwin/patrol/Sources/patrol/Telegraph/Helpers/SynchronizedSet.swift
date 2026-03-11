//
//  SynchronizedArray.swift
//  Telegraph
//
//  Created by Yvo van Beek on 7/13/18.
//  Copyright © 2018 Building42. All rights reserved.
//

import Foundation

public class SynchronizedSet<Element: Hashable> {
  private var innerSet = Set<Element>()
  private let queue = DispatchQueue(label: "Telegraph.SynchronizedSet", attributes: .concurrent)
}

extension SynchronizedSet {
  /// The number of elements in the set.
  public var count: Int {
    return queue.sync { innerSet.count }
  }

  /// A boolean indicating if the set is empty.
  public var isEmpty: Bool {
    return queue.sync { innerSet.isEmpty }
  }

  /// A textual representation of the set and its elements.
  public var description: String {
    return queue.sync { innerSet.description }
  }
}

extension SynchronizedSet {
  /// Inserts a new element into the set.
  public func insert(_ element: Element) {
    queue.async(flags: .barrier) { [weak self] in
      self?.innerSet.insert(element)
    }
  }

  /// Removes an element from the set.
  public func remove(_ element: Element) {
    queue.async(flags: .barrier) { [weak self] in
      self?.innerSet.remove(element)
    }
  }
}

extension SynchronizedSet {
  /// Returns a boolean indicating if the set contains the given element.
  public func contains(_ element: Element) -> Bool {
    return queue.sync { innerSet.contains(element) }
  }

  /// Calls the given closure on each element in the set.
  public func forEach(_ body: (Element) -> Void) {
    queue.sync { innerSet.forEach(body) }
  }
}

extension SynchronizedSet {
  /// Returns an array copy of the set.
  public func toArray() -> [Element] {
    return queue.sync { Array(innerSet) }
  }

  /// Returns a copy of the set.
  public func toSet() -> Set<Element> {
    return innerSet
  }
}
