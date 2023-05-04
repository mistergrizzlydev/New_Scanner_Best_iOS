import UIKit

protocol LocalFileManager: AnyObject {
  func getDocumentsURL() -> URL
  func isRootDirectory(url: URL) -> Bool
  
  func contentsOfDirectory(url: URL, sortBy sortType: SortType) -> [Document]?
  
  func createFile(withName name: String, contents: Data) -> Bool
  
  func delete(_ document: Document) -> Bool
  func delete(_ urls: [URL]) throws
  
  func createFolders(for category: OnboardingCategory) throws
  
  func createFolder(with name: String, at url: URL) throws -> URL
  
  func moveFile(from sourceURL: URL, to destinationURL: URL) throws
  func mergePDF(urls: [URL], with name: String, toRootURL url: URL)
  func mergeFolders(urls: [URL], with folderName: String, toRootURL url: URL)
  func duplicateFiles(_ urls: [URL]) throws
  
  func deletePencilKitFiles(at url: URL) throws
  func searchInDirectory(url: URL, searchFor name: String) -> [Document]
}

final class LocalFileManagerDefault: LocalFileManager {
  private struct Constants {
    static let thumbnailsFolder = ".Thumbnails"
  }
  
  private let documentsURL: URL
  
  var thumbnailsFolderURL: URL {
    documentsURL.appendingPathComponent(Constants.thumbnailsFolder)
  }
  
  init() {
    let uniqueId = "8F9F8563-B56C-4B8A-9D2E-3DF2EB08B1C9"
    let hiddenFolderName = ".MyDocuments/.\(uniqueId)"
    
    documentsURL = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0].appendingPathComponent(hiddenFolderName)
    
    // Create the hidden "Documents" folder if it doesn't exist
    if !FileManager.default.fileExists(atPath: documentsURL.path) {
      do {
        try FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
      } catch {
        debugPrint("Failed to create Documents folder: \(error)")
      }
    }
    
    setupThumbnailsFolder(url: thumbnailsFolderURL)
  }
  
  internal func setupThumbnailsFolder(url: URL) {
    if !FileManager.default.fileExists(atPath: url.path) {
      do {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
      } catch {
        debugPrint("Failed to create thumbnails folder: \(error)")
      }
    }
  }
  
  func getDocumentsURL() -> URL {
    return documentsURL
  }
  
  func isRootDirectory(url: URL) -> Bool {
    debugPrint("documentsURL", documentsURL.path)
    debugPrint("url", url.path)
    
    if getDocumentsURL().path == url.path {
      debugPrint("This is the root directory.")
    } else {
      debugPrint("This is not the root directory.")
    }
    
    return getDocumentsURL().path == url.path
  }
  
  func contentsOfDirectory(url: URL, sortBy sortType: SortType) -> [Document]? {
    guard url.isDirectory else { return nil }
    
    let fileManager = FileManager.default
    let contents = try! fileManager.contentsOfDirectory(at: url,
                                                        includingPropertiesForKeys: [.isDirectoryKey],
                                                        options: [.skipsHiddenFiles])
    var documents = [Document]()
    for url in contents {
      if !url.isCachePencilKitFile, url.isDirectory {
        let folder = Folder(url: url)
        documents.append(folder)
      } else if url.fileType == .pdf {
        let thumbnailName = url.deletingPathExtension().appendingPathExtension("jpg").lastPathComponent
        let thumbnailURL = thumbnailsFolderURL.appendingPathComponent(thumbnailName)
        if fileManager.fileExists(atPath: thumbnailURL.path) {
          let file = File(url: url, image: thumbnailURL.toImage, thumbnailURL: thumbnailURL)
          documents.append(file)
        } else {
          let thumbnail = getCreateAndGetThumbnail(for: url, thumbnailsFolderName: Constants.thumbnailsFolder)
          let file = File(url: url, image: thumbnail.image, thumbnailURL: thumbnail.url)
          documents.append(file)
        }
      }
    }
    
    switch sortType {
    case .date: return documents.sortByDate()
    case .name: return documents.sortByName()
    case .size: return documents.sortBySize()
    case .foldersOnTop: return documents.sortedFoldersOnTop()
    }
  }
  
  func searchInDirectory(url: URL, searchFor name: String) -> [Document] {
    let fileManager = FileManager.default
    let contents = fileManager.search(in: url, for: name)
    
    var documents = [Document]()
    
    for url in contents {
      if !url.isCachePencilKitFile, url.isDirectory {
        let folder = Folder(url: url)
        documents.append(folder)
      } else if url.fileType == .pdf {
        let thumbnailName = url.deletingPathExtension().appendingPathExtension("jpg").lastPathComponent
        let thumbnailURL = thumbnailsFolderURL.appendingPathComponent(thumbnailName)
        if fileManager.fileExists(atPath: thumbnailURL.path) {
          let file = File(url: url, image: thumbnailURL.toImage, thumbnailURL: thumbnailURL)
          documents.append(file)
        } else {
          let thumbnail = getCreateAndGetThumbnail(for: url, thumbnailsFolderName: Constants.thumbnailsFolder)
          let file = File(url: url, image: thumbnail.image, thumbnailURL: thumbnail.url)
          documents.append(file)
        }
      }
    }
    
    return documents
  }
  
  func createFile(withName name: String, contents: Data) -> Bool {
    let fileURL = documentsURL.appendingPathComponent(name)
    do {
      try contents.write(to: fileURL)
      return true
    } catch {
      debugPrint("Failed to create file: \(error)")
      return false
    }
  }
  
  func delete(_ document: Document) -> Bool {
    do {
      try FileManager.default.removeItem(at: document.url)
      return true
    } catch {
      debugPrint("Failed to delete document: \(error)")
      return false
    }
  }
  
  func moveFile(from sourceURL: URL, to destinationURL: URL) throws {
    let fileManager = FileManager.default
    try fileManager.moveItem(at: sourceURL, to: destinationURL)
  }
}

extension LocalFileManagerDefault {
  enum FolderCreationError: Error {
    case directoryCreationFailed
    case categoryDirectoryCreationFailed
    case folderCreationFailed
  }
  
  func createFolders(for category: OnboardingCategory) throws {
    let fileManager = FileManager.default
    let url = getDocumentsURL()
    
    let pdfFile = Bundle.main.bundleURL.appendingPathComponent("TurboScan™ Tutorial.pdf")
    let newPDFURL = url.appendingPathComponent(pdfFile.lastPathComponent)
    if !fileManager.fileExists(atPath: newPDFURL.path) {
      try? fileManager.copyItem(at: pdfFile, to: newPDFURL)
    }
    
    // Create directory if it doesn't exist
    if !fileManager.fileExists(atPath: url.path) {
      do {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
      } catch {
        throw FolderCreationError.directoryCreationFailed
      }
    }
    
    do {
      try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
      
      // Create popular folders for the category
      for folderName in category.popularFolderNames {
        let folderUrl = url.appendingPathComponent(folderName)
        if !fileManager.fileExists(atPath: folderUrl.path) {
          do {
            try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
          } catch {
            throw FolderCreationError.folderCreationFailed
          }
        }
      }
      
    } catch {
      throw FolderCreationError.categoryDirectoryCreationFailed
    }
  }
}

extension UIPasteboard {
  static func copyContentsOfFolderToClipboard(at url: URL) {
    let pasteboard = UIPasteboard.general
    pasteboard.url = url
    
    //        var fileURLs: [URL] = []
    //        do {
    //            fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
    //        } catch {
    //            print("Error: \(error.localizedDescription)")
    //            return
    //        }
    //
    //        pasteboard.items
    
    debugPrint("aaa", pasteboard.items, pasteboard.url)
  }
}

extension LocalFileManager {
  func createFolder(with name: String, at url: URL) throws -> URL {
    let fileManager = FileManager.default
    return try fileManager.createUniqueFolder(at: url, withName: name)
  }
  
  func delete(_ urls: [URL]) throws {
    try FileManager.default.delete(urls)
  }
}

extension LocalFileManager {
  func deletePencilKitFiles(at url: URL) throws {
    let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
    let cachePencilKitFiles = contents.filter { $0.isCachePencilKitFile }
    try FileManager.default.delete(cachePencilKitFiles)
  }
}
