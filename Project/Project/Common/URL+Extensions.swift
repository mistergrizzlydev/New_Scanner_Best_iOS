//
//  URL+Extensions.swift
//  Project
//
//  Created by Mister Grizzly on 06.04.2023.
//

import Foundation

extension URL {
  var isCachePencilKitFile: Bool {
    let cacheName = "A Document Being Saved By".lowercased()
    return lastPathComponent.lowercased().contains(cacheName)
  }
}

extension URL {
  var isDirectory: Bool {
    var isDir: ObjCBool = false
    FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    return isDir.boolValue
  }
}
