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

extension URL {
  func getSize() -> String? {
    if hasDirectoryPath {
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
