//
//  URL+Extensions.swift
//  Project
//
//  Created by Mister Grizzly on 06.04.2023.
//

import Foundation

enum FileType: String {
  case jpg
  case png
  case pdf
  case other
  
  init?(fileExtension: String) {
    guard let type = FileType(rawValue: fileExtension.lowercased()) else {
      self = .other
      return
    }
    self = type
  }
}

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

extension URL {
  var fileType: FileType {
    guard let type = FileType(fileExtension: pathExtension) else {
      return .other
    }
    return type
  }
}
