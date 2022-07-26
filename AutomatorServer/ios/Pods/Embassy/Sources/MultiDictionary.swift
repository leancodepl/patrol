//
//  MultiDictionary.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 6/1/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

/// Transformer for MultiDictionary keys, like lower case
public protocol KeyTransformer {
    associatedtype Key: Hashable
    static func transform(key: Key) -> Key
}

/// A key transformer that does nothing to the key but simply return it
public struct NoOpKeyTransform<T: Hashable>: KeyTransformer {
    public typealias Key = T
    public static func transform(key: T) -> Key {
        return key
    }
}

/// A key transformer that lowers case of the String key, so that the MultiDictionary will be
/// case-insenstive
public struct LowercaseKeyTransform: KeyTransformer {
    public typealias Key = String
    public static func transform(key: Key) -> Key {
        return key.lowercased()
    }
}

/// MultiDictionary is a Dictionary and Array like container, it allows one key to have multiple
/// values
public struct MultiDictionary<
    Key,
    Value,
    KeyTransform: KeyTransformer>
    where KeyTransform.Key == Key
 {
    public typealias ArrayType = Array<(Key, Value)>
    public typealias DictionaryType = Dictionary<Key, Array<Value>>

    // Items in this multi dictionary
    fileprivate let items: ArrayType
    // Dictionary mapping from key to tuple of original key (before transform) and all values in
    /// order
    fileprivate let keyValuesMap: DictionaryType

    public init(items: Array<(Key, Value)>) {
        self.items = items
        var keyValuesMap: DictionaryType = [:]
        for (key, value) in items {
            let transformedKey = KeyTransform.transform(key: key)
            var values = keyValuesMap[transformedKey] ?? []
            values.append(value)
            keyValuesMap[transformedKey] = values
        }
        self.keyValuesMap = keyValuesMap
    }

    /// Get all values for given key in occurrence order
    ///  - Parameter key: the key
    ///  - Returns: tuple of array of values for given key
    public func valuesFor(key: Key) -> Array<Value>? {
        return keyValuesMap[KeyTransform.transform(key: key)]
    }
    /// Get the first value for given key if available
    ///  - Parameter key: the key
    ///  - Returns: first value for the key if available, otherwise nil will be returned
    public subscript(key: Key) -> Value? {
        return valuesFor(key: key)?.first
    }
}

// MARK: CollectionType
extension MultiDictionary: Collection {

    public typealias Index = ArrayType.Index

    public var startIndex: Index {
        return items.startIndex
    }

    public var endIndex: Index {
        return items.endIndex
    }

    public subscript(position: Index) -> Element {
        return items[position]
    }

    public func index(after i: Index) -> Index {
        guard i != endIndex else { fatalError("Cannot increment endIndex") }
        return i + 1
    }
}

// MARK: ArrayLiteralConvertible
extension MultiDictionary: ExpressibleByArrayLiteral {
    public typealias Element = ArrayType.Element
    public init(arrayLiteral elements: Element...) {
        items = elements
        var keyValuesMap: DictionaryType = [:]
        for (key, value) in items {
            let transformedKey = KeyTransform.transform(key: key)
            var values = keyValuesMap[transformedKey] ?? []
            values.append(value)
            keyValuesMap[transformedKey] = values
        }
        self.keyValuesMap = keyValuesMap
    }
}
