//
//  Document.swift
//  TurboScan
//
//  Created by Mister Grizzly on 06.04.2023.
//

import Foundation
import CoreGraphics
import UIKit

enum DocumentType {
  case folder
  case file
}

protocol Document {
  init(url: URL)
  
  var url: URL { get }
  var type: DocumentType { get }
  
  var name: String { get }
  var fullName: String { get }
  
  var fileExtension: String? { get }
  var fileAttributes: [FileAttributeKey: Any]? { get }
  
  var documentURL: URL { get }
  var date: String? { get }
  var sizeOfFile: String? { get }
  var count: Int? { get }
  
  var thumbnailURL: URL? { get set }
  var image: UIImage? { get }
}

extension Document {
  var fullName: String {
    return url.lastPathComponent
  }
  
  var name: String {
    switch type {
    case .file: return url.deletingPathExtension().lastPathComponent
    case .folder: return url.lastPathComponent
    }
  }
  
  var type: DocumentType {
    url.isDirectory ? .folder : .file
  }
  
  var fileExtension: String? {
    return url.pathExtension.isEmpty ? nil : url.pathExtension
  }
  
  var fileAttributes: [FileAttributeKey : Any]? {
    return try? FileManager.default.attributesOfItem(atPath: url.path)
  }
  
  var documentURL: URL {
    return url
  }
  
  var count: Int? {
    switch type {
    case .file:
      guard let pdf = CGPDFDocument(url as CFURL) else { return nil }
      return pdf.numberOfPages
    case .folder:
      do {
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        let count = contents.filter{ !$0.isCachePencilKitFile }.count
        return count
      } catch {
        return nil
      }
    }
  }
  
  var date: String? {
    if let attributes = fileAttributes,
       let creationDate = attributes[.creationDate] as? Date {
      return DateFormatter.localizedString(from: creationDate, dateStyle: .medium, timeStyle: .short)
    }
    return nil
  }
  
//  var thumbnailURL: URL? {
//    get {
//      return nil
//    }
//    set {}
//  }
  
  var sizeOfFile: String? {
    switch type {
    case .file:
      if let fileAttributes = fileAttributes {
        if let size = fileAttributes[.size] as? UInt64 {
          return byteCountFormatter(size: size)
        } else {
          return nil
        }
      } else {
        return nil
      }
    case .folder:
      guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles]),
            let urls = enumerator.allObjects as? [URL]
      else {
        return nil
      }
      
      var size = UInt64(0)
      for fileURL in urls {
        do {
          let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
          if let fileSize = attributes[.size] as? UInt64 {
            size += fileSize
          }
        } catch {
          debugPrint("Error: \(error)")
        }
      }
      
      return byteCountFormatter(size: size)
    }
  }
}

private extension Document {
  func byteCountFormatter(size: UInt64) -> String {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .file
    formatter.allowedUnits = [.useKB, .useMB, .useGB]
    return formatter.string(fromByteCount: Int64(size))
  }
}
