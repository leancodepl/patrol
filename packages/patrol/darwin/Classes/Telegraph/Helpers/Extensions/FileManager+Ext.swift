//
//  FileManager+Ext.swift
//  Telegraph
//
//  Created by Yvo van Beek on 5/16/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)
  import MobileCoreServices
#endif

public extension FileManager {
  /// Returns the mime type for a path extension (e.g. wasm).
  func mimeType(pathExtension: String) -> String {
    // Check if there is an override for the extension
    switch pathExtension {
    case "wasm": return "application/wasm"
    default: break
    }

    // Let the system determine the proper mime-type
    if
      let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
      let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
      return mimeType as String
    }

    // No mime-type found? Return the fallback
    return "application/octet-stream"
  }
}
