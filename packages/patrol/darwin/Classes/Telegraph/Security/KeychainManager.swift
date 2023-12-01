//
//  KeychainManager.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/26/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation
import Security

public class KeychainManager {
  public static let shared = KeychainManager()
  public var accessibility = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

  public typealias KeychainClass = CFString
  public typealias KeychainValue = AnyObject
  public typealias KeychainQuery = [NSString: AnyObject]
}

// MARK: PKCS12 methods

public extension KeychainManager {
  /// Imports the PKCS12 data into the keychain.
  func importPKCS12(data: Data, passphrase: String, options: KeychainQuery = KeychainQuery()) -> SecIdentity? {
    var query = options
    query[kSecImportExportPassphrase] = passphrase as NSString

    // Import the data
    var importResult: CFArray?
    let status = withUnsafeMutablePointer(to: &importResult) { SecPKCS12Import(data as NSData, query as CFDictionary, $0) }
    guard status == errSecSuccess else { return nil }

    // The result is an array of dictionaries, we are looking for the one that contains the identity
    let importArray = importResult as? [[NSString: AnyObject]]
    let importIdentity = importArray?.compactMap { dict in dict[kSecImportItemIdentity as NSString] }.first

    // Let's double check that we have a result and that it is a SecIdentity
    guard let rawResult = importIdentity, CFGetTypeID(rawResult) == SecIdentityGetTypeID() else { return nil }
    let result = rawResult as! SecIdentity

    return result
  }
}

// MARK: Query methods

public extension KeychainManager {
  /// Adds a value to the keychain.
  func add(value: KeychainValue, label: String, options: KeychainQuery = KeychainQuery()) throws {
    // Don't specify kSecClass otherwise SecItemCopyMatching won't be able to find identities
    var query = options
    query[kSecAttrLabel] = label as NSString
    query[kSecAttrAccessible] = accessibility
    query[kSecValueRef] = value

    var result: AnyObject?
    let status = withUnsafeMutablePointer(to: &result) { SecItemAdd(query as CFDictionary, $0) }
    guard status == errSecSuccess else { throw KeychainError(code: status) }
  }

  /// Finds an item in the keychain.
  func find<T>(_ kClass: KeychainClass, label: String, options: KeychainQuery = KeychainQuery()) throws -> T {
    var query = options
    query[kSecClass] = kClass
    query[kSecAttrLabel] = label as NSString
    query[kSecReturnRef] = kCFBooleanTrue

    var result: AnyObject?
    let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(query as CFDictionary, $0) }

    guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError(code: status) }
    guard let item = result else { throw KeychainError.itemNotFound }
    guard let typedItem = item as? T else { throw KeychainError.invalidResult }

    return typedItem
  }

  /// Removes an item from the keychain.
  func remove(_ kClass: KeychainClass, label: String, options: KeychainQuery = KeychainQuery()) throws {
    var query = options
    query[kSecClass] = kClass
    query[kSecAttrLabel] = label as NSString

    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess else { throw KeychainError(code: status) }
  }
}
