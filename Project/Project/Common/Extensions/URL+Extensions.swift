import Foundation
import PDFKit

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
  func appendPDF(from newDocURL: URL) {
    guard pathExtension == FileType.pdf.rawValue, newDocURL.pathExtension == FileType.pdf.rawValue else { return }
    guard let originalDocument = PDFDocument(url: self), let documentToAppend = PDFDocument(url: newDocURL), !originalDocument.isLocked else { return }  // handle locked
    
    for pageIndex in 0..<documentToAppend.pageCount {
      if let page = documentToAppend.page(at: pageIndex) {
        originalDocument.insert(page, at: originalDocument.pageCount) // end
      }
    }
    
    do {
      let data = originalDocument.dataRepresentation()
      try data?.write(to: self)
    } catch {
      return
    }
  }
  
  func appendPDF(from newDocURL: URL, andRefreshAtPage pageIndex: Int) {
    guard pathExtension == FileType.pdf.rawValue, newDocURL.pathExtension == FileType.pdf.rawValue else { return }
    guard let originalDocument = PDFDocument(url: self), let documentToAppend = PDFDocument(url: newDocURL), !originalDocument.isLocked else { return } // handle locked
    
    let newPageIndex = pageIndex - 1
    if let page = documentToAppend.page(at: 0), newPageIndex >= 0 {
      originalDocument.removePage(at: newPageIndex)
      originalDocument.insert(page, at: newPageIndex) // from the specific spacent
    }
    
    do {
      let data = originalDocument.dataRepresentation()
      try data?.write(to: self)
    } catch {
      return
    }
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
    hasDirectoryPath
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

extension URL {
  func getSize() -> String? {
    if isDirectory {
      guard let enumerator = FileManager.default.enumerator(at: self, includingPropertiesForKeys: [.totalFileAllocatedSizeKey], options: [.skipsHiddenFiles]) else {
        return nil
      }
      
      var size: UInt64 = 0
      for case let fileURL as URL in enumerator {
        do {
          // Add up file size
          let resourceValues = try fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
          size += UInt64(resourceValues.totalFileAllocatedSize ?? 0)
        } catch {
          return nil
        }
      }
      
      let formatter = ByteCountFormatter()
      formatter.allowedUnits = [.useMB, .useGB, .useTB]
      formatter.countStyle = .file
      return formatter.string(fromByteCount: Int64(size))
    } else {
      do {
        let resourceValues = try resourceValues(forKeys: [.fileSizeKey])
        let fileSize = resourceValues.fileSize ?? 0
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        let formattedSize = formatter.string(fromByteCount: Int64(fileSize))
        
        return formattedSize
      } catch {
        return nil
      }
    }
  }
}

extension URL {
  static func generateTempPDFURL() -> URL {
    let uuid = UUID().uuidString
    let tmpDirectory = NSTemporaryDirectory() as NSString
    let filePath = tmpDirectory.appendingPathComponent("\(uuid).pdf")
    return URL(fileURLWithPath: filePath)
  }
}

extension URL {
  var toImage: UIImage? {
    if pathExtension == "jpg", let data = try? Data(contentsOf: self) {
      return UIImage(data: data)
    }
    
    return nil
  }
}

extension URL {
  var generateFileName: String {
    return Locale.current.fileNameFromSelectedTags(self)
  }
}

extension Array where Element == URL {
  func save(to folderURL: URL) throws {
    for url in self {
      if let validatedName = FileManager.default.validatedName(at: folderURL.appendingPathComponent(url.lastPathComponent)) {
        let fileURL = folderURL.appendingPathComponent(validatedName)
        let data = try Data(contentsOf: url)
        try data.write(to: fileURL, options: .atomic)
      }
    }
  }
}

extension URL {
  private struct DocumentConstants {
    static let kStarredAttribute = "★"
  }
  
  func isFileStarred() -> Bool {
    let name = lastPathComponent
    return name.contains(DocumentConstants.kStarredAttribute)
  }
  
  func starFile() {
    guard !isFileStarred() else { return }
    let starredName = DocumentConstants.kStarredAttribute + lastPathComponent
    let starredURL = deletingLastPathComponent().appendingPathComponent(starredName)
    do {
      try FileManager.default.moveItem(at: self, to: starredURL)
      debugPrint("Starred file ", path)
    } catch {
      // Error handling code
      debugPrint(error.localizedDescription, "starFile")
    }
  }
  
  func unstarFile() {
    guard isFileStarred() else { return }
    let unstarredName = lastPathComponent.replacingOccurrences(of: DocumentConstants.kStarredAttribute, with: "")
    let unstarredURL = deletingLastPathComponent().appendingPathComponent(unstarredName)
    do {
      try FileManager.default.moveItem(at: self, to: unstarredURL)
//      debugPrint("unstarFile ", path, fileAttributes)
    } catch {
      // Error handling code
      debugPrint(error.localizedDescription, "unstarFile")
    }
  }
}
