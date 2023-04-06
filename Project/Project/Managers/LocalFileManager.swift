//
//  LocalFileManager.swift
//  TurboScan
//
//  Created by Mister Grizzly on 06.04.2023.
//

import Foundation

protocol LocalFileManager: AnyObject {
  func getDocumentsURL() -> URL
  func contentsOfDirectory(url: URL) -> [Document]?
  
  func createFile(withName name: String, contents: Data) -> Bool
  func delete(_ document: Document) -> Bool
  
  func createFolders(for category: OnboardingCategory) throws
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
    
    setupThumbnailsFolder()
  }
  
  private func setupThumbnailsFolder() {
    if !FileManager.default.fileExists(atPath: thumbnailsFolderURL.path) {
      do {
        try FileManager.default.createDirectory(at: thumbnailsFolderURL, withIntermediateDirectories: true, attributes: nil)
      } catch {
        debugPrint("Failed to create thumbnails folder: \(error)")
      }
    }
  }
  
  func getDocumentsURL() -> URL {
    return documentsURL
  }
  
  func contentsOfDirectory(url: URL) -> [Document]? {
    guard url.isDirectory else { return nil }
    
    let fileManager = FileManager.default
    let contents = try! fileManager.contentsOfDirectory(at: url,
                                                        includingPropertiesForKeys: [.isDirectoryKey],
                                                        options: [.skipsHiddenFiles])
    var documents = [Document]()
    for url in contents {
      if !url.isCachePencilKitFile {
        if url.isDirectory {
          let folder = Folder(url: url)
          documents.append(folder)
        } else if url.pathExtension != "tmp" { // skip files with the ".tmp" suffix
          let thumbnail = generateThumbnail(for: url)
          let file = File(url: url, image: thumbnail, thumbnailURL: thumbnailsFolderURL)
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
      print("Failed to create file: \(error)")
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

import PDFKit

extension LocalFileManager {
  func generateThumbnail(for pdfURL: URL) -> UIImage? {
      guard let pdfDocument = PDFDocument(url: pdfURL) else {
          return nil
      }
      let pdfPage = pdfDocument.page(at: 0)
      let thumbnailSize = CGSize(width: 200, height: 200) // set your desired size here
      return pdfPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.mediaBox)
  }
}
