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
  
  func isFileStarred() -> Bool
  func starFile()
  func unstarFile()
  
  func details() -> String?
}

private struct DocumentConstants {
  static let kStarredAttribute = "★"
}

extension URL {
  var pdfName: String {
    var fileName = lastPathComponent
    if let range = fileName.range(of: DocumentConstants.kStarredAttribute) {
      fileName.removeSubrange(range)
    }
    return fileName
  }
}

extension Document {
  var fullName: String {
    var fileName = url.lastPathComponent
    if let range = fileName.range(of: DocumentConstants.kStarredAttribute) {
      fileName.removeSubrange(range)
    }
    return fileName
  }
  
  var name: String {
    var fileName = url.lastPathComponent
    if let range = fileName.range(of: DocumentConstants.kStarredAttribute) {
      fileName.removeSubrange(range)
    }
    return fileName
  }
  
  var type: DocumentType {
    url.hasDirectoryPath ? .folder : .file
  }
  
  var fileExtension: String? {
    return url.pathExtension.isEmpty ? nil : url.pathExtension
  }
  
  var fileAttributes: [FileAttributeKey: Any]? {
    return try? FileManager.default.attributesOfItem(atPath: url.path)
  }
  
  var documentURL: URL {
    return url
  }
  
  func isFileStarred() -> Bool {
    let name = url.lastPathComponent
    return name.contains(DocumentConstants.kStarredAttribute)
  }
  
  func starFile() {
    guard !isFileStarred() else { return }
    let starredName = DocumentConstants.kStarredAttribute + url.lastPathComponent
    let starredURL = url.deletingLastPathComponent().appendingPathComponent(starredName)
    do {
      try FileManager.default.moveItem(at: url, to: starredURL)
      print("Starred file ", url.path)
    } catch {
      // Error handling code
      print(error.localizedDescription, "starFile")
    }
  }
  
  func unstarFile() {
    let unstarredName = url.lastPathComponent.replacingOccurrences(of: DocumentConstants.kStarredAttribute, with: "")
    let unstarredURL = url.deletingLastPathComponent().appendingPathComponent(unstarredName)
    do {
      try FileManager.default.moveItem(at: url, to: unstarredURL)
      print("unstarFile ", url.path, fileAttributes)
    } catch {
      // Error handling code
      print(error.localizedDescription, "unstarFile")
    }
  }
  
  func starUnstarFile() {
    
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

extension Array where Element == Document {
  func sortByDate() -> [Document] {
    self.sorted { (doc1, doc2) -> Bool in
      let date1 = doc1.fileAttributes?[.modificationDate] as? Date
      let date2 = doc2.fileAttributes?[.modificationDate] as? Date
      return date1 ?? Date.distantPast > date2 ?? Date.distantPast
    }
  }
  
  func sortByName() -> [Document] {
    self.sorted { (doc1, doc2) -> Bool in
      doc1.name.lowercased() < doc2.name.lowercased()
    }
  }
  
  func sortBySize() -> [Document] {
    self.sorted { (doc1, doc2) -> Bool in
      let size1 = try? doc1.url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
      let size2 = try? doc2.url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
      return size1 ?? 0 > size2 ?? 0
    }
  }
  func sortedFoldersOnTop() -> [Element] {
    let folders = filter { $0.url.isDirectory }
    let files = filter { !$0.url.isDirectory }
    return folders + files
  }
}

extension Document {
  func details() -> String? {
    guard let attributes = fileAttributes else { return nil }

    let fileName = name
    let fileSize = attributes[.size] as? UInt64 ?? 0
    let fileSizeString = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    let creationDate = attributes[.creationDate] as? Date ?? Date()
    let type = type == .folder ? "Folder" : "PDF file"
    let modificationDate = attributes[.modificationDate] as? Date ?? Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    
    let message = "\nFile name: \(fileName)\n\nFile size: \(fileSizeString)\n\nCreated: \(dateFormatter.string(from: creationDate))\n\nModified: \(dateFormatter.string(from: modificationDate))\n\nType: \(type)"
    
    return message
  }
}
